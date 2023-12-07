#!/bin/bash
set -e
STATEMENTS_DIR="${PWD}"
cd "$(dirname "${BASH_SOURCE[0]}")"
docker build \
  -t statements \
  --platform linux/amd64 \
  .
docker run --rm -it \
  --platform linux/amd64 \
  -p "57473:57473" \
  -v "$STATEMENTS_DIR:/wd" \
  statements
