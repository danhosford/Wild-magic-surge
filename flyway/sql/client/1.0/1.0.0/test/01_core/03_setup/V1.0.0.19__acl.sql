/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 14/01/2019 11:13

- Enable all super user breadcrumb for super user
*/

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

PRINT 'Attempt enable super user features on all sites...';

INSERT INTO [dbo].[kioskAccessControlFeature] (
  [kbcID],[kioskID],[kioskSiteUUID]
  ,[kacfIsActive],[kacfCreateBy],[kacfCreateUTC]
)
SELECT kbc.kbcID,@KIOSKID,ks.kioskSiteUUID
,1,0,GETUTCDATE()
  FROM [v3_sp].[dbo].[kioskBreadcrumb] AS kbc
  FULL OUTER JOIN kioskSite AS ks ON ks.kioskSiteUUID IS NOT NULL
  LEFT JOIN kioskAccessControlFeature AS kacf ON kacf.kbcID = kbc.kbcID
	AND kacf.kacfIsActive = 1
	AND kacf.kacfDeactivateUTC IS NULL
	AND kacf.kioskSiteUUID = ks.kioskSiteUUID
	AND kacf.kioskID = @KIOSKID
  WHERE kbc.kbcIsSuperuserOnly = 1
   AND kacf.kacfID IS NULL;

PRINT 'Super user features enables on all sites successfully!';

PRINT 'Attempt add super user to admin groups...';

INSERT INTO [kioskUserAccessControlGroupMembership] (
[kioskID],[kioskSiteUUID],[kuID]
,[kacgID],[kuacgmIsActive],[kuacgmCreateBy],[kuacgmCreateUTC]
)
SELECT @KIOSKID,kacg.kioskSiteUUID,ku.kuid
,kacg.kacgID,1,0,GETUTCDATE()
FROM kioskUser AS ku
FULL OUTER JOIN kioskAccessControlGroup AS kacg ON kacg.kacgName LIKE '%admin%'
	AND kacg.kacgName NOT LIKE 'CP System Admin - outdated'
	AND kacg.kacgName NOT LIKE 'CP Company Admin'
LEFT JOIN kioskUserAccessControlGroupMembership AS kuacgm ON kuacgm.kacgID = kacg.kacgID
	AND kuacgm.kioskID = @KIOSKID
	AND kuacgm.kioskSiteUUID = kacg.kioskSiteUUID
	AND kuacgm.kuID = ku.kuID
	AND kuacgm.kacgID = kacg.kacgID
	AND kuacgm.kuacgmIsActive = 1
	AND kuacgm.kuacgmDeactivateUTC IS NULL
WHERE ku.kuIsSuperuser = 1
	AND kuacgm.kuacgmID IS NULL;

PRINT 'Super user added to admin groups successfully!';

SET NOCOUNT OFF;