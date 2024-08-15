-- ==================================================================
-- Author:      Alexandre Tran
-- Create date: 26/11/2020
-- Description: Create fake companies based on sites
-- 26/11/2020 - AT - Create company for each site
-- 26/11/2020 - AT - Make company serve each site
-- 26/11/2020 - AT - Create company admin for each company site
-- 26/11/2020 - AT - Set company admin for site served
-- 26/11/2020 - AT - Include in ACL
-- ==================================================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @TOTAL_CONTRACTORS INT = 25;
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

DECLARE @StartingRecord BIGINT;
DECLARE @count INT = 0;
DECLARE @batchSize INT = 500;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

SET NOCOUNT ON;

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

DECLARE @counter INT = 0;
DECLARE @salt VARCHAR(255) = CONVERT(VARCHAR(40),HASHBYTES('SHA1',convert(varchar(50), NEWID())),2)

DECLARE @passwordhash VARCHAR(255) = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT('@1LookSystems',@salt)),2);
WHILE @counter < 999
BEGIN
	SET @passwordhash = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT(@passwordhash,@salt)),2);
	SET @counter = @counter +1;
END

PRINT 'Password and Salt created!';

DECLARE  @siteCompanies TABLE(
	[name] VARCHAR(255)
	,[address1] VARCHAR(255)
	,[address2] VARCHAR(255) NOT NULL DEFAULT ''
	,[address3] VARCHAR(255) NOT NULL DEFAULT ''
	,[address4] VARCHAR(255) NOT NULL DEFAULT ''
	,[address5] VARCHAR(255) NOT NULL DEFAULT ''
	,[addressState] VARCHAR(255) NOT NULL DEFAULT ''
	,[phone] VARCHAR(255) NOT NULL DEFAULT ''
	,[email] VARCHAR(255) NOT NULL DEFAULT ''
	,[website] VARCHAR(255) NOT NULL DEFAULT ''
	,[fax] VARCHAR(255) NOT NULL DEFAULT ''
	,[active] BIT NOT NULL DEFAULT 1
	,[countryISO] VARCHAR(2)
  ,[siteid] INT NOT NULL
  ,[site] VARCHAR(255) NOT NULL
);


