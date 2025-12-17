#!/bin/zsh
# Simple macOS zsh script to mirror scripts/00_dependencies.bat
# Runs each sf command sequentially without fancy functions.
# Location-independent: resolves repo root relative to this script.

set -euo pipefail

# Resolve repository root (script is at repo_root/scripts/mac/install.zsh)
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

# Set target org alias (override by exporting TARGET_ORG before running)
TARGET_ORG="${TARGET_ORG:-lightweightagentforcerecordbuilder}"

# Set the wanted dev-hub
sf config set target-dev-hub="defaultDevHub"

# Create a scratch org using TARGET_ORG alias
sf org create scratch --definition-file "$REPO_ROOT/config/project-scratch-def.json" --duration-days 7 --wait 30 --alias "${TARGET_ORG}" --set-default --no-ancestors --no-namespace

# Generate the password for the scratch org
sf org generate password --target-org "${TARGET_ORG}"

# Assign permission sets to the running user, required for deploying the prompt templates
sf org assign permset --name "EinsteinGPTPromptTemplateManager" --target-org "${TARGET_ORG}"

# Install Package - Lightweight - Apex Unit Test Util v2 (2.7)
sf package install -p "04tP3000001adwjIAA" -w 30 --target-org "${TARGET_ORG}"
sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2" --target-org "${TARGET_ORG}"

# Install Package - Lightweight - Apex Trigger Util (0.1)
sf package install -p "04tP3000001bUo9IAE" -w 30 --target-org "${TARGET_ORG}"
sf org assign permset --name "Lightweight_Apex_Trigger_Util" --target-org "${TARGET_ORG}"

# Install Package - Lightweight - Record Tree (0.1)
sf package install -p "04tP3000001bWRl04tP3000001cPZVIA2IAM" -w 30 --target-org "${TARGET_ORG}"
sf org assign permset --name "Lightweight_Record_Tree" --target-org "${TARGET_ORG}"

# Install Package - Lightweight - Agentforce Record Builder (0.3)
sf package install -p "04tP3000001cPZVIA2" -w 30 --target-org "${TARGET_ORG}"
sf org assign permset --name "Lightweight_Agentforce_Record_Builder_Admin" --target-org "${TARGET_ORG}"

# Open the target org
sf org open --target-org "${TARGET_ORG}"

# Run the data import script from the correct path (scripts/mac)
zsh "$SCRIPT_DIR/import_data.zsh"

echo "All steps completed successfully."
