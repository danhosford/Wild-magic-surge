/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 13/12/2018 23:50

- Add CP group to settings groups
- 12/05/2020 - SG - Adding three breadcrumbs that are needed for cp employee
*/

DECLARE @DEBUG BIT = 0;
DECLARE @CP_MODULE_ID INT = 2;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

DECLARE @CP_ADMINISTRATOR VARCHAR(255) = 'CP System Admin';
DECLARE @CP_SUPER_ADMIN VARCHAR(255) = 'CP Super Admin';
DECLARE @CP_COMPANY_ADMIN VARCHAR(255) = 'CP Company Admin';
DECLARE @CP_EMPLOYEE VARCHAR(255) = 'CP Employee';

IF OBJECT_ID('tempdb..#CP_BREADCRUMBS') IS NOT NULL DROP TABLE #CP_BREADCRUMBS;

CREATE TABLE #CP_BREADCRUMBS(
	section VARCHAR(255) NOT NULL
	,page VARCHAR(255) NOT NULL
	,groupname VARCHAR(255) NOT NULL
	,isActive BIT NOT NULL
	,moduleid INT DEFAULT 2
);

INSERT INTO #CP_BREADCRUMBS (section,page,groupname,isActive)
VALUES ('cpReports','workforceReport',@CP_ADMINISTRATOR,1)
,('cpReports','workforceReport',@CP_SUPER_ADMIN,1)
,('cpQuestionnaireCreate','questionnaireCreateSubmit',@CP_COMPANY_ADMIN,1)
,('cpCompany','companyTableAllOptionsAccess',@CP_EMPLOYEE,1)
,('cpCompany','cpCompanyRatingAdd_display',@CP_EMPLOYEE,0)
,('cpCompany','cpCompanyRatingAdd_submit',@CP_EMPLOYEE,0);

PRINT 'Attempting enabling breadcrumbs is not already enabled...';

INSERT INTO [dbo].[kioskAccessControlFeature](
[kioskID],[kioskSiteUUID]
,[kbcID]
,[kacfIsActive]
,[kacfCreateBy],[kacfCreateUTC]
)
SELECT DISTINCT @KIOSKID,ks.kioskSiteUUID
,kb.kbcID
,b.isActive
,0,GETUTCDATE()
FROM #CP_BREADCRUMBS AS b
LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kb ON kb.kbcSection = b.section COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kb.kbcPage = b.page COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kb.kaID = b.moduleid
FULL OUTER JOIN kioskSite AS ks ON ks.kioskSiteUUID IS NOT NULL
LEFT JOIN [kioskAccessControlFeature] AS kacf ON kacf.kbcID = kb.kbcID
	AND kacf.kioskID = @KIOSKID
	AND kacf.kioskSiteUUID = ks.kioskSitePublicUUID
	AND kacf.kacfIsActive = b.isActive
	AND kacf.kacfDeactivateUTC IS NULL
WHERE kacf.kacfID IS NULL;

PRINT 'Breadcrumbs enabled successfully!';

PRINT 'Attempting enable section/page access to group...';
INSERT INTO [dbo].[kioskAccessControlPage](
[kioskID],[kioskSiteUUID]
,[kbcID],[kacgPublicKey]
,[kacpCreateBy],[kacpCreateUTC]
,[kacpIsActive]
)
SELECT @KIOSKID,kacg.kioskSiteUUID
,kb.kbcID,kacg.kacgPublicKey
,0,GETUTCDATE()
,b.isActive
FROM #CP_BREADCRUMBS AS b
LEFT JOIN kioskAccessControlGroup AS kacg ON kacg.kacgName = b.groupname COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kb ON kb.kbcSection = b.section COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kb.kbcPage = b.page COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kb.kaID = b.moduleid
LEFT JOIN [kioskAccessControlPage] AS kacgp ON kacgp.kacgPublicKey = kacg.kacgPublicKey
	AND kacgp.kioskID = @KIOSKID
	AND kacgp.kbcID = kb.kbcID
	AND kacgp.kioskSiteUUID = kacg.kioskSiteUUID
	AND kacgp.kacpIsActive = b.isActive
	AND kacgp.kacpDeactivateUTC IS NULL
WHERE kacgp.kacpID IS NULL;

PRINT 'Section/page enable for groups successfully!';
