/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 07/11/2018 13:21
*/

SET NOCOUNT ON;

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';
DECLARE @counter INT = 0;
DECLARE @salt VARCHAR(255) = CONVERT(VARCHAR(40),HASHBYTES('SHA1',convert(varchar(50), NEWID())),2)

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

IF OBJECT_ID('tempdb..#SuperUsers') IS NOT NULL DROP TABLE #SuperUsers

/* Store super accounts requiring super user */
CREATE TABLE #SuperUsers(
  email VARCHAR(255)
);

INSERT INTO #SuperUsers
VALUES ('test.sysadmin@onelooksystems.com');

PRINT 'Creating a password and salt ...';

DECLARE @passwordhash VARCHAR(255) = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT('@1LookSystems',@salt)),2);
WHILE @counter < 999
BEGIN
	SET @passwordhash = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT(@passwordhash,@salt)),2);
	SET @counter = @counter +1;
END

PRINT 'Password and Salt created!';

UPDATE kioskUser
SET kioskID = dbo.udf_GetKioskID(db_name())
WHERE kioskID = 0

PRINT 'Update Test account'
UPDATE kioskUser
SET kuPasswordHash = @passwordhash
,kuPasswordSalt = @salt
,kioskID = dbo.udf_GetKioskID(db_name())
,kuIsActive = 1
,kuIsAccountLocked = 0
FROM kioskUser AS ku;

UPDATE ku
SET kuIsSuperuser = 1
FROM kioskUser AS ku
LEFT JOIN #SuperUsers AS su ON su.email = CONVERT(VARCHAR(MAX),DECRYPTBYPASSPHRASE(@PASS,ku.[kuEmailN]))
WHERE su.email IS NOT NULL;

PRINT 'Test account updated!'

PRINT 'Attempt add super user to all sites...';

INSERT INTO kioskUserSite(
[kioskID],[kioskSiteUUID],[kuID]
,[kioskUserSiteIsActive]
,[kioskUserSiteCreateBy],[kioskUserSiteCreateUTC])
SELECT ku.kioskID,ks.kioskSiteUUID,ku.kuID
,1
,0,GETUTCDATE() 
FROM kioskUser AS ku
FULL OUTER JOIN kioskSite AS ks ON ks.kioskID = ku.kioskID
	AND ks.kioskSiteUUID IS NOT NULL
LEFT JOIN kioskUserSite AS kus ON kus.kuID = ku.kuID 
	AND kus.kioskID = ku.kioskID
	AND kus.kioskSiteUUID = ks.kioskSiteUUID
	AND kus.kioskUserSiteIsActive = 1
WHERE ku.kuIsSuperuser = 1
	AND kus.kuID IS NULL
	AND ku.kuIsActive = 1;

PRINT 'Super users added to all sites successfully!';

DECLARE @SUFFIX_SUPER_ADMIN_GROUP_NAME VARCHAR(255) = 'Super Admin';

PRINT 'Attempt to create ACL Groups...';
INSERT INTO [kioskAccessControlGroup](
[kioskID],[kioskSiteUUID],[kaID],[kacgPublicKey]
,[kacgName],[kacgDescription]
,[kacgIsActive]
,[kacgIsEmployeeOnly],[kacgIsExternalContractorOnly]
,[kacgCreateBy],[kacgCreateUTC]
,[kacgIsDocApprovalGroup])
SELECT @KIOSKID,ks.kioskSiteUUID,ka.kaID,NEWID()
,CONCAT(UPPER(ka.kaPrefix),' ',@SUFFIX_SUPER_ADMIN_GROUP_NAME),CONCAT('Module administration group for ',ka.kaName)
,1
,1,0
,0,GETUTCDATE()
,0
FROM v3_sp.dbo.kioskApplications AS ka
FULL OUTER JOIN kioskSite AS ks ON ks.kioskID = @KIOSKID
	AND ks.kioskSiteUUID IS NOT NULL
LEFT JOIN kioskAccessControlGroup AS kacg ON kacg.kioskID = ks.kioskID
	AND kacg.kioskSiteUUID = ks.kioskSiteUUID
	AND kacg.kaID = ka.kaID
	AND kacg.kacgName = CONCAT(ka.kaPrefix,' ',@SUFFIX_SUPER_ADMIN_GROUP_NAME)
	AND kacg.kacgIsActive = 1
WHERE kacg.kacgID IS NULL;


SET NOCOUNT OFF;