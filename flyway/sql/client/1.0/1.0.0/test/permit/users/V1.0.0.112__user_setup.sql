-- =========================================================================================================
-- Author:      Paul McGee
-- Create date: 31/07/2019
-- CHANGELOG:
-- 28/09/2021 - SG - Assign a test user to a new test user group
-- =========================================================================================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @KIOSKSITEUUID VARCHAR(255) = '6BDE601C-3317-4643-A386-2954638AFC37'
DECLARE @PASS VARCHAR(255) = 'test pass';
DECLARE @USER_KUID INT;
DECLARE @GROUP_ID INT;
DECLARE @RECEIVER_USER_KUID INT;
DECLARE @RECEIVER_GROUP_ID INT;

SET NOCOUNT ON;

SELECT @USER_KUID = kuID FROM kioskUser WHERE DECRYPTBYPASSPHRASE(@PASS,kuEmailN) = 'test.companyadmin@onelooksystems.com'

SELECT @GROUP_ID = kacgID from kioskAccessControlGroup where kioskSiteUUID = '6BDE601C-3317-4643-A386-2954638AFC37'
and kacgName = 'CP System Admin'

INSERT INTO 	kioskUserAccessControlGroupMembership 
				values
					(	
						@KIOSKID,
						@USER_KUID,
						@GROUP_ID,
						2,
						GETDATE(),
						1,
						NULL,
						NULL,
						@KIOSKSITEUUID
					)

SELECT @RECEIVER_USER_KUID = kuID FROM kioskUser WHERE DECRYPTBYPASSPHRASE(@PASS,kuEmailN) = 'admin.protakecareofitagainltd@onelooksystems.com'

SELECT @RECEIVER_GROUP_ID = kacgID from kioskAccessControlGroup where kioskSiteUUID = '6BDE601C-3317-4643-A386-2954638AFC37'
and kacgName = 'Permit Receiver'

INSERT INTO kioskUserAccessControlGroupMembership 
    (kioskID,
     kacgID, 
     kuacgmCreateBy, 
     kuacgmCreateUTC, 
     kuacgmIsActive, 
     kuID, 
     kioskSiteUUID )
 VALUES (@KIOSKID,
        @RECEIVER_GROUP_ID,
        0,
        GETDATE(),
        1,
        @RECEIVER_USER_KUID,
        @KIOSKSITEUUID)

SET NOCOUNT OFF;