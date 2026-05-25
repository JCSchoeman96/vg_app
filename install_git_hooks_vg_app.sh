#!/usr/bin/env bash
set -euo pipefail

problem() {
  echo "Problem: $1"
  echo "Fix: $2"
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  problem "not inside a Git repository" "run this script from inside the vg_app repo"
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "${repo_root}"

if [[ ! -d ".githooks" ]]; then
  problem "missing .githooks directory" "create .githooks/pre-commit before installing hooks"
  exit 1
fi

if [[ ! -f ".githooks/pre-commit" ]]; then
  problem "missing .githooks/pre-commit" "add the pre-commit hook file before installing hooks"
  exit 1
fi

chmod +x .githooks/pre-commit

git config core.hooksPath .githooks

echo "Git hooks"
echo "|> repo: ${repo_root}"
echo "|> hooksPath: .githooks"
echo "|> pre-commit: executable"
echo "|> action: configured"
