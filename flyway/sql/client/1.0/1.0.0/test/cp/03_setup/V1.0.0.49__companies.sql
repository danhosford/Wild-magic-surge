-- ================================================================================
-- Author:      Alexandre Tran
-- Create date: 14/01/2019
-- Description: Create fake companies and workforce
-- 15/03/2020 - AT - Ensure company uuid is populate to workforce
-- 10/09/2020 - BOL - Added company death star
-- 15/09/2020 - AT - Insert first & last name in new column
-- 23/11/2020 - CC - Added new company Treadstone Inc
-- 27/11/2020 - JC - Add new company General Inc for general permit workflow #3030
-- 27/11/2020 - JC - Add new company signature inc for the signature permit #3030
-- ================================================================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @TOTAL_CONTRACTORS INT = 25;
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

SET NOCOUNT ON;

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

DECLARE @counter INT = 0;
DECLARE @salt VARCHAR(255) = CONVERT(VARCHAR(40),HASHBYTES('SHA1',convert(varchar(50), NEWID())),2)

PRINT 'Creating a password and salt ...';

DECLARE @passwordhash VARCHAR(255) = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT('@1LookSystems',@salt)),2);
WHILE @counter < 999
BEGIN
	SET @passwordhash = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT(@passwordhash,@salt)),2);
	SET @counter = @counter +1;
END

PRINT 'Password and Salt created!';

IF OBJECT_ID('tempdb..#Companies') IS NOT NULL DROP TABLE #Companies

CREATE TABLE #Companies(
	name VARCHAR(255)
	,address1 VARCHAR(255)
	,address2 VARCHAR(255) NOT NULL DEFAULT ''
	,address3 VARCHAR(255) NOT NULL DEFAULT ''
	,address4 VARCHAR(255) NOT NULL DEFAULT ''
	,address5 VARCHAR(255) NOT NULL DEFAULT ''
	,addressState VARCHAR(255) NOT NULL DEFAULT ''
	,phone VARCHAR(255) NOT NULL DEFAULT ''
	,email VARCHAR(255) NOT NULL DEFAULT ''
	,website VARCHAR(255) NOT NULL DEFAULT ''
	,fax VARCHAR(255) NOT NULL DEFAULT ''
	,active BIT NOT NULL DEFAULT 1
	,countryISO VARCHAR(2)
);

INSERT INTO #Companies (name,address1,countryISO)
VALUES ('Test Company Ltd','@local','IE')
,('ProTakeCareOfItAgain Ltd', '@hereAndThere', 'IE')
,('Messy Ltd','@tralal','IE')
,('Death Star','Space','IE')
,('Treadstone Inc', 'Budapest', 'IE')
,('General Inc', 'Paris', 'IE')
,('Signature Inc', 'Alderaan', 'IE');


PRINT 'Attempt add companies information...';

INSERT INTO [dbo].[cpCompany] (
	[kioskID],[cpCompanyID],[cpCompanyVersion]
	,[cpCompanyPublicKey],[cpCompanyIsActive]
	,[cpCompanyCreateBy],[cpCompanyCreateUTC]
	,[cpStatusID]
	,[cpCompanyName]
	,[cpCompanyAddress1]
	,[cpCompanyAddress2]
	,[cpCompanyAddress3]
	,[cpCompanyAddress4]
	,[cpCompanyAddress5]
	,[cpCompanyAddressState],[cpCompanyAddressCountryID]
	,[cpCompanyContactName],[cpCompanyContactEmail]
	,[cpCompanyContactTelephone],[cpCompanyContactWebsite],[cpCompanyContactFax]
)
SELECT @kioskid AS [kioskid],ISNULL(MAX([existing].[id]),0) + (ROW_NUMBER() OVER(ORDER BY NEWID())) AS [autonumb], 1 AS [version]
	,NEWID() AS [companykey],1 AS [isActive]
	,0,GETUTCDATE()
	,2
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[name])
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[address1])
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[address2])
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[address3])
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[address4])
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[address5])
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[addressState]),[country].[cpCountryID]
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[name]),ENCRYPTBYPASSPHRASE(@PASS,[company].[email])
	,ENCRYPTBYPASSPHRASE(@PASS,[company].[phone]),ENCRYPTBYPASSPHRASE(@PASS,[company].[website]),ENCRYPTBYPASSPHRASE(@PASS,[company].[fax])
