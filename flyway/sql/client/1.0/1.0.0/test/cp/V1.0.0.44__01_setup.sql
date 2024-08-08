-- =============================================
-- Author:      Alexandre Tran
-- Create date: 13/12/2018
-- Description: Setup Contractor portal for 
-- test environment
-- 12/05/2020 - JC - Change the casigID to be set to 3 as will be needed for testing
-- =============================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#Features') IS NOT NULL DROP TABLE #Features

CREATE TABLE #Features (
  section VARCHAR(255),
  page VARCHAR(255),
  enable BIT NOT NULL DEFAULT 1
);

INSERT INTO #Features (section,page)
VALUES('cpReports','workforceReport');

PRINT 'Attempt enabling features ...';

INSERT INTO [kioskAccessControlFeature] (
[kioskID],[kioskSiteUUID]
,[kbcID],[kacfIsActive]
,[kacfCreateBy],[kacfCreateUTC]
)
SELECT 
@KIOSKID,ks.kioskSiteUUID
,kbc.kbcID,f.enable
,0,GETUTCDATE()
FROM #Features AS f
LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kbc ON kbc.kbcSection = f.section COLLATE SQL_Latin1_General_CP1_CI_AS
  AND kbc.kbcPage = f.page COLLATE SQL_Latin1_General_CP1_CI_AS
FULL OUTER JOIN kioskSite AS ks ON ks.kioskID = @KIOSKID
  AND ks.kioskSiteUUID IS NOT NULL
LEFT JOIN kioskAccessControlFeature AS kacf ON kacf.kioskID = @KIOSKID
  AND kacf.kioskSiteUUID = ks.kioskSiteUUID
  AND kacf.kbcID = kbc.kbcID
  AND kacf.kacfIsActive = f.enable
WHERE kacf.kacfID IS NULL;

PRINT 'Features enabled successfully!';

IF OBJECT_ID('tempdb..#Features') IS NOT NULL DROP TABLE #Features
SET NOCOUNT OFF;

PRINT 'Attempt setting up configuration for Contractor Portal...';
-- Empty any existing CP configuration
TRUNCATE TABLE [dbo].[cpCompanyAdminGroupSetting];

-- Disable dirty group
UPDATE [dbo].[kioskAccessControlGroup]
SET [kacgIsActive] = 0
,[kacgDeactivateUTC] = GETUTCDATE()
,[kacgDeactivateBy] = 0
WHERE UPPER([kacgName]) LIKE '%outdated%'
  AND [kacgDeactivateUTC] IS NULL;

INSERT INTO [dbo].[cpCompanyAdminGroupSetting](
  [kioskID],[kioskSiteUUID]
  ,[cagID],[casagID],[cagsIsActive]
  ,[cagsAddedBy],[cagsAddedUTC]
  ,[casigID],[cacigID]
  ,[caEmailIsMandatory]
  ,[cacsgid],[cat1agid],[cat2agid],[cat3agid]
)
SELECT [site].[kioskID],[site].[kioskSiteUUID]
,[site].[CP_Company_Admin],[site].[CP_System_Admin],1 AS [active]
,0 AS [createdby],GETUTCDATE() AS [createdon]
,3 AS [casigID],0 AS [cacigID]
,0 AS [caEmailIsMandatory]
,0 AS [cacsgid],0 AS [cat1agid],0 AS [cat2agid],0 AS [cat3agid]
FROM (
  SELECT [group].[kioskID],[group].[kioskSiteUUID]
  ,REPLACE([group].[kacgName],' ','_') AS [name]
  ,[group].[kacgID]
  FROM [dbo].[kioskAccessControlGroup] AS [group]
  WHERE (UPPER([group].[kacgName]) LIKE '%CP SYSTEM ADMIN%'
    OR UPPER([group].[kacgName]) LIKE '%CP COMPANY ADMIN%')
    AND [group].[kacgDeactivateUTC] IS NULL
) AS [sourcetable]
PIVOT (
  MAX([kacgID])
  FOR [name] IN ([CP_Company_Admin],[CP_System_Admin])
) AS [site]
LEFT JOIN [dbo].[cpCompanyAdminGroupSetting] AS [existing]
  ON [existing].[kioskID] = [site].[kioskID]
  AND [existing].[kioskSiteUUID] = [site].[kioskSiteUUID]
  AND [existing].[cagsDeactivateUTC] IS NULL
WHERE [existing].[kioskSiteUUID] IS NULL;

PRINT 'Contractor portal setup successfully!';