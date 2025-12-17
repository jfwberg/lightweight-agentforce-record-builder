#!/bin/zsh
# Minimal zsh script to create and manage the managed package. Keep it simple.

set -euo pipefail

# Defaults (override via env if desired)
DEV_HUB="${DEV_HUB:-defaultDevHub}"
PACKAGE_NAME="${PACKAGE_NAME:-Lightweight - Agentforce Record Builder}"
PACKAGE_DESCRIPTION="${PACKAGE_DESCRIPTION:-A Lightweight utility to convert any Agentforce Prompt Template Output into structured Salesforce sObject records.}"
PACKAGE_TYPE="${PACKAGE_TYPE:-Managed}"
PACKAGE_PATH="${PACKAGE_PATH:-force-app/package}"
DEFINITION_FILE="${DEFINITION_FILE:-config/project-package-def.json}"
PACKAGE_ID="${PACKAGE_ID:-0HoP300000001lhKAA}"
PACKAGE_VERSION_ID="${PACKAGE_VERSION_ID:-04tP3000001cPZVIA2}"

# Run from repo root so relative paths work
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
cd "$REPO_ROOT"

# Single-line commands, no extra output
#sf package create --name "${PACKAGE_NAME}" --description "${PACKAGE_DESCRIPTION}" --package-type "${PACKAGE_TYPE}" --path "${PACKAGE_PATH}" --target-dev-hub "${DEV_HUB}"
sf package version create --package "${PACKAGE_NAME}" --target-dev-hub "${DEV_HUB}" --code-coverage --installation-key-bypass --wait 30 --definition-file "${DEFINITION_FILE}"

# Uncomment to delete (dangerous):
# sf package:delete -p "${PACKAGE_ID}" --target-dev-hub "${DEV_HUB}" --no-prompt
# sf package:version:delete -p "${PACKAGE_VERSION_ID}" --target-dev-hub "${DEV_HUB}" --no-prompt
#sf package:version:promote -p "${PACKAGE_VERSION_ID}" --target-dev-hub "${DEV_HUB}" --no-prompt
