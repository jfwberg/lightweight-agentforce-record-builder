@IsTest
private with sharing class AgentforceRecordCreatorFlowTest {
    
    // Create a test uses with the test util permission set
    private static User runAsUser = utl.Tst.createRunAsUser(
        utl.Tst.STANDARD_USER_PROFILE,
        utl.Tst.TEST_SR_NAME  
    ); 


    @IsTest
    static void runTest(){

        // Execute the flow logic and create test records
        System.runAs(runAsUser){
            // Create request
            AgentforceRecordCreatorFlow.Request request = new AgentforceRecordCreatorFlow.Request();
            request.jsonString = Util.getStaticResourceBody(Constant.VAL_APEX_UNIT_TEST_JSON);

            // Create a list of request for the flow input
            AgentforceRecordCreatorFlow.Request[] requests = new AgentforceRecordCreatorFlow.Request[]{request};
            
            // Execute the logic
            AgentforceRecordCreatorFlow.Response[] responses = AgentforceRecordCreatorFlow.run(requests);
        }

        // Assert
        Assert.areEqual(1,  [SELECT COUNT() FROM record__Upsert_Result__c],        'Expected 01 record__Upsert_Result__c record to exist.'        );
        Assert.areEqual(11, [SELECT COUNT() FROM record__Upsert_Result_Record__c], 'Expected 11 record__Upsert_Result_Record__c records to exist.');

    }


    @IsTest
    static void runExceptionTest(){

        // Variables to assert
        Exception exceptionToAssert;

        // Response to validate
        AgentforceRecordCreatorFlow.Response[] responses;

        // Execute the flow logic and create test records
        System.runAs(runAsUser){
            try{
                // Start the test
                test.startTest();

                // Method to add and remove a forced exception identifier
                utl.Tst.addForcedException(Constant.VAL_FORCED_EXCEPTION);

                // Create request
                AgentforceRecordCreatorFlow.Request request = new AgentforceRecordCreatorFlow.Request();
                request.jsonString = '{}';

                // Create a list of request for the flow input
                AgentforceRecordCreatorFlow.Request[] requests = new AgentforceRecordCreatorFlow.Request[]{request};
                
                // Execute logic
                responses = AgentforceRecordCreatorFlow.run(requests);
                
                // Stop the test
                test.stopTest();

            }catch(Exception e){
                exceptionToAssert = e;
            }
        }

        // Assert the exception
        Assert.areEqual(
            utl.Tst.getForcedExceptionMessage(),
            responses[0].errorMessage,
            'Unexpected Exception Message'
        );
    }
}