REM *****************************
REM        PACKAGE CREATION   
REM *****************************

REM Package Create Config
SET devHub=defaultDevHub
SET packageName=Lightweight - Agentforce Record Builder
SET packageDescription=A Lightweight utility to convert any Agentforce Prompt Template Output into structured Salesforce sObject records.
SET packageType=Managed
SET packagePath=force-app/package
SET definitionFile=config/project-package-def.json

REM Package Config
SET packageId=0HoP300000001lhKAA
SET packageVersionId=04tP3000001cPZVIA2

REM Create package
sf package create --name "%packageName%" --description "%packageDescription%" --package-type "%packageType%" --path "%packagePath%" --target-dev-hub %devHub%

REM Create package version
sf package version create --package "%packageName%"  --target-dev-hub "%devHub%" --code-coverage --installation-key-bypass --wait 30 --definition-file "%definitionFile%"

REM Delete package
sf package:delete -p %packageId% --target-dev-hub %devHub% --no-prompt

REM Delete package version
sf package:version:delete -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM Promote package version
sf package:version:promote -p %packageVersionId% --target-dev-hub %devHub% --no-prompt

REM Installation URL
rem /packaging/installPackage.apexp?p0=04tP3000001cNXhIAM
rem sf package install -p "04tP3000001cNXhIAM" -w 30 --target-org "PCK_TST"
