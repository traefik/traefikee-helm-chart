#!/bin/bash

CT_ARGS=""
GIT_SAFE_DIR="false"

if [ "$GIT_SAFE_DIR" != "true" ]; then
    git config --global --add safe.directory /charts
fi

ct $1 --config=./.github/chart-testing.yaml --charts /charts/traefikee $2 $3 $4 $5
