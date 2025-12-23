#!/usr/bin/env bash
set -euo pipefail
# manage.sh 所在目录（一般是 .../Docker）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# 项目根目录（上一级）
IMAGE_NAME="vs3"
PROJECT_NAME="vs3"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE="${IMAGE:-${IMAGE_NAME}:latest}"
# 用 docker-compose 驱动
case "${1:-}" in
  build)   docker build -t ${PROJECT_NAME}:latest \
            -f "${SCRIPT_DIR}/Dockerfile" \
            -t "${IMAGE}" \
            "${PROJECT_ROOT}"
            ;;
  irm)     docker image rm -f ${IMAGE_NAME:-"${PROJECT_NAME}:latest"} ;;
  up)      docker compose \
            -f "${SCRIPT_DIR}/docker-compose.yml" \
            --env-file "${SCRIPT_DIR}/.env" \
            up -d
            ;;
  down)    docker compose \
            -f "${SCRIPT_DIR}/docker-compose.yml" \
            --env-file "${SCRIPT_DIR}/.env" \
            down
            ;;
  restart) docker compose \
            -f "${SCRIPT_DIR}/docker-compose.yml" \
            --env-file "${SCRIPT_DIR}/.env" \
            down && \
            docker compose \
            -f "${SCRIPT_DIR}/docker-compose.yml" \
            --env-file "${SCRIPT_DIR}/.env" \
            up -d
            ;;
  attach)  docker exec -it ${CONTAINER_NAME:-gdino-dev} /bin/bash ;;
  logs)    docker compose \
            -f "${SCRIPT_DIR}/docker-compose.yml" \
            --env-file "${SCRIPT_DIR}/.env" \
            logs -f
            ;;
  *)
    echo "Usage: $0 {build|irm|up|down|restart|attach|logs}"
    exit 1
    ;;
esac
