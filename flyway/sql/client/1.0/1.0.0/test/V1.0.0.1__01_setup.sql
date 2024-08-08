-- ==============================================================================================
-- Author:      Alexandre Tran
-- Create date: 23/11/2018
-- Description: Setup kiosk application on sites
-- * 03/10/2019 - AT - Fix issue where non existing application was registered into site app
-- * 25/04/2020 - AT - Add site for each languages
-- * 29/04/2020 - AT - Enable Germany site for Gitlab #2085
-- * 29/04/2020 - AT - Enable Hungary site for Gitlab #2085
-- * 17/05/2020 - AT - Ensure all sites use CP as contractor management
-- * 30/07/2020 - AT - Set dd/mm/yyyy as default for France site
-- * 06/08/2020 - BOL - Set different date formats for each site
-- * 12/08/2020 - AT - Revert Date format for Hong Kong due to RTL support date
-- * 16/10/2020 - SG - Updating the Translations site to use Europe/Dublin as its timezone
-- * 30/11/2020 - AT - Include SHORT site for SHORT date format
-- * 08/12/2020 - AT - Ensure all sites use HH:MM format (will change for future coverage)
-- * 08/12/2020 - AT - Ensure that any change is updated if site already exist
-- * 17/12/2020 - AT - Include Playground site
-- * 17/12/2020 - AT - Update the new name column instead
-- * 16/01/2021 - AT - Enable by default Self-Service module
-- * 28/01/2021 - JC - Enable Poland Site for Gitlab 3348
-- * 02/03/2021 - SG - Ensure contractorCanSeeDocuments is turned on
-- * 08/02/2022 - JO - Updating Safepermit to Permit to Work - Rebranding
-- * 11/02/2022 - KB - Ensure appplications have correct priority
-- * 30/11/2022 - JC - Ensure applications have new order to include loto
-- ==============================================================================================

SET NOCOUNT ON;
DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

DECLARE @count INT = 0;
DECLARE @batchSize INT = 500;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

DECLARE @CPLegacy INT = 1;
DECLARE @CP INT = 2;

DECLARE @APPLIST TABLE(
	name VARCHAR(255) NOT NULL,
	enable BIT NOT NULL DEFAULT 1
);

INSERT INTO @APPLIST (name)
VALUES ('Permit to Work')
,('Contractor Portal')
,('Management of Change')
,('Visitor')
,('Course Manager')
,('Risk Assessment')
,('Global Administration')
,('COSHH')
,('Enterprise Dashboard')
,('Self-Service');

-- Update base site name to be user friendly
UPDATE kioskSite
SET kioskSiteName = 'Ireland'
WHERE kioskSiteName = 'Onelook-Base';

PRINT 'Attempt create test sites...';
IF OBJECT_ID('tempdb..#TargetSites') IS NOT NULL DROP TABLE #TargetSites

CREATE TABLE #TargetSites(
  name NVARCHAR(255),
  timezone VARCHAR(255) NOT NULL,
  language VARCHAR(15) NOT NULL,
  dateformat VARCHAR(255) NOT NULL,
  CalendarDateFormat VARCHAR(255) NOT NULL,
  TimeFormat VARCHAR(255) NOT NULL,
  enable BIT NOT NULL DEFAULT 1,
  contractorSystemToUse INT NOT NULL DEFAULT 2,
  contractorAccountCompanyMandatory INT NOT NULL DEFAULT 1,
  contractorCanSeePermits INT NOT NULL DEFAULT 2,
  IsGeneralApprovalRequiredBeforeOtherPermit BIT NOT NULL DEFAULT 0,
  IsContractorDocument BIT NOT NULL DEFAULT 0,
  IsGoogleMapIntegrationEnabled BIT NOT NULL DEFAULT 0,
  ApproverByLocation BIT NOT NULL DEFAULT 0,
  DocumentApprovalMultiApprover BIT NOT NULL DEFAULT 0,
  contractorCanSeeDocuments BIT NOT NULL DEFAULT 1,
  timeout INT NOT NULL DEFAULT 3600000
);

