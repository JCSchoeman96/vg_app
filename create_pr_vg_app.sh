#!/usr/bin/env bash
set -euo pipefail

REMOTE="${REMOTE:-origin}"
BASE_BRANCH="${BASE_BRANCH:-main}"
RUN_CHECKS="yes"
DRAFT_FLAG=""

usage() {
  cat <<USAGE
Usage: scripts/create_pr.sh [--skip-checks] [--draft]

Creates or opens a GitHub PR for the current branch.
Rules:
  - branch must not be ${BASE_BRANCH}
  - working tree must be clean
  - branch must contain commits ahead of ${REMOTE}/${BASE_BRANCH}
  - checks run by default
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-checks)
      RUN_CHECKS="no"
      shift
      ;;
    --draft)
      DRAFT_FLAG="--draft"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Problem: unknown option $1"
      usage
      exit 2
      ;;
  esac
done

problem() {
  echo "Problem: $1"
  echo "Why: $2"
  echo "Fix: $3"
}

require_cmd() {
  command -v "$1" >/dev/null || {
    problem "missing command: $1" "PR creation depends on this tool" "install $1 and retry"
    exit 1
  }
}

require_cmd git
require_cmd gh

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  problem "not inside a Git repository" "PR creation needs repo context" "run from inside the vg_app repo"
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "${repo_root}"

branch="$(git branch --show-current)"
if [[ -z "${branch}" ]]; then
  problem "detached HEAD" "PRs require a named branch" "create or check out a feature branch"
  exit 1
fi

if [[ "${branch}" == "${BASE_BRANCH}" ]]; then
  problem "current branch is ${BASE_BRANCH}" "meaningful work must be reviewed in a PR" "create a feature branch and commit the work there"
  exit 1
fi

if [[ -n "$(git status --short)" ]]; then
  problem "working tree is not clean" "PR creation should happen after intentional commits" "commit or stash changes before creating the PR"
  git status --short --branch
  exit 1
fi

git fetch "${REMOTE}" "${BASE_BRANCH}" --prune

read -r ahead behind < <(git rev-list --left-right --count "${REMOTE}/${BASE_BRANCH}...HEAD")

echo "PR state"
echo "|> branch: ${branch}"
echo "|> base: ${REMOTE}/${BASE_BRANCH}"
echo "|> ahead-of-base: ${ahead}"
echo "|> behind-base: ${behind}"
echo "|> checks: ${RUN_CHECKS}"

if [[ "${ahead}" == "0" ]]; then
  problem "branch has no commits ahead of ${REMOTE}/${BASE_BRANCH}" "there is no meaningful work to review" "commit work before creating a PR"
  exit 1
fi

if [[ "${RUN_CHECKS}" == "yes" ]]; then
  make precommit
fi

if git rev-parse --abbrev-ref --symbolic-full-name '@{u}' >/dev/null 2>&1; then
  echo "|> action: git push"
  git push
else
  echo "|> action: git push -u ${REMOTE} ${branch}"
  git push -u "${REMOTE}" "${branch}"
fi

if gh pr view --json url --jq .url >/tmp/vg_app_existing_pr_url 2>/dev/null; then
  pr_url="$(cat /tmp/vg_app_existing_pr_url)"
  rm -f /tmp/vg_app_existing_pr_url
  echo "|> existing-pr: ${pr_url}"
  exit 0
fi

rm -f /tmp/vg_app_existing_pr_url

echo "|> action: gh pr create --fill --base ${BASE_BRANCH} ${DRAFT_FLAG}"
gh pr create --fill --base "${BASE_BRANCH}" ${DRAFT_FLAG}
