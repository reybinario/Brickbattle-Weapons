#!/bin/sh
# Builds the test place with Rojo, uploads it to our throwaway test place on
# Roblox, and runs the given Luau task inside a real server instance via the
# Open Cloud Luau Execution API. Exits non-zero when the task fails, which
# fails the CI check.
#
# Usage: sh scripts/shell/run-engine-tests.sh <project.json> <task script>
# (Invoked with sh because the GitHub web editor cannot set +x on files.)
set -e

rojo build "$1" --output dist.rbxl
python3 scripts/python/upload_and_run_task.py dist.rbxl "$2"
rm dist.rbxl