INSERT INTO #TargetSites (name,timezone,language,dateformat,CalendarDateFormat,TimeFormat,contractorSystemToUse)
VALUES ('Brazil','Brazil/Acre','pt_BR','ddd dd mmm yyyy','d M yy','HH:MM',@CP)
,('France','Europe/Paris','fr_FR','dd/mm/yyyy','d M yy','HH:MM',@CP)
,('Germany','Europe/Berlin','de_DE','dd-mmm-yyyy','d M yy','HH:MM',@CP)
,('HongKong','Hongkong','zh_CN','dd/mm/yyyy','d M yy','HH:MM',@CP)
,('Hungary','Europe/Budapest','hu_HU','mmm-dd-yyyy','d M yy','HH:MM',@CP)
,('Icelandic','Iceland','is_IS','mmmm d, yyyy','d M yy','HH:MM',@CP)
,('Ireland','Europe/Dublin','en_IE','mm/dd/yyyy','d M yy','HH:MM',@CP)
,('Israel','Israel','iw_IL','dd/mm/yyyy','d M yy','HH:MM',@CP)
,('Italy','Europe/Rome','it_IT','ddd, mmmm dd, yyyy','d M yy','HH:MM',@CP)
,('Legacy','Europe/Dublin','en_IE','yyyy-mm-dd','d M yy','HH:MM',@CPLegacy)
,('Playground','Europe/Dublin','en_IE','dd/mm/yyyy','d M yy','HH:nn',@CP)
,('Spain','Europe/Madrid','es_ES','ddd dd mmm yyyy','d M yy','HH:MM',@CP)
,('Switzerland','Europe/Zurich','de_CH','ddd dd mmm yyyy','d M yy','HH:MM',@CP)
,('Tatooine','Japan','en_IE','ddd dd mmm yyyy','d M yy','HH:MM',@CP)
,('Translations','Europe/Dublin','en_IE','ddd dd mmm yyyy','d M yy','HH:MM',@CP)
,('US Central','US/Central','en_US','ddd dd mmm yyyy','d M yy','HH:MM',@CP)
,('SHORT','Europe/Dublin','en_IE','SHORT','d M yy','HH:MM',@CP)
,('Poland','Europe/Warsaw','pl_PL','ddd, mmmm dd, yyyy','d M yy','HH:MM',@CP)
;

INSERT INTO [dbo].[kioskSite] (
[kioskID],[kioskSiteUUID],[kioskSitePublicUUID]
,[kioskSiteName],[name],[kioskSiteIsActive]
,[kioskSiteCreateBy],[kioskSiteCreateUTC]
,[contractorSystemToUse],[contractorAccountCompanyMandatory],[contractorCanSeePermits],[contractorCanSeeDocuments])
SELECT @KIOSKID,NEWID(),NEWID()
,CAST(ts.name AS VARCHAR(255)),ts.name,ts.enable
,0,GETUTCDATE()
,ts.contractorSystemToUse,ts.contractorAccountCompanyMandatory,ts.contractorCanSeePermits,ts.contractorCanSeeDocuments
FROM #TargetSites AS ts
LEFT JOIN kioskSite AS ks ON ks.kioskID = @KIOSKID
	AND ks.kioskSiteName = ts.name COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE ks.kioskSiteUUID IS NULL
ORDER BY ts.name;

PRINT 'Populate hint with all existing translation...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  UPDATE TOP(@batchSize) [site]
  SET [site].[contractorSystemToUse] = [setting].[contractorSystemToUse]
      ,[site].[contractorCanSeeDocuments] = [setting].[contractorCanSeeDocuments]
  FROM [dbo].[kioskSite] AS [site]
  INNER JOIN #TargetSites AS [setting]
    ON [setting].[name] = [site].[kioskSiteName] COLLATE SQL_Latin1_General_CP1_CI_AS
    AND [setting].[contractorSystemToUse] != [site].[contractorSystemToUse]
    AND [setting].[contractorCanSeeDocuments] != [site].[contractorCanSeeDocuments];

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative update site setting: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

INSERT INTO kioskSetting (
  [kioskID],[kioskSiteUUID],[ksIsActive]
  ,[ksTimeZone],[ksDateFormat],[ksCalendarDateFormat],[ksTimeFormat]
  ,[ksLanguage],[ksLocale]
  ,[ksCreateBy],[ksCreateUTC]
  ,[ksIsGoogleMapIntegrationEnabled]
  ,[ksIsContractorDocument]
  ,[ksIsGeneralApprovalRequiredBeforeOtherPermit]
  ,[ksApproverByLocation]
  ,[ksDocumentApprovalMultiApprover]
  ,[ksTimeout]
)
SELECT ks.kioskID,ks.kioskSiteUUID,ts.enable
  ,ts.timezone,ts.dateformat,ts.CalendarDateFormat,ts.TimeFormat
  ,ts.language,ts.language
  ,0,GETUTCDATE()
  ,ts.IsGoogleMapIntegrationEnabled
  ,ts.IsContractorDocument
  ,ts.IsGeneralApprovalRequiredBeforeOtherPermit
  ,ts.ApproverByLocation
  ,ts.DocumentApprovalMultiApprover
  ,ts.timeout
