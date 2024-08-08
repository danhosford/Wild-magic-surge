/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 07/11/2018 13:21
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 0;
DECLARE @MOC_MODULE_ID INT = 3;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

-- Test script variable
DECLARE @GROUPLIST VARCHAR(MAX) = 'MOC Approver';

SET NOCOUNT ON;

-- Add user to the MOC group
PRINT 'Add MOC Approver list...'
INSERT INTO mocApproverList(
  [kioskID],[kioskSiteUUID]
  ,[malIsActive],[malIsDefault]
  ,[kuPublicKey],[kuID]
  ,[malCreateBy],[malCreateUTC]
)
SELECT @KIOSKID,kacg.kioskSiteUUID
,1,0
-- user setting
,ku.kuPublicKey, ku.kuID
-- Creation setting - 0 always system
,0,GETUTCDATE()
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