FROM #Companies AS [company]
LEFT JOIN [dbo].[cpCountries] AS [country]
	ON [country].[cpCountryISO] = [company].[countryISO] COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN [dbo].[companies] AS [existing]
	ON [existing].[kioskid] = @KIOSKID
LEFT JOIN [dbo].[companies] AS [created]
	ON [created].[kioskID] = @KIOSKID
	AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[created].[name])) = [company].[name] COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE [created].[id] IS NULL
GROUP BY [company].[name]
	,[company].[address1]
	,[company].[address2]
	,[company].[address3]
	,[company].[address4]
	,[company].[address5]
	,[company].[addressState],[country].[cpCountryID]
	,[company].[name],[company].[email]
	,[company].[phone],[company].[website],[company].[fax];

PRINT 'Companies information added successfully!';

PRINT 'Attempt add companies to sites...';

INSERT INTO [cpCompanySites] (
  [cpCompanyID],[cpCompanyVersion]
  ,[kioskSiteID],[kioskSiteUUID],[kioskID]
)
SELECT cm.cpCompanyID, cm.cpCompanyVersion
,ks.kioskSiteID,ks.kioskSiteUUID,@KIOSKID
FROM #Companies AS c
LEFT JOIN cpCompanyMaster AS cm 
  ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,cm.currentName)) = c.name COLLATE SQL_Latin1_General_CP1_CI_AS
FULL OUTER JOIN kioskSite AS ks 
  ON ks.kioskSiteUUID IS NOT NULL
LEFT JOIN cpCompanySites AS ccs 
  ON ccs.cpCompanyID = cm.cpCompanyID
	AND ccs.cpCompanyVersion = cm.cpCompanyVersion
	AND ccs.kioskSiteID = ks.kioskSiteID
	AND ccs.kioskSiteUUID = ks.kioskSiteUUID
	AND ccs.kioskID = @KIOSKID
WHERE ccs.cpCompanySiteID IS NULL

PRINT 'Companies added to sites successfully!';

PRINT 'Attempt create company admin...';


INSERT INTO [dbo].[kioskUser](
  [kioskID],[kuPublicKey],[kuPrivateKey]
  ,[kuIsSuperuser],[kuIsActive]
  ,[kuCreateBy],[kuCreateUTC]
  ,[kuPasswordHash],[kuPasswordSalt]
  ,[kuIsEmployeeOrExternalContractor]
  ,[cpCompanyID]
  ,[kuFirstNameN],[kuLastNameN]
  ,[firstname],[lastname]
  ,[kuEmailN],[kuTelephoneN],[kuJobTitleN]
)
SELECT @KIOSKID,NEWID(),NEWID()
,0,1
,0,GETUTCDATE()
,@passwordhash,@salt
,'Employee'
,[company].[id]
,ENCRYPTBYPASSPHRASE(@PASS,'admin')
,ENCRYPTBYPASSPHRASE(@PASS,LOWER(REPLACE([newcompany].[name],' ','')))
,ENCRYPTBYPASSPHRASE(@PASS,N'admin')
,ENCRYPTBYPASSPHRASE(@PASS,CAST(LOWER(REPLACE([newcompany].[name],' ','')) AS NVARCHAR(255)))
,ENCRYPTBYPASSPHRASE(@PASS,CONCAT('admin.',LOWER(REPLACE([newcompany].[name],' ','')),'@onelooksystems.com'))
,ENCRYPTBYPASSPHRASE(@PASS,'555-5555')
,ENCRYPTBYPASSPHRASE(@PASS,'Company admin tester')
FROM #Companies AS [newcompany]
LEFT JOIN [dbo].[companies] AS [company]
  ON [company].[kioskid] = @KIOSKID
  AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[company].[name])) = [newcompany].[name]
LEFT JOIN [dbo].[kioskUser] AS [existing]
  ON [existing].[kioskID] = @KIOSKID
  AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[existing].[kuEmailN])) = CONCAT('admin.',LOWER(REPLACE([newcompany].[name],' ','')),'@onelooksystems.com')
WHERE [existing].[kuID] IS NULL;

PRINT 'Company admin created successfully!';