FROM #TargetSites AS ts
LEFT JOIN kioskSite AS ks ON ks.kioskSiteName = ts.name COLLATE SQL_Latin1_General_CP1_CI_AS
	AND ks.kioskID = @KIOSKID
LEFT JOIN kioskSetting AS cfg ON cfg.kioskID = ks.kioskID
	AND cfg.kioskSiteUUID = ks.kioskSiteUUID
	AND cfg.ksIsActive = 1
WHERE cfg.ksID IS NULL;

PRINT 'Update setting if site already exist...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  UPDATE [target]
  SET [target].[ksTimeFormat] = [setting].[TimeFormat]
  FROM [kioskSetting] AS [target]
  INNER JOIN [kioskSite] AS [site]
    ON [site].[kioskSiteUUID] = [target].[kioskSiteUUID]
  INNER JOIN #TargetSites AS [setting]
    ON [setting].[name] = [site].[kioskSiteName] COLLATE SQL_Latin1_General_CP1_CI_AS
  WHERE [target].[ksIsActive] = 1 
   AND [setting].[timeFormat] != [target].[ksTimeFormat]  COLLATE SQL_Latin1_General_CP1_CI_AS;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative update site setting: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

IF OBJECT_ID('tempdb..#TargetSites') IS NOT NULL DROP TABLE #TargetSites
PRINT 'Test site created successfully!';

PRINT 'Attempt enable all applications...';

INSERT INTO [kioskSiteApplication] (
  [kioskID],[kioskSiteUUID],[kaID]
  ,[ksaIsActive],[ksaCreateBy],[ksaCreateUTC]
)
SELECT @KIOSKID,[site].[kioskSiteUUID],[globalapp].[kaID]
,[application].[enable],0,GETUTCDATE()
FROM @APPLIST AS [application]
LEFT JOIN [v3_sp].[dbo].[kioskApplications] AS [globalapp]
	ON [globalapp].[kaName] = [application].[name] COLLATE SQL_Latin1_General_CP1_CI_AS
FULL OUTER JOIN [dbo].[kioskSite] AS [site]
	ON [site].[kioskID] = @KIOSKID
	AND [site].[kioskSiteUUID] IS NOT NULL
LEFT JOIN [dbo].[kioskSiteApplication] AS [siteapp]
	ON [siteapp].[kioskID] = @KIOSKID
	AND [siteapp].[kioskSiteUUID] = [site].[kioskSiteUUID]
	AND [siteapp].[kaID] = [globalapp].[kaID]
	AND [siteapp].[ksaIsActive] = [application].[enable]
WHERE [siteapp].[ksaID] IS NULL
	AND [globalapp].[kaid] IS NOT NULL;

PRINT 'Applications enabled successfully!';

IF(@DEBUG = 1)
BEGIN
  SELECT * FROM #MailSettings;
END

IF(@DEBUG = 1)
BEGIN
  SELECT * FROM kioskSetting;
END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;
GO

IF COL_LENGTH('kioskSiteApplication', 'kaPriority') IS NOT NULL
BEGIN

PRINT 'Attempting to add values to [kaPriority] in table [dbo].[kioskSiteApplication] ...';
DECLARE  @priority TABLE(
  [kaID] INT 
  ,
  [kaPriority] INT
);

INSERT INTO @priority
  ([kaID],[kaPriority])

VALUES
  (1, 1) -- Permit
,
  (2, 2) -- CP
,
  (4, 3) -- Visitor
,
  (5, 4) -- CM
,
  (11, 5) -- LOTO
,
  (3, 6) -- MOC
,
  (8,7) -- COSHH
,
  (10, 8) -- SELF SERVICE
,
  (7,9) -- GA
,
  (6, 10) -- RA
,
  (9, 11) -- ED
 
  UPDATE [dbo].[kioskSiteApplication]
  SET [kaPriority] = [p].[kaPriority]
  FROM [dbo].[kioskSiteApplication]
  LEFT JOIN @priority [p]
    ON [dbo].[kioskSiteApplication].[kaID] =[p].[kaid]
  WHERE [dbo].[kioskSiteApplication].[kaPriority] IS NOT NULL

  PRINT 'New column [kaPriority] to table [dbo].[kioskSiteApplication] and values added successfully!';
END

