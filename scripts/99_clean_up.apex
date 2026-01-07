delete [SELECT Id FROM Task];
delete [SELECT Id FROM Case];
delete [SELECT Id FROM Contact];
delete [SELECT Id FROM Account WHERE Name != 'Sample Account for Entitlements'];
delete [SELECT Id FROM Process__c];
delete [SELECT Id FROM ContentDocument WHERE CreatedDate = Today];