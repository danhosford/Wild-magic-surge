/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 07/11/2018 13:21

- Add MOC group to settings groups
*/

DECLARE @DEBUG BIT = 0;
DECLARE @MOC_MODULE_ID INT = 3;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

DECLARE @MOC_REQUESTER VARCHAR(255) = 'MOC Requester';
DECLARE @MOC_ADMINISTRATOR VARCHAR(255) = 'MOC Administrator';
DECLARE @MOC_APPROVER VARCHAR(255) = 'MOC Approver';
DECLARE @MOC_TASK_OWNER VARCHAR(255) = 'MOC Action Task Owner';

IF OBJECT_ID('tempdb..#MOC_BREADCRUMBS') IS NOT NULL DROP TABLE #MOC_BREADCRUMBS;

CREATE TABLE #MOC_BREADCRUMBS(
	section VARCHAR(255) NOT NULL
	,page VARCHAR(255) NOT NULL
	,groupname VARCHAR(255) NOT NULL
	,moduleid INT DEFAULT 3
	,isActive BIT DEFAULT 1
);

INSERT INTO #MOC_BREADCRUMBS (section,page,groupname)
VALUES ('mocApprover','mocAdminApproverByLocation',@MOC_ADMINISTRATOR)
,('mocCreate','mocCreateSubmit',@MOC_REQUESTER);


PRINT 'Attempting setting up MOC Group management...';
INSERT INTO [mocGroupSetting] (kioskID,kioskSiteUUID,mgsRequesterID,mgsApproverID,mgsAdministratorID,mgsOwnerID,mgsAddedBy,mgsAddedUTC,mgsIsActive,mgsUsesLongReports,mgsUsesOpenStatus)
SELECT @KIOSKID,pvt.*,0,GETUTCDATE(),1,0,0
FROM (
	  SELECT kacgID,kacgname,kioskSiteUUID
	  FROM kioskAccessControlGroup
		WHERE kacgName IN (@MOC_REQUESTER,@MOC_ADMINISTRATOR,@MOC_APPROVER,@MOC_TASK_OWNER)
			AND kaID = @MOC_MODULE_ID
) AS source
PIVOT(
	MIN(kacgID)
	FOR kacgName IN ([MOC Requester],[MOC Approver],[MOC Administrator],[MOC Action Task Owner])
) AS pvt
LEFT JOIN [mocGroupSetting] AS mgs ON mgs.kioskID = @KIOSKID
	AND mgs.kioskSiteUUID = pvt.kioskSiteUUID
WHERE mgs.mgsID IS NULL;

IF (@DEBUG = 1)
BEGIN

SELECT [mgsID]
      ,[mgsRequesterID]
      ,[mgsApproverID]
      ,[mgsAdministratorID]
      ,[mgsOwnerID]
      ,[mgsAddedUTC]
      ,[mgsAddedBy]
      ,[mgsIsActive]
      ,[kioskID]
      ,[kioskSiteUUID]
      ,[mgsDeactivateUTC]
      ,[mgsDeactivateBy]
      ,[mgsMocSelectNarrative]
      ,[mgsUsesLongReports]
      ,[mgsUsesOpenStatus]
  FROM [dbo].[mocGroupSetting]
END

PRINT 'Group assigned to MOC successfully!';

PRINT 'Attempt to enable approver by location';

-- Ensure kbcid is enable
INSERT INTO [dbo].[kioskAccessControlFeature](
[kioskID],[kioskSiteUUID]
,[kbcID]
,[kacfIsActive]
,[kacfCreateBy],[kacfCreateUTC]
)
SELECT @KIOSKID,ks.kioskSiteUUID
,kb.kbcID
,b.isActive
,0,GETUTCDATE()
FROM #MOC_BREADCRUMBS AS b
LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kb ON kb.kbcSection = b.section COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kb.kbcPage = b.page COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kb.kaID = b.moduleid
FULL OUTER JOIN kioskSite AS ks ON ks.kioskSiteUUID IS NOT NULL
LEFT JOIN [kioskAccessControlFeature] AS kacf ON kacf.kbcID = kb.kbcID
	AND kacf.kioskID = @KIOSKID
	AND kacf.kacfIsActive = b.isActive
	AND kacf.kacfDeactivateUTC IS NULL
WHERE kacf.kacfID IS NULL;

--Ensure group access is enable for admin
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
FROM #MOC_BREADCRUMBS AS b
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

PRINT 'Approver by location enabled successfully!';


-- Ensure super user is added to administration
PRINT 'Attempting adding super user to MOC Administration...';

INSERT INTO [dbo].[kioskUserAccessControlGroupMembership](
  [kioskID],[kioskSiteUUID]
  ,[kuID],[kacgID],[kuacgmIsActive]
  ,[kuacgmCreateBy],[kuacgmCreateUTC]
)
SELECT @KIOSKID,kacg.kioskSiteUUID
,ku.kuID,kacg.kacgID,1
,0,GETUTCDATE()
FROM kioskUser AS ku
FULL OUTER JOIN kioskAccessControlGroup AS kacg ON kacg.kacgName = @MOC_ADMINISTRATOR
LEFT JOIN kioskUserAccessControlGroupMembership AS kuacgm ON kuacgm.kioskID = @KIOSKID
	AND kuacgm.kioskSiteUUID = kacg.kioskSiteUUID
	AND kuacgm.kuID = ku.kuID
	AND kuacgm.kacgID = kacg.kacgID
WHERE ku.kuIsSuperuser = 1
	AND kuacgm.kuacgmID IS NULL;

PRINT 'Super added to MOC Administration group successfully!';
