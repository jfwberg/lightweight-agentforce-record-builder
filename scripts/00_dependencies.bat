REM sf config set target-dev-hub=defaultDevHub

REM sf org generate password --target-org lightweightagentforcerecordbuilder

REM Assign permission sets to the running user
call sf org assign permset --name "EinsteinGPTPromptTemplateManager" --target-org "lightweightagentforcerecordbuilder"

REM Install Package - Lightweight - Apex Unit Test Util v2 (2.7)
call sf package install -p "04tP3000001adwjIAA" -w 30 --target-org "lightweightagentforcerecordbuilder"
call sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2" --target-org "lightweightagentforcerecordbuilder"

REM Install Package - Lightweight - Apex Trigger Util (0.1)
call sf package install -p "04tP3000001bUo9IAE" -w 30 --target-org "lightweightagentforcerecordbuilder"
call sf org assign permset --name "Lightweight_Apex_Trigger_Util" --target-org "lightweightagentforcerecordbuilder"

REM Install Package - Lightweight - Record Tree (0.1)
call sf package install -p "04tP3000001bWRlIAM" -w 30 --target-org "lightweightagentforcerecordbuilder"
call sf org assign permset --name "Lightweight_Record_Tree" --target-org "lightweightagentforcerecordbuilder"

REM Install Package - Lightweight - Agentforce Record Builder (0.3)
call sf package install -p "04tP3000001cNXhIAM" -w 30 --target-org "EricDemo"
call sf org assign permset --name "Lightweight_Agentforce_Record_Builder_Admin" --target-org "lightweightagentforcerecordbuilder"
