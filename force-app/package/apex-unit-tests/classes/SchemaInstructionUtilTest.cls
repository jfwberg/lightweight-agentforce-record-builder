@IsTest
private with sharing class SchemaInstructionUtilTest {
    
    // Create a test uses with the test util permission set
    private static User runAsUser = utl.Tst.createRunAsUser(
        utl.Tst.STANDARD_USER_PROFILE,
        Constant.VAL_PERMISSION_SET_NAME  
    ); 


    @IsTest
    static void insertDefaultInstructionsTest(){
        
        // Execute the flow logic and create test records
        System.runAs(runAsUser){
            SchemaInstructionUtil.insertDefaultInstructions();
        }

        Assert.areEqual(1, [SELECT COUNT() FROM Schema_Instruction__c],         'Expected 01 Instruction__c record to exist.'         );
        Assert.areEqual(1, [SELECT COUNT() FROM Schema_Instruction_Version__c], 'Expected 01 Instruction_Version__c records to exist.');
    }
}