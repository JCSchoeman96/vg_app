SHELL := /usr/bin/env bash
.SHELLFLAGS := -euo pipefail -c

# -----------------------------------------------------------------------------
# vg_app repo automation
# -----------------------------------------------------------------------------
# Principle:
#   Agents SHALL use these targets instead of inventing ad-hoc commands.
#   Targets are intentionally small, composable, and safe by default.

.DEFAULT_GOAL := help

PROJECT := vg_app
MIX := mise exec -- mix

HEX_HTTP_TIMEOUT ?= 180
HEX_HTTP_CONCURRENCY ?= 1

export HEX_HTTP_TIMEOUT
export HEX_HTTP_CONCURRENCY

.PHONY: \
	help status doctor sync-check sync toolchain deps infra db db-test \
	setup ready ready-local check format format-check compile test test-watch \
	credo sobelow dialyzer ash-codegen-dev ash-codegen ash-migrate \
	precommit ci hooks pr index index-check reset-db stop-db logs-db psql-db

help:
	@echo "vg_app Makefile"
	@echo ""
	@echo "Core:"
	@echo "  make status          |> show git branch/status/worktrees"
	@echo "  make doctor          |> verify required local tools"
	@echo "  make setup           |> install toolchain, deps, hooks, infra, databases"
	@echo "  make ready           |> sync with origin/main, setup, then run ci"
	@echo "  make ready-local     |> setup and ci without git sync"
	@echo ""
	@echo "Quality:"
	@echo "  make check           |> format-check + compile + fast tests"
	@echo "  make precommit       |> full local gate used by git hooks"
	@echo "  make ci              |> full CI-equivalent local gate"
	@echo ""
	@echo "Database:"
	@echo "  make infra           |> start local Postgres container"
	@echo "  make reset-db        |> reset local Postgres volume and recreate dbs"
	@echo "  make stop-db         |> stop/remove local Postgres container"
	@echo "  make logs-db         |> follow local Postgres logs"
	@echo "  make psql-db         |> open psql in local Postgres container"
	@echo ""
	@echo "Ash:"
	@echo "  make ash-codegen-dev |> run mix ash.codegen --dev"
	@echo "  make ash-codegen NAME=meaningful_name |> create named migration/snapshots"
	@echo "  make ash-migrate     |> run mix ash.migrate"
	@echo ""
	@echo "GitHub:"
	@echo "  make pr              |> run checks, push branch, create/fetch PR with gh"

status:
	@bash scripts/check_repo_state.sh --status

doctor:
	@echo "=== 0. Checking required tools for $(PROJECT) ==="
	@command -v git >/dev/null || { echo "Missing: git"; exit 1; }
	@command -v bash >/dev/null || { echo "Missing: bash"; exit 1; }
	@command -v make >/dev/null || { echo "Missing: make"; exit 1; }
	@command -v mise >/dev/null || { echo "Missing: mise"; exit 1; }
	@command -v docker >/dev/null || { echo "Missing: docker"; exit 1; }
	@command -v gh >/dev/null || { echo "Missing: gh"; exit 1; }
	@command -v rg >/dev/null || { echo "Missing: rg / ripgrep"; exit 1; }
	@(command -v ast-grep >/dev/null || command -v sg >/dev/null) || { echo "Missing: ast-grep / sg"; exit 1; }
	@echo "|> required tools: ok"

sync-check:
	@echo ""
	@echo "=== 1. Checking Git sync safety ==="
	@bash scripts/sync_with_origin_main.sh --check

sync: sync-check
	@echo ""
	@echo "=== 2. Syncing with origin/main ==="
	@bash scripts/sync_with_origin_main.sh --sync

toolchain:
	@echo ""
	@echo "=== 3. Installing pinned toolchain ==="
	@mise install
	@echo ""
	@echo "=== 4. Verifying BEAM toolchain ==="
	@mise exec -- elixir --version
	@mise exec -- erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell

deps:
	@echo ""
	@echo "=== 5. Installing Hex/Rebar ==="
	@$(MIX) local.hex --force
	@$(MIX) local.rebar --force
	@echo ""
	@echo "=== 6. Fetching and compiling Elixir dependencies ==="
	@$(MIX) deps.get
	@$(MIX) deps.compile
	@MIX_ENV=test $(MIX) deps.compile

hooks:
	@echo ""
	@echo "=== 7. Installing repo-local Git hooks ==="
	@bash scripts/install_git_hooks.sh

infra:
	@echo ""
	@echo "=== 8. Starting $(PROJECT) Dev Postgres ==="
	@bash scripts/dev_postgres.sh start
	@echo ""
	@echo "=== 9. Checking $(PROJECT) Dev Postgres status ==="
	@bash scripts/dev_postgres.sh status

db:
	@echo ""
	@echo "=== 10. Preparing development database ==="
	@$(MIX) ecto.create
	@$(MIX) ecto.migrate

db-test:
	@echo ""
	@echo "=== 11. Preparing test database ==="
	@MIX_ENV=test $(MIX) ecto.create
	@MIX_ENV=test $(MIX) ecto.migrate

setup: doctor toolchain deps hooks infra db db-test
	@echo ""
	@echo "🚀 $(PROJECT) local setup complete."

ready: status sync setup ci
	@echo ""
	@echo "🚀 $(PROJECT) workspace synced, validated, and ready for agent work."

ready-local: status setup ci
	@echo ""
	@echo "🚀 $(PROJECT) local workspace validated. No git sync was performed."

format:
	@$(MIX) format

format-check:
	@$(MIX) format --check-formatted

compile:
	@$(MIX) compile --warnings-as-errors

# Fast developer confidence gate. Full gate is `make precommit`.
check: format-check compile test
	@echo "|> check: ok"

test:
	@MIX_ENV=test $(MIX) test

test-watch:
	@MIX_ENV=test $(MIX) test.watch

credo:
	@$(MIX) credo --strict

sobelow:
	@$(MIX) sobelow --config

dialyzer:
	@$(MIX) dialyzer

ash-codegen-dev:
	@$(MIX) ash.codegen --dev

ash-codegen:
	@if [[ -z "$${NAME:-}" ]]; then \
		echo "Problem: missing NAME for named Ash codegen"; \
		echo "Usage: make ash-codegen NAME=add_membership_product"; \
		exit 2; \
	fi
	@$(MIX) ash.codegen "$${NAME}"

ash-migrate:
	@$(MIX) ash.migrate

precommit:
	@bash scripts/precommit.sh

ci: precommit
	@echo "|> ci: ok"

index:
	@$(MIX) project.index

index-check:
	@$(MIX) project.index --check

reset-db:
	@echo ""
	@echo "=== Resetting $(PROJECT) Dev Postgres ==="
	@bash scripts/dev_postgres.sh reset --yes
	@bash scripts/dev_postgres.sh start
	@$(MAKE) db
	@$(MAKE) db-test

stop-db:
	@echo ""
	@echo "=== Stopping $(PROJECT) Dev Postgres ==="
	@bash scripts/dev_postgres.sh stop

logs-db:
	@bash scripts/dev_postgres.sh logs

psql-db:
	@bash scripts/dev_postgres.sh psql

pr:
	@bash scripts/create_pr.sh
