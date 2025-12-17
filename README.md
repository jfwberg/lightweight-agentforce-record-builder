# Lightweight - Agentforce Record Builder
A Lightweight utility to convert any Agentforce Prompt Template Output into structured Salesforce sObject records.

## Background
Prompt tempates are (IMHO) the most powerful feature of the Salesforce platform. Yet there is no easy way to convert Prompt Template outputs into Salesforce records.
This utility allows you to create a Salesforce Record Tree with linked Lookup fields (including) both forward and backwards lookups

## Blog
For detailed design decisions and instructions please read my blog posts below.
- [Coming soon](https://)
- [Coming soon](https://)

## Pre-Install
Make sure that the installing user has the **`EinsteinGPTPromptTemplateManager`** permission set assigned *BEFORE* you run the install. This is required in order to deploy the included prompt templates. If you run into any flow related errors during the package install this is most likely the reason.

You can do it manual through setup or use the CLI using `sf org assign permset --name "EinsteinGPTPromptTemplateManager"`

## Package Info
|   |   |   |   |
|---|---|---|---|
|Package Name|**[Lightweight - Agentforce Record Builder](https://github.com/jfwberg/lightweight-agentforce-record-builder)**||
|Package Version|0.3.0-1||
|Last updated date|Dec 17, 2025||
|Managed Package | <ul><li> `sf package install --wait 30 --security-type AllUsers --package 04tP3000001cNXhIAM`</li><li>`/packaging/installPackage.apexp?p0=04tP3000001cNXhIAM`</li></ul> | [Install in Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tP3000001cNXhIAM) | [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001cNXhIAM)|

## Dependencies
The following packages need to be installed before installing the main package in the order as below. Note that for this package only *managed packages* are supported.
|   |   |   |   |
|---|---|---|---|
|Package Name|**[Lightweight - Apex Unit Test Util v2](https://github.com/jfwberg/lightweight-apex-unit-test-util-v2)**||
|Package Version|2.7.0-1||
|Last updated date|Dec 5, 2025||
|Managed Package | <ul><li> `sf package install --wait 30 --security-type AllUsers --package 04tP3000001adwjIAA`</li><li>`/packaging/installPackage.apexp?p0=04tP3000001adwjIAA`</li></ul> | [Install in Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tP3000001adwjIAA) | [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001adwjIAA)|

|   |   |   |   |
|---|---|---|---|
|Package Name|**[Lightweight - Apex Trigger Util](https://github.com/jfwberg/lightweight-apex-trigger-util)**||
|Package Version|0.1.0-3||
|Last updated date|Dec 09, 2025||
|Managed Package | <ul><li> `sf package install --wait 30 --security-type AllUsers --package 04tP3000001bUo9IAE`</li><li>`/packaging/installPackage.apexp?p0=04tP3000001bUo9IAE`</li></ul> | [Install in Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tP3000001bUo9IAE) | [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001bUo9IAE)|

|   |   |   |   |
|---|---|---|---|
|Package Name|**[Lightweight - Record Tree](https://github.com/jfwberg/lightweight-record-tree)**||
|Package Version|0.1.0-3||
|Last updated date|Dec 09, 2025||
|Managed Package | <ul><li> `sf package install --wait 30 --security-type AllUsers --package 04tP3000001bWRlIAM`</li><li>`/packaging/installPackage.apexp?p0=04tP3000001bWRlIAM`</li></ul> | [Install in Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tP3000001bWRlIAM) | [Install in Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?mgd=true&p0=04tP3000001bWRlIAM)|

## Salesforce CLI - Install Script
You can install the dependencies using this batch script as well (Windows Command Prompt Version, but update accordingly)
```batch
REM !! ASSIGN THIS ONE BEFORE INSTALLING DEPENDENCIES !!
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
call sf package install -p "04tP3000001cNXhIAM" -w 30 --target-org "lightweightagentforcerecordbuilder"
call sf org assign permset --name "Lightweight_Agentforce_Record_Builder_Admin" --target-org "lightweightagentforcerecordbuilder"
```

## Post Install
**Assign Permission Sets**

You need to assign the the `Lightweight - Agentforce Record Builder - Admin` permission set to the admin users in order to use the application. 
The user who installs the package automatically added during the post install script.
`sf org assign permset --name Lightweight_Agentforce_Record_Builder_Admin`

## Load Sample Data (Optional)
Optionally you can load the `Test Data Generator` as a good example to get you started to play around. Not you will require Accounts, Contacts and Cases to be availible in your org.
Execute the import commands in the `03_import_data.bat` file inside the `scripts/` folder. Update the paths and org aliasses accordingly


# Notes
This is currently a first version. There are lots of improvents and optimization to aapply. But it is a stable functionallity that properly structured.
New version are coming in due time so bear with me and don't judge the code too much :)