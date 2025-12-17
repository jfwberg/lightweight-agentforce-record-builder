/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           December 2025
 * @copyright      (c) 2025 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains the actions that need to run post-install
 */
public without sharing class PostInstallHandler implements InstallHandler {

    /**
     * @description Interface method that runs on install
     * @param context The install context during install
     */
    public void onInstall(InstallContext context) {
        
        try{
            // Check if the package is installed for the first time or is upgraded
            Boolean isFirstInstall = context == null || context?.isUpgrade() == false;

            // Create the instructions
            System.EventBus.publish(new Action__e(
                Type__c    = Constant.VAL_TYPE_INSERT_INSTRUCTIONS
            ));

            // Assign the permission set
            System.EventBus.publish(new Action__e(
                Type__c    = Constant.VAL_TYPE_INSERT_PERM_SET,
                User_Id__c = context?.installerID() ?? UserInfo.getUserId()
            ));
            
        }catch(Exception e){
            System.EventBus.publish(new Action__e(
                Type__c        = Constant.VAL_TYPE_LOG_MESSAGE,
                User_Id__c     = context?.installerID() ?? UserInfo.getUserId(),
                Message__c     = e.getMessage(),
                Stack_Trace__c = e.getStackTraceString(),
                Error_Code__c  = e.getTypeName()
            ));
        }
    }
}