PRINT 'Attempt add admin to CP Company Admin group...';

INSERT INTO [dbo].[kioskUserAccessControlGroupMembership](
  [kioskID],[kioskSiteUUID]
  ,[kuID],[kacgID]
  ,[kuacgmCreateBy],[kuacgmCreateUTC],[kuacgmIsActive]
)
SELECT [cpsetting].[kioskID],[cpsetting].[kioskSiteUUID]
,[admin].[kuid],[cpsetting].[cagID]
,0,GETUTCDATE(),1
FROM [dbo].[cpCompanyAdminGroupSetting] AS [cpsetting]
FULL OUTER JOIN #Companies AS [newcompany]
  ON [newcompany].[name] IS NOT NULL
LEFT JOIN [dbo].[kioskUser] AS [admin]
  ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[admin].[kuEmailN])) = CONCAT('admin.',LOWER(REPLACE([newcompany].[name],' ','')),'@onelooksystems.com')
LEFT JOIN [dbo].[kioskUserAccessControlGroupMembership] AS [existing]
  ON [existing].[kioskID] = [cpsetting].[kioskID]
  AND [existing].[kioskSiteUUID] = [cpsetting].[kioskSiteUUID]
  AND [existing].[kuID] = [admin].[kuID]
  AND [existing].[kacgID] = [cpsetting].[cagID]
WHERE [existing].[kuacgmID] IS NULL
  AND [cpsetting].[kioskid] = @KIOSKID;

PRINT 'CP Company Admin added to CP company admin group successfully!';

PRINT 'Attempt to add contractors to companies...';

DECLARE @i int = 0
WHILE @i < @TOTAL_CONTRACTORS
BEGIN
    SET @i = @i + 1
	
	DECLARE @name VARCHAR(255) = 'c';

	INSERT INTO kioskUser (
    [kuIsActive],[kuPublicKey],[kuPrivateKey]
    ,[kioskID]
    ,[kuFirstNameN]
    ,[kuLastNameN]
    ,[firstname]
    ,[lastname]
    ,[kuEmailN]
    ,[kuTelephoneN]
    ,[kuJobTitleN]
    ,[kuIsSuperuser],[kuIsPasswordChangeRequired]
    ,[kuCreateBy],[kuCreateUTC]
    ,[kuPasswordHash],[kuPasswordSalt]
    ,[kuIsEmployeeOrExternalContractor]
    ,[kuIsAccountLocked]
    ,[cpCompanyID]
  )
	SELECT 1,NEWID(),NEWID()
    ,@KIOSKID
    ,ENCRYPTBYPASSPHRASE(@PASS,@name)
    ,ENCRYPTBYPASSPHRASE(@PASS,CONVERT(VARCHAR(255),@i))
    ,ENCRYPTBYPASSPHRASE(@PASS,CAST(@name AS NVARCHAR(255)))
    ,ENCRYPTBYPASSPHRASE(@PASS,CAST(CONVERT(VARCHAR(255),@i) AS NVARCHAR(255)))
    ,ENCRYPTBYPASSPHRASE(@PASS,CONCAT('c',@i,'.',LOWER(REPLACE(CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)),' ','')),'@onelooksystems.com'))
    ,ENCRYPTBYPASSPHRASE(@PASS,'')
    ,ENCRYPTBYPASSPHRASE(@PASS,'Tester')
    ,0,0
    ,0,GETUTCDATE()
    ,@passwordhash,@salt
    ,'Contractor'
    ,0
    ,cm.cpCompanyID
	FROM #Companies AS c
	LEFT JOIN cpCompanyMaster AS cm ON CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)) = c.name
	LEFT JOIN kioskUser AS ku ON ku.kioskID = @KIOSKID
		AND CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = CONCAT('c',@i,'.',LOWER(REPLACE(CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)),' ','')),'@onelooksystems.com')
		AND ku.kuIsEmployeeOrExternalContractor = 'Contractor'
	WHERE ku.kuID IS NULL;

    INSERT INTO [cpWorkforce] (
	[cpWorkforcePublicKey],[kioskID]
      ,[cpCompanyID],[cpWorkforceIsSubcontractor]
      ,[cpWorkforceFirstName],[cpWorkforceLastName]
      ,[cpWorkforceContactEmailAddress]
      ,[cpWorkforceIsActive],[cpWorkforceHasAccount],[kuID]
      ,[cpWorkforceCreateBy],[cpWorkforceCreateUTC]
	  ,[cpWorkforceJobTitle]
      ,[cpWorkforceContactWorkAddress]
	  ,[cpWorkforceContactTelephone]
	  ,[cpWorkforceSubContractorCompanyName]
      ,[company]
	)
	SELECT 
	NEWID(),@KIOSKID
	,cm.cpCompanyID,0
	,ku.kuFirstNameN,ku.kuLastNameN
	,ku.kuEmailN
	,1,0,ku.kuID
	,0,GETUTCDATE()
	,ku.kuJobTitleN
	,ENCRYPTBYPASSPHRASE(@PASS,'')
	,ku.kuTelephoneN
	,ENCRYPTBYPASSPHRASE(@PASS,'')
    ,[cm].[uuid]
	FROM #Companies AS c
	LEFT JOIN cpCompanyMaster AS cm ON CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)) = c.name
	LEFT JOIN kioskUser AS ku ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = CONCAT('c',@i,'.',LOWER(REPLACE(CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)),' ','')),'@onelooksystems.com')
		AND ku.kioskID = @KIOSKID
	LEFT JOIN cpWorkforce AS cwf ON cwf.kioskID = @KIOSKID
		AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,cwf.cpWorkforceContactEmailAddress)) = CONCAT('c',@i,'.',LOWER(REPLACE(CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)),' ','')),'@onelooksystems.com')
		AND cwf.cpCompanyID = cm.cpCompanyID
	WHERE cwf.cpWorkforceID IS NULL;

