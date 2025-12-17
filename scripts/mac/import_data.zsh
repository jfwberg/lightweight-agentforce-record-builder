#!/bin/zsh
# Simple macOS zsh script to mirror scripts/03_import_data.bat
# Runs each sf command sequentially without functions.
# Location-independent: resolves repo root relative to this script.

set -euo pipefail

# Resolve repository root (script is at repo_root/scripts/mac/import_data.zsh)
SCRIPT_DIR="$(cd -- "$(dirname -- "$0")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

# Target org alias/name (mirrors the .bat file default)
TARGET_ORG="lightweightagentforcerecordbuilder"

# NO LOOKUPS
sf data upsert bulk --sobject "agentforce1__Schema_Instruction__c"         --file "$REPO_ROOT/config-data/no-lookups/000_agentforce1__Schema_Instruction__c.csv"          --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Schema_Instruction_Version__c" --file "$REPO_ROOT/config-data/no-lookups/001_agentforce1__Schema_Instruction_Version__c.csv"  --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Schema_Mapping__c"             --file "$REPO_ROOT/config-data/no-lookups/002_agentforce1__Schema_Mapping__c.csv"              --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Schema_Mapping_Version__c"     --file "$REPO_ROOT/config-data/no-lookups/003_agentforce1__Schema_Mapping_Version__c.csv"      --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Mapped_sObject__c"             --file "$REPO_ROOT/config-data/no-lookups/004_agentforce1__Mapped_sObject__c.csv"              --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Mapped_sObject_Field__c"       --file "$REPO_ROOT/config-data/no-lookups/005_agentforce1__Mapped_sObject_Field__c.csv"        --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"

# WITH LOOKUPS TO FIX (SELF) LOOKUP FIELD
sf data upsert bulk --sobject "agentforce1__Schema_Instruction__c"         --file "$REPO_ROOT/config-data/000_agentforce1__Schema_Instruction__c.csv"          --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Schema_Instruction_Version__c" --file "$REPO_ROOT/config-data/001_agentforce1__Schema_Instruction_Version__c.csv"  --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Schema_Mapping__c"             --file "$REPO_ROOT/config-data/002_agentforce1__Schema_Mapping__c.csv"              --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Schema_Mapping_Version__c"     --file "$REPO_ROOT/config-data/003_agentforce1__Schema_Mapping_Version__c.csv"      --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Mapped_sObject__c"             --file "$REPO_ROOT/config-data/004_agentforce1__Mapped_sObject__c.csv"              --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"
sf data upsert bulk --sobject "agentforce1__Mapped_sObject_Field__c"       --file "$REPO_ROOT/config-data/005_agentforce1__Mapped_sObject_Field__c.csv"        --external-id "agentforce1__External_Id__c" --wait 60 --target-org "$TARGET_ORG" --line-ending "LF"

echo "Data import upserts completed successfully to org: $TARGET_ORG"
