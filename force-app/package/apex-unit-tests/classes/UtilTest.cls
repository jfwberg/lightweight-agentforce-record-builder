@IsTest
private with sharing class UtilTest {


    @IsTest
    static void sha1Test(){
        Assert.areEqual('a94a8fe5ccb19ba61c4c0873d391e987982fbbd3',Util.sha1('test'), 'Unexpected SHA1 hash');
    }


    /**
     * @description Method to test the static resource utility
     */
    @IsTest
    static void getStaticResourceBody(){

        // Check the body is as expected
        Assert.areNotEqual(
            null,
            Util.getStaticResourceBody(Constant.VAL_APEX_UNIT_TEST_JSON),
            'Unexpected static resource body'
        );

        // Test the exceptions
        try{
            // Invalid static resource name
            Util.getStaticResourceBody('invalid');

            // This code should not be reached
            utl.Tst.assertExceptionHasBeenThrow();

        }catch(Util.InvalidDataException e){
            utl.Tst.assertExceptionMessage(
                Constant.MSG_STATIC_RESOURCE_ERROR,
                'invalid',
                e
            );
        }
	}
}