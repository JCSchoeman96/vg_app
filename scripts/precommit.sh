#!/usr/bin/env bash
set -euo pipefail

# vg_app full local gate.
# Agents SHALL NOT weaken this script to make tests green.
# If a check fails, fix the code or update the planning contract first.

MIX_CMD="${MIX_CMD:-mise exec -- mix}"
ASH_CODEGEN_CHECK_CMD="${ASH_CODEGEN_CHECK_CMD:-mise exec -- mix ash.codegen --check}"
SOBELOW_CMD="${SOBELOW_CMD:-mise exec -- mix sobelow --config}"

run() {
  local label="$1"
  shift

  echo ""
  echo "=== ${label} ==="
  echo "|> run: $*"
  "$@"
}

run_shell() {
  local label="$1"
  local command="$2"

  echo ""
  echo "=== ${label} ==="
  echo "|> run: ${command}"
  bash -lc "${command}"
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Problem: precommit must run inside the vg_app Git repository"
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "${repo_root}"

echo "vg_app precommit"
echo "|> repo: ${repo_root}"
echo "|> principle: RED tests first, GREEN tests only by correct implementation"

run "Format check" ${MIX_CMD} format --check-formatted
run "Compile with warnings as errors" ${MIX_CMD} compile --warnings-as-errors
run_shell "Ash codegen drift check" "${ASH_CODEGEN_CHECK_CMD}"
run "Credo strict" ${MIX_CMD} credo --strict
run_shell "Sobelow security scan" "${SOBELOW_CMD}"
run "Test suite" env MIX_ENV=test ${MIX_CMD} test
run "Dialyzer" ${MIX_CMD} dialyzer

echo ""
echo "|> precommit: ok"
