@IsTest
private with sharing class SchemaUtilTest {
    
    @IsTest
    static void validateRecordIdTest(){
        
        try{
            // Execute logic
            SchemaUtil.validateRecordId(null,null);

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(SchemaUtil.InputException e){
            utl.Tst.assertExceptionMessage(Constant.MSG_ID_SOBJECT_TYPE_MANDATORY, e);
        }


        try{
            // Execute logic
            SchemaUtil.validateRecordId('AAABBBCCC', User.getSObjectType());

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(SchemaUtil.InputException e){
            utl.Tst.assertExceptionMessage(Constant.MSG_INVALID_ID, e);
        }


        try{
            // Execute logic
            SchemaUtil.validateRecordId(UserInfo.getOrganizationId(),User.getSObjectType());

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(SchemaUtil.InputException e){
            utl.Tst.assertExceptionMessage(
                Constant.MSG_INVALID_ID_TYPE,
                Organization.getSObjectType().toString(),
                User.getSObjectType().toString(),
                e
            );
        }


        try{
            // Execute logic
            SchemaUtil.validateRecordId('00D000000000000', Organization.getSObjectType());

            // This method will fail the test as it should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(SchemaUtil.InputException e){
            utl.Tst.assertExceptionMessage(
                Constant.MSG_NO_RECORDS_FOUND_FOR_ID,
                '00D000000000000',
                e
            );
        }
    }
}