/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 07/11/2018 13:21
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = CONVERT(INT,SUBSTRING(db_name(),5,4));

-- Test script variable
DECLARE @GROUPLIST VARCHAR(MAX) = 'MOC Approver';

SET NOCOUNT ON;

-- Get the KACGID of the MOC approver group
--SELECT * FROM kioskAccessControlGroup WHERE kacgName IN (SELECT * FROM STRING_SPLIT(@GROUPLIST,';'))


-- Add user to the MOC group

PRINT 'Add MOC Approver list...'
INSERT INTO mocApproverList([kioskID]
      ,[malIsActive]
	  ,[malIsDefault]
      ,[kuPublicKey]
      ,[kuID]
      ,[malCreateBy]
      ,[malCreateUTC]
	  ,[kioskSiteUUID]
      )
SELECT @KIOSKID,1,0
-- user setting
,ku.kuPublicKey, ku.kuID
-- Creation setting - 0 always system
,0,GETUTCDATE()
-- Site
,kacg.kioskSiteUUID
FROM kioskUserAccessControlGroupMembership AS kacg
LEFT JOIN kioskUser AS ku ON ku.kuID = kacg.kuID
LEFT JOIN kioskAccessControlGroup AS kag ON kag.kacgID = kacg.kacgID
AND kacgName IN (SELECT * FROM STRING_SPLIT(@GROUPLIST,';'))
LEFT JOIN mocApproverList AS mal ON mal.kuPublicKey = ku.kuPublicKey
AND mal.kioskSiteUUID = kacg.kioskSiteUUID
AND mal.kioskID = @KIOSKID
WHERE kag.kacgID IS NOT NULL
AND kacg.kuacgmDeactivateUTC IS NULL
AND mal.malID IS NULL

PRINT 'MOC Approver list updated successfully!'
SET NOCOUNT OFF;