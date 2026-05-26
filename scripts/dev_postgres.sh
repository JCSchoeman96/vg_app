#!/usr/bin/env bash
set -euo pipefail

readonly PROJECT_NAME="vg_app"
readonly CONTAINER_NAME="${VG_APP_POSTGRES_CONTAINER:-vg_app-postgres-dev}"
readonly VOLUME_NAME="${VG_APP_POSTGRES_VOLUME:-vg_app-postgres-dev-data}"
readonly IMAGE_NAME="${VG_APP_POSTGRES_IMAGE:-postgres:16-alpine}"
readonly POSTGRES_USER_VALUE="${VG_APP_POSTGRES_USER:-postgres}"
readonly POSTGRES_PASSWORD_VALUE="${VG_APP_POSTGRES_PASSWORD:-postgres}"
readonly POSTGRES_DB_VALUE="${VG_APP_POSTGRES_DB:-vg_app_dev}"
readonly POSTGRES_HOST_PORT="${VG_APP_POSTGRES_HOST_PORT:-5433}"
readonly POSTGRES_CONTAINER_PORT="5432"
readonly PORT_MAPPING="${POSTGRES_HOST_PORT}:${POSTGRES_CONTAINER_PORT}"

usage() {
  cat <<USAGE
Usage: scripts/dev_postgres.sh {start|stop|reset|status|logs|psql}

Environment overrides:
  VG_APP_POSTGRES_CONTAINER     default: vg_app-postgres-dev
  VG_APP_POSTGRES_VOLUME        default: vg_app-postgres-dev-data
  VG_APP_POSTGRES_IMAGE         default: postgres:16-alpine
  VG_APP_POSTGRES_USER          default: postgres
  VG_APP_POSTGRES_PASSWORD      default: postgres
  VG_APP_POSTGRES_DB            default: vg_app_dev
  VG_APP_POSTGRES_HOST_PORT     default: 5433

Reset safety:
  scripts/dev_postgres.sh reset --yes
USAGE
}

problem() {
  echo "Problem: $1" >&2
  echo "Fix: $2" >&2
}

container_exists() {
  docker container inspect "${CONTAINER_NAME}" >/dev/null 2>&1
}

container_running() {
  [[ "$(docker inspect -f '{{.State.Running}}' "${CONTAINER_NAME}" 2>/dev/null || true)" == "true" ]]
}

port_in_use() {
  docker ps --format '{{.Ports}}' | grep -qE "(^|,| )0\.0\.0\.0:${POSTGRES_HOST_PORT}->|(^|,| )127\.0\.0\.1:${POSTGRES_HOST_PORT}->|:${POSTGRES_HOST_PORT}->" || \
    (command -v lsof >/dev/null 2>&1 && lsof -iTCP:"${POSTGRES_HOST_PORT}" -sTCP:LISTEN >/dev/null 2>&1)
}

print_connection() {
  echo "|> container: ${CONTAINER_NAME}"
  echo "|> volume: ${VOLUME_NAME}"
  echo "|> image: ${IMAGE_NAME}"
  echo "|> host-port: ${POSTGRES_HOST_PORT}"
  echo "|> database: ${POSTGRES_DB_VALUE}"
  echo "|> user: ${POSTGRES_USER_VALUE}"
  echo "|> url: postgres://${POSTGRES_USER_VALUE}:${POSTGRES_PASSWORD_VALUE}@localhost:${POSTGRES_HOST_PORT}/${POSTGRES_DB_VALUE}"
}

wait_for_ready() {
  local attempts="${VG_APP_POSTGRES_READY_ATTEMPTS:-30}"

  for _ in $(seq 1 "${attempts}"); do
    if docker exec "${CONTAINER_NAME}" pg_isready -U "${POSTGRES_USER_VALUE}" -d "${POSTGRES_DB_VALUE}" >/dev/null 2>&1; then
      echo "${PROJECT_NAME} Dev Postgres is ready."
      print_connection
      return 0
    fi

    sleep 1
  done

  problem "Dev Postgres did not become ready within ${attempts}s" "inspect logs with scripts/dev_postgres.sh logs"
  return 1
}

start_container() {
  if container_running; then
    echo "${PROJECT_NAME} Dev Postgres already running."
    wait_for_ready
    return 0
  fi

  if container_exists; then
    docker start "${CONTAINER_NAME}" >/dev/null
    echo "Started existing ${PROJECT_NAME} Dev Postgres container."
    wait_for_ready
    return 0
  fi

  if port_in_use; then
    problem \
      "host port ${POSTGRES_HOST_PORT} appears to be in use" \
      "set VG_APP_POSTGRES_HOST_PORT to another port, for example 5434"
    exit 1
  fi

  docker run -d \
    --name "${CONTAINER_NAME}" \
    --label "project=${PROJECT_NAME}" \
    --label "role=dev-postgres" \
    -e POSTGRES_USER="${POSTGRES_USER_VALUE}" \
    -e POSTGRES_PASSWORD="${POSTGRES_PASSWORD_VALUE}" \
    -e POSTGRES_DB="${POSTGRES_DB_VALUE}" \
    -p "${PORT_MAPPING}" \
    -v "${VOLUME_NAME}:/var/lib/postgresql/data" \
    "${IMAGE_NAME}" >/dev/null

  echo "Started new ${PROJECT_NAME} Dev Postgres container."
  wait_for_ready
}

stop_container() {
  if ! container_exists; then
    echo "${PROJECT_NAME} Dev Postgres container does not exist."
    return 0
  fi

  docker rm -f "${CONTAINER_NAME}" >/dev/null
  echo "Stopped and removed ${PROJECT_NAME} Dev Postgres container."
}

reset_container() {
  local confirm="${1:-}"

  if [[ "${confirm}" != "--yes" && "${VG_APP_POSTGRES_RESET:-}" != "yes" ]]; then
    problem \
      "reset requires explicit confirmation" \
      "run scripts/dev_postgres.sh reset --yes or set VG_APP_POSTGRES_RESET=yes"
    exit 2
  fi

  if container_exists; then
    docker rm -f "${CONTAINER_NAME}" >/dev/null
  fi

  docker volume rm -f "${VOLUME_NAME}" >/dev/null 2>&1 || true
  echo "Reset ${PROJECT_NAME} Dev Postgres container and deleted volume."
}

status_container() {
  echo "${PROJECT_NAME} Dev Postgres status"
  print_connection

  docker ps -a \
    --filter "name=^/${CONTAINER_NAME}$" \
    --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

  if docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1; then
    echo "|> volume-status: present"
  else
    echo "|> volume-status: missing"
  fi
}

logs_container() {
  if ! container_exists; then
    problem "Dev Postgres container does not exist" "run scripts/dev_postgres.sh start first"
    exit 1
  fi

  docker logs -f "${CONTAINER_NAME}"
}

psql_container() {
  if ! container_running; then
    problem "Dev Postgres container is not running" "run scripts/dev_postgres.sh start first"
    exit 1
  fi

  docker exec -it "${CONTAINER_NAME}" psql -U "${POSTGRES_USER_VALUE}" -d "${POSTGRES_DB_VALUE}"
}

main() {
  local command="${1:-}"
  shift || true

  case "${command}" in
    start)
      start_container "$@"
      ;;
    stop)
      stop_container "$@"
      ;;
    reset)
      reset_container "$@"
      ;;
    status)
      status_container "$@"
      ;;
    logs)
      logs_container "$@"
      ;;
    psql)
      psql_container "$@"
      ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
