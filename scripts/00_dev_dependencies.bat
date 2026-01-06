REM Assign permission sets to the running user
call sf org assign permset --name "EinsteinGPTPromptTemplateManager"

REM Install Package - Lightweight - Apex Unit Test Util v2 (2.7)
call sf package install -p "04tP3000001adwjIAA" -w 30
call sf org assign permset --name "Lightweight_Apex_Unit_Test_Util_v2"

REM Install Package - Lightweight - Apex Trigger Util (0.1)
call sf package install -p "04tP3000001bUo9IAE" -w 30
call sf org assign permset --name "Lightweight_Apex_Trigger_Util"

REM Install Package - Lightweight - Record Tree (0.1)
call sf package install -p "04tP3000001bWRlIAM" -w 30
call sf org assign permset --name "Lightweight_Record_Tree"
