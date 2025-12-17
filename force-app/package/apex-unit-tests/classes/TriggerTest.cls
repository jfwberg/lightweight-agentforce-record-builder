@IsTest
private with sharing class TriggerTest {


    @IsTest
    static void triggerTest(){

        Schema_Instruction__c si = new Schema_Instruction__c();
        si.Is_Default__c        = true;
        si.Name                 = Constant.DEFAULT_INSTRUCTION_NAME;
        si.Ignore_Triggers__c   = true;
        insert si;

        si.Ignore_Triggers__c   = true;
        update si;

        try{
            // Should not be possble
            delete si;

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(System.DmlException e){
            Assert.areEqual(
                true,
                e.getMessage().contains('The default record cannot be deleted.'),
                'Unexpected Exception Message'
            );
        }


        Schema_Instruction_Version__c siv = new Schema_Instruction_Version__c();
        siv.Schema_Instruction__c = si.Id;
        siv.Prompt_Output__c = 'ABC';
        siv.Prompt_Output_Hash__c = Util.sha1('ABC');
        siv.Prompt_Output_Length__c = 3;
        insert siv;

        si.Ignore_Triggers__c   = true;
        update siv;

        // Create a schema
        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = si.Id;
        insert sm;
        update sm;


        
        // Create the new mapping
        Schema_Mapping_Version__c smv = new Schema_Mapping_Version__c(
            Is_Latest__c            = true,
            Schema_Mapping__c       = sm.Id,
            Version_Number__c       = 1,
            Prompt_Output__c        = 'ABC',
            Prompt_Output_Length__c = 3,
            Prompt_Output_Hash__c   = Util.sha1('ABC')
        );
        insert smv;
        update smv;



        Mapped_sObject__c parentMso = new Mapped_sObject__c();
        parentMso.Name              = 'utl__Parent_Test_sObject__c';
        parentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        parentMso.Schema_Mapping__c = sm.Id;
        insert parentMso;
        update parentMso;

        Mapped_sObject_Field__c parentMsof = new Mapped_sObject_Field__c();
        parentMsof.Name              = 'Name';
        parentMsof.Mapped_sObject__c = parentMso.Id;
        insert parentMsof;
        update parentMsof;

        Mapped_sObject__c childMso = new Mapped_sObject__c();
        childMso.Name                   = 'utl__Child_Test_sObject__c';
        childMso.sObjectType__c         = 'utl__Child_Test_sObject__c';
        childMso.Parent_sObjectType__c  = 'utl__Parent_Test_sObject__c';
        childMso.Relationship_Field__c  = 'utl__Parent_Test_sObject__c';
        childMso.Schema_Mapping__c      = sm.Id;
        childMso.Parent_sObject__c      = parentMso.Id;
        insert childMso;
        update childMso;

        // Add field
        Mapped_sObject_Field__c childMsof = new Mapped_sObject_Field__c();
        childMsof.Name              = 'Name';
        childMsof.Mapped_sObject__c = childMso.Id;
        insert childMsof;
        update childMsof;

        // Test deletes
        delete childMsof;
        delete childMso;
    }


    @IsTest
    static void testProblemChild(){

        Schema_Instruction__c si = new Schema_Instruction__c();
        si.Is_Default__c        = true;
        si.Name                 = Constant.DEFAULT_INSTRUCTION_NAME;
        insert si;

        Schema_Mapping__c sm = new Schema_Mapping__c();
        sm.Name = 'Test Schema';
        sm.Schema_Instruction__c = si.Id;
        insert sm;
        
        Mapped_sObject__c parentMso = new Mapped_sObject__c();
        parentMso.Name              = 'utl__Parent_Test_sObject__c';
        parentMso.sObjectType__c    = 'utl__Parent_Test_sObject__c';
        parentMso.Schema_Mapping__c = sm.Id;
        insert parentMso;

        try{
            Mapped_sObject__c problemChildMso = new Mapped_sObject__c();
            problemChildMso.Parent_sObject__c      = parentMso.Id;
            problemChildMso.Name                   = 'Invalid';
            problemChildMso.sObjectType__c         = 'Invalid';

            // Execute test
            insert problemChildMso;

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(System.DmlException e){
            Assert.areEqual(
                true,
                e.getMessage().contains('No sObject with the name: "Invalid" found in the metadata.'),
                'Unexpected Exception Message: ' + e.getMessage() + e.getStackTraceString()
            );
        }

        
        try{
            Mapped_sObject__c problemChildMso = new Mapped_sObject__c();
            problemChildMso.Parent_sObject__c      = parentMso.Id;
            problemChildMso.Name                   = 'utl__Child_Test_sObject__c';
            problemChildMso.sObjectType__c         = 'utl__Child_Test_sObject__c';

            // Execute test
            insert problemChildMso;

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(System.DmlException e){
            Assert.areEqual(
                true,
                e.getMessage().contains('The Parent sObjectType field cannot be blank if a Parent Mapped sObject is specified.'),
                'Unexpected Exception Message: ' + e.getMessage() + e.getStackTraceString()
            );
        }


        try{

            Mapped_sObject__c problemChildMso = new Mapped_sObject__c();
            problemChildMso.Parent_sObject__c      = parentMso.Id;
            problemChildMso.Name                   = 'utl__Child_Test_sObject__c';
            problemChildMso.sObjectType__c         = 'utl__Child_Test_sObject__c';
            problemChildMso.Parent_sObjectType__c  = 'utl__Parent_Test_sObject__c';

            // Execute test
            insert problemChildMso;

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(System.DmlException e){
            Assert.areEqual(
                true,
                e.getMessage().contains('The (Parent) Relationship Field cannot be blank if a Parent Mapped sObject is specified.'),
                'Unexpected Exception Message: ' + e.getMessage() + e.getStackTraceString()
            );
        }


        try{
            Mapped_sObject__c problemChildMso = new Mapped_sObject__c();
            problemChildMso.Parent_sObject__c      = parentMso.Id;
            problemChildMso.Name                   = 'utl__Child_Test_sObject__c';
            problemChildMso.sObjectType__c         = 'utl__Child_Test_sObject__c';
            problemChildMso.Parent_sObjectType__c  = 'Invalid';
            problemChildMso.Relationship_Field__c  = 'utl__Parent_Test_sObject__c';

            // Execute test
            insert problemChildMso;

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(System.DmlException e){
            Assert.areEqual(
                true,
                e.getMessage().contains('No sObject with the name: "Invalid" found in the metadata.'),
                'Unexpected Exception Message: ' + e.getMessage() + e.getStackTraceString()
            );
        }


        try{
            Mapped_sObject__c problemChildMso = new Mapped_sObject__c();
            problemChildMso.Parent_sObject__c      = parentMso.Id;
            problemChildMso.Name                   = 'Organization';
            problemChildMso.sObjectType__c         = 'Organization';
            problemChildMso.Parent_sObjectType__c  = 'utl__Parent_Test_sObject__c';
            problemChildMso.Relationship_Field__c  = 'utl__Parent_Test_sObject__c';

            // Execute test
            insert problemChildMso;

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(System.DmlException e){
            Assert.areEqual(
                true,
                e.getMessage().contains('"utl__Parent_Test_sObject__c" does not have any child relationship(s) to "Organization"'),
                'Unexpected Exception Message: ' + e.getMessage() + e.getStackTraceString()
            );
        }


        try{
            Mapped_sObject__c problemChildMso = new Mapped_sObject__c();
            problemChildMso.Parent_sObject__c      = parentMso.Id;
            problemChildMso.Name                   = 'utl__Child_Test_sObject__c';
            problemChildMso.sObjectType__c         = 'utl__Child_Test_sObject__c';
            problemChildMso.Parent_sObjectType__c  = 'utl__Parent_Test_sObject__c';
            problemChildMso.Relationship_Field__c  = 'OwnerId';

            // Execute test
            insert problemChildMso;

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(System.DmlException e){
            Assert.areEqual(
                true,
                e.getMessage().contains('The field "OwnerId" on sObject "utl__Child_Test_sObject__c" does not lookup to sObject "utl__Parent_Test_sObject__c"'),
                'Unexpected Exception Message: ' + e.getMessage() + e.getStackTraceString()
            );
        }
    }
}