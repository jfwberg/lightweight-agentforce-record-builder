call sf project deploy start --source-dir ../examples/force-app
call sf org assign permset --name "Lightweight_Agentforce_Record_Builder_Examples"
call 05_import_example_data.bat