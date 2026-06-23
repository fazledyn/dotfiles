#!/usr/bin/env bash
#
# docker-cleanup.sh - Reclaim disk space used by Docker.
#
# By default this prunes only dangling/unused resources. Pass --all to also
# remove unused images and volumes (more aggressive).

set -euo pipefail

# Make sure Docker is installed and the daemon is reachable.
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed." >&2
  exit 1
fi
if ! docker info >/dev/null 2>&1; then
  echo "Cannot talk to the Docker daemon. Is it running?" >&2
  exit 1
fi

AGGRESSIVE=false
case "${1:-}" in
  "")     ;;
  --all)  AGGRESSIVE=true ;;
  *)
    echo "Unknown option: $1" >&2
    echo "Usage: $0 [--all]" >&2
    exit 1
    ;;
esac

echo ">> Disk usage before cleanup:"
docker system df

echo ">> Removing stopped containers..."
docker container prune -f

echo ">> Removing unused networks..."
docker network prune -f

echo ">> Removing build cache..."
docker builder prune -f

if $AGGRESSIVE; then
  echo ">> Removing all unused images and volumes (--all)..."
  docker image prune -a -f
  docker volume prune -f
else
  echo ">> Removing dangling images..."
  docker image prune -f
  echo "   (run with --all to also remove unused images and volumes)"
fi

echo ">> Disk usage after cleanup:"
docker system df

echo ">> Done."