END

PRINT 'Contractors added to companies successfully!';

PRINT 'Attempt setup ACL for contractors...';

INSERT INTO [kioskUserAccessControlGroupMembership](
      [kioskID],[kuID],[kacgID]
      ,[kuacgmCreateBy],[kuacgmCreateUTC]
      ,[kuacgmIsActive]
      ,[kioskSiteUUID])
SELECT @KIOSKID,ku.kuID,kacg.kacgID
,0,GETUTCDATE()
,1,kacg.kioskSiteUUID
FROM kioskUser AS ku
FULL OUTER JOIN #Companies AS c ON c.name IS NOT NULL
LEFT JOIN cpCompanyMaster AS cm ON CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)) = c.name
FULL OUTER JOIN kioskAccessControlGroup AS kacg ON kacg.kacgName IN('Course Standard User - Contractor')
LEFT JOIN [kioskUserAccessControlGroupMembership] AS kuacg ON kuacg.kacgID = kacg.kacgID
	AND kuacg.kioskID = @KIOSKID
	AND kuacg.kuID = ku.kuID
	AND kuacg.kioskSiteUUID = kacg.kioskSiteUUID
WHERE kuacg.kuacgmID IS NULL
	AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) LIKE CONCAT('%','.',LOWER(REPLACE(CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)),' ','')),'@onelooksystems.com','%');

INSERT INTO [kioskUserSite](
      [kioskID],[kioskSiteUUID]
      ,[kuID],[kioskUserSiteIsActive]
      ,[kioskUserSiteCreateBy],[kioskUserSiteCreateUTC]
      )
SELECT @KIOSKID,kacg.kioskSiteUUID
,ku.kuID,1
,0,GETUTCDATE()
FROM kioskUser AS ku
FULL OUTER JOIN #Companies AS c ON c.name IS NOT NULL
LEFT JOIN cpCompanyMaster AS cm ON CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)) = c.name
FULL OUTER JOIN kioskAccessControlGroup AS kacg ON kacg.kacgName IN('Course Standard User - Contractor')
LEFT JOIN kioskUserSite AS kus ON kus.kioskID = @KIOSKID
	AND kus.kioskSiteUUID = kacg.kioskSiteUUID
	AND kus.kuID = ku.kuID
WHERE kus.kioskUserSiteID IS NULL
	AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) LIKE CONCAT('%','.',LOWER(REPLACE(CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,cm.currentName)),' ','')),'@onelooksystems.com','%');

PRINT 'ACL for contractors setup successfully!';


IF OBJECT_ID('tempdb..#Companies') IS NOT NULL DROP TABLE #Companies

SET NOCOUNT OFF;