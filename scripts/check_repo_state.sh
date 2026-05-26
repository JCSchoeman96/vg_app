#!/usr/bin/env bash
set -euo pipefail

MODE="${1:---status}"

if [[ "${MODE}" != "--status" && "${MODE}" != "--strict-clean" ]]; then
  echo "Usage: scripts/check_repo_state.sh [--status|--strict-clean]"
  exit 2
fi

problem() {
  echo "Problem: $1"
  echo "Why: $2"
  echo "Fix: $3"
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  problem "not inside a Git repository" "repo state cannot be inspected outside Git" "run from inside the vg_app repo"
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "${repo_root}"

current_branch="$(git branch --show-current || true)"
status_short="$(git status --short)"
status_branch="$(git status --short --branch)"

has_conflicts="no"
if [[ -n "$(git diff --name-only --diff-filter=U)" ]]; then
  has_conflicts="yes"
fi

git_dir="$(git rev-parse --git-dir)"
in_progress="no"
if [[ -f "${git_dir}/MERGE_HEAD" ]] || \
   [[ -d "${git_dir}/rebase-merge" ]] || \
   [[ -d "${git_dir}/rebase-apply" ]] || \
   [[ -f "${git_dir}/CHERRY_PICK_HEAD" ]] || \
   [[ -f "${git_dir}/REVERT_HEAD" ]] || \
   [[ -f "${git_dir}/BISECT_LOG" ]]; then
  in_progress="yes"
fi

clean="yes"
if [[ -n "${status_short}" ]]; then
  clean="no"
fi

echo "Repo state"
echo "|> repo: ${repo_root}"
echo "|> branch: ${current_branch:-detached-head}"
echo "|> clean: ${clean}"
echo "|> conflicts: ${has_conflicts}"
echo "|> in-progress: ${in_progress}"
echo "|> status:"
if [[ -n "${status_branch}" ]]; then
  echo "${status_branch}" | sed 's/^/   /'
else
  echo "   clean"
fi

echo "|> worktrees:"
git worktree list | sed 's/^/   /'

if git remote get-url origin >/dev/null 2>&1; then
  echo "|> origin: $(git remote get-url origin)"
else
  echo "|> origin: missing"
fi

if [[ "${MODE}" == "--strict-clean" ]]; then
  if [[ -z "${current_branch}" ]]; then
    problem "detached HEAD" "agents must work on named branches" "check out or create a branch before continuing"
    exit 1
  fi

  if [[ "${clean}" != "yes" ]]; then
    problem "working tree is not clean" "strict mode requires a committed/stashed/discarded tree" "review git status and commit or stash intentionally"
    exit 1
  fi

  if [[ "${has_conflicts}" == "yes" ]]; then
    problem "unresolved conflicts" "work cannot continue safely during conflicts" "resolve conflicts or abort the Git operation"
    exit 1
  fi

  if [[ "${in_progress}" == "yes" ]]; then
    problem "Git operation in progress" "merge/rebase/cherry-pick/revert/bisect must finish first" "finish or abort the operation before continuing"
    exit 1
  fi
fi