PRINT 'Attempt add site company in temporary table...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

    INSERT INTO @siteCompanies(
      [name]
      ,[address1]
      ,[countryISO]
      ,[siteid]
      ,[site]
    )
    SELECT TOP(@batchsize)
      CONCAT([kioskSiteName],' Company') AS [name]
      ,CONCAT('@',[kioskSiteName]) AS [address]
      ,ISNULL([country].[cpCountryISO],'IE') AS [iso]
      ,[site].[kioskSiteID] AS [siteid]
      ,[site].[kioskSiteUUID] AS [site]
    FROM [dbo].[kioskSite] AS [site]
    LEFT JOIN [dbo].[cpCountries] AS [country]
      ON [country].[cpCountryName] = [site].[kioskSiteName]
    LEFT JOIN @siteCompanies AS [register]
      ON [register].[name] = CONCAT([kioskSiteName],' Company')
    WHERE [register].[name] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative add company: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Attempt add companies information...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

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
  SELECT TOP(@batchSize) @kioskid AS [kioskid]
    ,ISNULL(MAX([existing].[id]),0) + (ROW_NUMBER() OVER(ORDER BY NEWID())) AS [autonumb]
    , 1 AS [version]
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
  FROM @siteCompanies AS [company]
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

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative add company: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Attempt assign site to companies...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO [cpCompanySites] (
    [cpCompanyID],[cpCompanyVersion]
    ,[kioskSiteID],[kioskSiteUUID],[kioskID]
  )
  SELECT [master].[id]
    ,[master].[version]
    ,[company].[siteid]
    ,[company].[site]
    ,[master].[kioskid]
  FROM @sitecompanies AS [company]
  INNER JOIN [dbo].[companies] AS [master]
    ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[master].[name])) = [company].[name] COLLATE SQL_Latin1_General_CP1_CI_AS
  LEFT JOIN [dbo].[cpCompanySites] AS [register]
    ON [register].[cpCompanyID] = [master].[id]
    AND [register].[cpCompanyVersion] = [master].[version]
    AND [register].[kioskSiteID] = [company].[siteid]
    AND [register].[kioskSiteUUID] = [company].[site]
    AND [register].[kioskID] = [master].[kioskid]
  WHERE [register].[cpCompanySiteid] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative assign site to companies: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Attempt create site admin...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

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
  SELECT TOP(@batchSize) @KIOSKID,NEWID(),NEWID()
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
  FROM @sitecompanies AS [newcompany]
  LEFT JOIN [dbo].[companies] AS [company]
    ON [company].[kioskid] = @KIOSKID
    AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[company].[name])) = [newcompany].[name]
  LEFT JOIN [dbo].[kioskUser] AS [existing]
    ON [existing].[kioskID] = @KIOSKID
    AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[existing].[kuEmailN])) = CONCAT('admin.',LOWER(REPLACE([newcompany].[name],' ','')),'@onelooksystems.com')
  WHERE [existing].[kuID] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative create company admin: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Attempt assign site to admin...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO [kioskUserSite](
    [kioskID],[kioskSiteUUID]
    ,[kuID],[kioskUserSiteIsActive]
    ,[kioskUserSiteCreateBy],[kioskUserSiteCreateUTC]
  )
  SELECT [user].[kioskid],[company].[site]
    ,[user].[kuID],1
    ,0,GETUTCDATE()
  FROM [dbo].[kioskUser] AS [user]
  INNER JOIN @siteCompanies AS [company]
    ON CONCAT('admin.',LOWER(REPLACE([company].[name],' ','')),'@onelooksystems.com') = CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuEmailN]))
  LEFT JOIN [dbo].[kioskuserSite] AS [userSite]
    ON [userSite].[kioskid] = [user].[kioskid]
    AND [userSite].[kioskSiteUUID] = [company].[site]
    AND [userSite].[kuid] = [user].[kuid]
    AND [userSite].[kioskUserSiteIsActive] = 1
  WHERE [userSite].[kioskUserSiteID] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative assign site to admin: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Attempt add admin to CP Company Admin group...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO [dbo].[kioskUserAccessControlGroupMembership](
    [kioskID],[kioskSiteUUID]
    ,[kuID],[kacgID]
    ,[kuacgmCreateBy],[kuacgmCreateUTC],[kuacgmIsActive]
  )
  SELECT TOP(@batchSize) [cpsetting].[kioskID],[cpsetting].[kioskSiteUUID]
  ,[admin].[kuid],[cpsetting].[cagID]
  ,0,GETUTCDATE(),1
  FROM [dbo].[cpCompanyAdminGroupSetting] AS [cpsetting]
  FULL OUTER JOIN @sitecompanies AS [newcompany]
    ON [newcompany].[name] IS NOT NULL
  INNER JOIN [dbo].[kioskUser] AS [admin]
    ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[admin].[kuEmailN])) = CONCAT('admin.',LOWER(REPLACE([newcompany].[name],' ','')),'@onelooksystems.com')
  LEFT JOIN [dbo].[kioskUserAccessControlGroupMembership] AS [existing]
    ON [existing].[kioskID] = [cpsetting].[kioskID]
    AND [existing].[kioskSiteUUID] = [cpsetting].[kioskSiteUUID]
    AND [existing].[kuID] = [admin].[kuID]
    AND [existing].[kacgID] = [cpsetting].[cagID]
  WHERE [existing].[kuacgmID] IS NULL
    AND [cpsetting].[kioskid] = @KIOSKID;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative create company admin: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @startScriptTime, @endScriptTime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;