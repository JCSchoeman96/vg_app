#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---check}"
REMOTE="${REMOTE:-origin}"
BASE_BRANCH="${BASE_BRANCH:-main}"

if [[ "${MODE}" != "--check" && "${MODE}" != "--sync" && "${MODE}" != "--status" ]]; then
  echo "Usage: scripts/sync_with_origin_main.sh [--status|--check|--sync]"
  exit 2
fi

problem() {
  local message="$1"
  local why="$2"
  local fix="$3"

  echo
  echo "Problem: ${message}"
  echo "Why: ${why}"
  echo "Fix: ${fix}"
}

git_dir_path() {
  git rev-parse --git-dir
}

has_unresolved_conflicts() {
  [[ -n "$(git diff --name-only --diff-filter=U)" ]]
}

has_in_progress_operation() {
  local git_dir
  git_dir="$(git_dir_path)"

  [[ -f "${git_dir}/MERGE_HEAD" ]] ||
    [[ -d "${git_dir}/rebase-merge" ]] ||
    [[ -d "${git_dir}/rebase-apply" ]] ||
    [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]] ||
    [[ -f "${git_dir}/REVERT_HEAD" ]] ||
    [[ -f "${git_dir}/BISECT_LOG" ]]
}

branch_delta_state() {
  local ahead="$1"
  local behind="$2"

  if [[ "${ahead}" == "0" && "${behind}" == "0" ]]; then
    echo "current"
  elif [[ "${ahead}" == "0" ]]; then
    echo "behind"
  elif [[ "${behind}" == "0" ]]; then
    echo "ahead"
  else
    echo "ahead-and-behind"
  fi
}

remote_branch_exists() {
  local branch="$1"
  git rev-parse --verify "refs/remotes/${REMOTE}/${branch}" >/dev/null 2>&1
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Problem: not inside a Git repository"
  exit 1
fi

CURRENT_BRANCH="$(git branch --show-current)"

if [[ -z "${CURRENT_BRANCH}" ]]; then
  echo "Problem: detached HEAD"
  echo "Fix: check out a branch before syncing"
  exit 1
fi

if ! git remote get-url "${REMOTE}" >/dev/null 2>&1; then
  problem \
    "remote ${REMOTE} not found" \
    "the sync script compares local work against ${REMOTE}/${BASE_BRANCH}" \
    "add the remote or override REMOTE before syncing"
  exit 1
fi

echo "Git sync"
echo "|> branch: ${CURRENT_BRANCH}"
echo "|> mode: ${MODE}"
echo "|> remote: ${REMOTE}"
echo "|> base: ${BASE_BRANCH}"

git fetch "${REMOTE}" --prune

TARGET_REF="${REMOTE}/${BASE_BRANCH}"

if ! git rev-parse --verify "${TARGET_REF}" >/dev/null 2>&1; then
  problem \
    "${TARGET_REF} not found" \
    "the sync script can only compare against a fetched base branch ref" \
    "confirm the remote and base branch, or set BASE_BRANCH explicitly"
  exit 1
fi

STATUS_SHORT="$(git status --short)"
DIRTY_TREE="no"
if [[ -n "${STATUS_SHORT}" ]]; then
  DIRTY_TREE="yes"
fi

IN_PROGRESS="no"
if has_in_progress_operation; then
  IN_PROGRESS="yes"
fi

HAS_CONFLICTS="no"
if has_unresolved_conflicts; then
  HAS_CONFLICTS="yes"
fi

read -r AHEAD BEHIND < <(git rev-list --left-right --count HEAD..."${TARGET_REF}")
BASE_STATE="$(branch_delta_state "${AHEAD}" "${BEHIND}")"
BRANCH_PUSHED="no"
if remote_branch_exists "${CURRENT_BRANCH}"; then
  BRANCH_PUSHED="yes"
fi

echo "|> clean: $([[ "${DIRTY_TREE}" == "no" ]] && echo "yes" || echo "no")"
echo "|> conflicts: ${HAS_CONFLICTS}"
echo "|> in-progress: ${IN_PROGRESS}"
echo "|> pushed-branch: ${BRANCH_PUSHED}"
echo "|> compared-to-${TARGET_REF}: ahead=${AHEAD} behind=${BEHIND}"
echo "|> base-state: ${BASE_STATE}"

if [[ "${MODE}" == "--status" ]]; then
  exit 0
fi

CHECK_SAFE="yes"
CHECK_ACTION="none"

if [[ "${DIRTY_TREE}" == "yes" ]]; then
  CHECK_SAFE="no"
  CHECK_ACTION="stopped"
  problem \
    "working tree has local changes" \
    "syncing should only happen after you intentionally commit, stash, or discard local work" \
    "review git status and clean the branch before syncing"
fi

if [[ "${HAS_CONFLICTS}" == "yes" ]]; then
  CHECK_SAFE="no"
  CHECK_ACTION="stopped"
  problem \
    "branch has unresolved conflicts" \
    "rebases and pulls must not continue while conflicts are unresolved" \
    "resolve or abort the current Git operation before syncing"
fi

if [[ "${IN_PROGRESS}" == "yes" ]]; then
  CHECK_SAFE="no"
  CHECK_ACTION="stopped"
  problem \
    "another Git operation is already in progress" \
    "merge, rebase, cherry-pick, revert, or bisect state must be completed first" \
    "finish or abort the in-progress operation before syncing"
fi

if [[ "${CURRENT_BRANCH}" == "${BASE_BRANCH}" ]]; then
  case "${BASE_STATE}" in
    current)
      CHECK_ACTION="none"
      ;;
    behind)
      CHECK_ACTION="fast-forward-available"
      ;;
    ahead|ahead-and-behind)
      CHECK_SAFE="no"
      CHECK_ACTION="stopped"
      problem \
        "${BASE_BRANCH} is ahead of or diverged from ${TARGET_REF}" \
        "the sync script never rewrites or auto-reconciles the base branch" \
        "inspect ${BASE_BRANCH} manually before syncing"
      ;;
  esac
else
  case "${BASE_STATE}" in
    current|ahead)
      CHECK_ACTION="none"
      ;;
    behind|ahead-and-behind)
      if [[ "${BRANCH_PUSHED}" == "yes" ]]; then
        CHECK_SAFE="no"
        CHECK_ACTION="stopped"
        problem \
          "feature branch exists on ${REMOTE}" \
          "rebasing a pushed/shared branch rewrites published history" \
          "ask for approval before rebasing this branch"
      else
        CHECK_ACTION="rebase-available"
      fi
      ;;
  esac
fi

echo "|> action: ${CHECK_ACTION}"

if [[ "${MODE}" == "--check" ]]; then
  [[ "${CHECK_SAFE}" == "yes" ]]
  exit $?
fi

if [[ "${CHECK_SAFE}" != "yes" ]]; then
  exit 1
fi

case "${CHECK_ACTION}" in
  none)
    exit 0
    ;;
  fast-forward-available)
    echo "|> run: git pull --ff-only ${REMOTE} ${BASE_BRANCH}"
    git pull --ff-only "${REMOTE}" "${BASE_BRANCH}"
    ;;
  rebase-available)
    echo "|> run: git rebase ${TARGET_REF}"
    git rebase "${TARGET_REF}"
    ;;
  *)
    problem \
      "unsupported sync action: ${CHECK_ACTION}" \
      "the script reached an unexpected action state" \
      "inspect the script before retrying"
    exit 1
    ;;
esac
