REM Set the wanted dev-hub
call sf config set target-dev-hub="defaultDevHub"

REM Create a scratch org
call sf org create scratch --definition-file ../config/project-scratch-def.json --duration-days 7 --alias "larb_test" --set-default
rem call sf org create scratch --definition-file ../config/project-scratch-def.json --duration-days 7 --alias "larb_test" --set-default --no-namespace

REM Generate the password for the scratch org
call sf org generate password --target-org "larb_test"

REM Assign permission sets to the running user, this is required for deploying the prompt templates
call sf org assign permset --name "EinsteinGPTPromptTemplateManager" --target-org "larb_test"

REM Install Package - Lightweight - Apex Unit Test Util v2 (2.7)
call sf package install -p "04tP3000001adwjIAA" -w 30 --target-org "larb_test"
call sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2" --target-org "larb_test"

REM Install Package - Lightweight - Apex Trigger Util (0.1)
call sf package install -p "04tP3000001bUo9IAE" -w 30 --target-org "larb_test"
call sf org assign permset --name "Lightweight_Apex_Trigger_Util" --target-org "larb_test"

REM Install Package - Lightweight - Record Tree (0.2)
call sf package install -p "04tP3000001wItdIAE" -w 30 --target-org "larb_test"
call sf org assign permset --name "Lightweight_Record_Tree" --target-org "larb_test"

REM Install Package - Lightweight - Agentforce Record Builder (0.4)
rem call sf package install -p "04tP3000001cPZVIA2" -w 30 --target-org "larb_test"
rem call sf org assign permset --name "Lightweight_Agentforce_Record_Builder_Admin" --target-org "larb_test"
