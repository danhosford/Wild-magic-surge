-- =========================================================================================================
-- Author:      Alexandre Tran
-- Create date: 07/11/2018
-- CHANGELOG:
-- 30/03/2020 - JC - Script changed to include workflow controller group 
-- 22/04/2020 - SG - Adding new insert to update the access for COSHH Admin
-- 02/07/2020 - SG - Adding CP System Admin and CP Company Admin to the Groups list for all sites
-- 15/09/2020 - AT - Insert first & last name in new column
-- 02/11/2020 - JC - Ensuring Contractor Creator is set up on all sites
-- 26/11/2020 - JC - Ensuring Visitor User groups are set up on all sites
-- 25/11/2020 - SG - Ensuring COSHH users are set up on all sites
-- 13/01/2020 - AT - Ensure that group ACL is tied to module
-- 28/09/2021 - SG - Adding new Permit Receiver user group
-- =========================================================================================================

SET NOCOUNT ON;
DECLARE @DEBUG BIT = 1;

DECLARE @KIOSKID INT = CONVERT(INT,SUBSTRING(db_name(),5,4));
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';
-- Grab default site
DECLARE @DEFAULT_SITEUUID VARCHAR(255) = (SELECT TOP 1 ks.kiosksiteuuid FROM kioskSite AS ks ORDER BY ks.kioskSiteID ASC);

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

DECLARE @APP_PERMIT_ID INT = (SELECT TOP 1 ka.kaid FROM v3_sp.dbo.kioskApplications AS ka WHERE ka.kaPrefix = 'Permit');
DECLARE @APP_CP_ID INT = (SELECT TOP 1 ka.kaid FROM v3_sp.dbo.kioskApplications AS ka WHERE ka.kaPrefix = 'cp');
DECLARE @APP_VISITOR_ID INT = (SELECT TOP 1 ka.kaid FROM v3_sp.dbo.kioskApplications AS ka WHERE ka.kaPrefix = 'visitor');
DECLARE @APP_COSHH_ID INT = (SELECT TOP 1 ka.kaid FROM v3_sp.dbo.kioskApplications AS ka WHERE ka.kaPrefix = 'coshh');
--DECLARE @APP_ED_ID INT = (SELECT TOP 1 ka.kaid FROM v3_sp.dbo.kioskApplications AS ka WHERE ka.kaPrefix = 'ed');

-- Change name to be able to build email
UPDATE kioskAccessControlGroup
  SET kacgName = 'Create Permit - Contractor'
  WHERE kacgID = 4;

UPDATE kioskAccessControlGroup
  SET kacgName = 'Course Standard User - Contractor'
  WHERE kacgID = 106;

-- Enable can see user 
-- TODO: Refactor to ensure all group have correct permission
DECLARE @KBC_CAN_SEE_USER INT = 3125;
INSERT INTO [dbo].[kioskAccessControlPage] (
  [kioskID],[kioskSiteUUID]
  ,[kbcid],[kacgPublickey]
  ,[kacpCreateBy],[kacpCreateUTC]
  ,[kacpIsActive])
SELECT [group].[kioskID],[group].[kioskSiteUUID]
,@KBC_CAN_SEE_USER,[group].[kacgPublicKey]
,0,GETUTCDATE()
,1
FROM [dbo].[kioskAccessControlGroup] AS [group]
LEFT JOIN [dbo].[kioskAccessControlPage] AS [acl]
  ON [acl].[kacgPublicKey] = [group].[kacgPublicKey]
  AND [acl].[kbcID] = @KBC_CAN_SEE_USER
  AND [acl].[kioskID] = [group].[kioskID]
  AND [acl].[kioskSiteUUID] = [group].[kioskSiteUUID]
  AND [acl].[kacpDeactivateUTC] IS NULL
WHERE kacgName = 'CP System Admin'
  AND [acl].[kacpID] IS NULL;
  
-- Enable Coshh Approver Edit
DECLARE @KBC_COSHH_APPROVER_EDIT INT = 40064;
INSERT INTO [dbo].[kioskAccessControlPage] (
  [kioskID],[kioskSiteUUID]
  ,[kbcid],[kacgPublickey]
  ,[kacpCreateBy],[kacpCreateUTC]
  ,[kacpIsActive])
SELECT [group].[kioskID],[group].[kioskSiteUUID]
,@KBC_COSHH_APPROVER_EDIT,[group].[kacgPublicKey]
,0,GETUTCDATE()
,1
FROM [dbo].[kioskAccessControlGroup] AS [group]
LEFT JOIN [dbo].[kioskAccessControlPage] AS [acl]
  ON [acl].[kacgPublicKey] = [group].[kacgPublicKey]
  AND [acl].[kbcID] = @KBC_COSHH_APPROVER_EDIT
  AND [acl].[kioskID] = [group].[kioskID]
  AND [acl].[kioskSiteUUID] = [group].[kioskSiteUUID]
  AND [acl].[kacpDeactivateUTC] IS NULL
WHERE kacgName = 'COSHH Administrator'
  AND [acl].[kacpID] IS NULL;

IF OBJECT_ID('tempdb..#GROUPS') IS NOT NULL DROP TABLE #GROUPS;
CREATE TABLE #GROUPS (
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255) NOT NULL,
  appid INT NOT NULL,
  enable BIT NOT NULL DEFAULT 1,
  employeeOnly BIT NOT NULL,
  externalContractor BIT NOT NULL
);

INSERT INTO #GROUPS (name,description,appid,employeeOnly,externalcontractor)
VALUES ('Create Permit','Access Group for permission to create permit',@APP_PERMIT_ID,1,0),
('Approve Permit','Access Group for permission to approve permit',@APP_PERMIT_ID,1,0),
('Permit Receiver','Access Group for Permit Receiver permissions in ',@APP_PERMIT_ID,1,0),
('Workflow Controller','Workflow Controller Group',@APP_PERMIT_ID,1,0),
('CP System Admin','Access Group for admin permissions in CP',@APP_CP_ID,1,0),
('CP Company Admin','Access Group for company admin permissions in CP',@APP_CP_ID,1,0),
('Contractor Creator','Contractor Access Group for permission to create permit',@APP_PERMIT_ID,0,1),
('Visitor Administrator','Access Group for visitor admin permissions in Visitor',@APP_VISITOR_ID,1,0),
('Visitor Security','Access Group for visitor security permissions in Visitor',@APP_VISITOR_ID,1,0),
('Visitor Booker','Access Group for visitor booker permissions in Visitor',@APP_VISITOR_ID,1,0),
('COSHH Administrator','Access Group for admin permissions in COSHH',@APP_COSHH_ID,1,0),
('COSHH Approver','Access Group for approver permissions in COSHH',@APP_COSHH_ID,1,0),
('COSHH Assessor','Access Group for Assessor permissions in COSHH',@APP_COSHH_ID,1,0),
('COSHH Requestor','Access Group for Requestor permissions in COSHH',@APP_COSHH_ID,1,0),
('COSHH View Only','Access Group for View Only permissions in COSHH',@APP_COSHH_ID,1,0)
--,('ED Viewer', 'Access Group for permission to view enterprise dashboard',@APP_ED_ID,1,0)
;

PRINT 'Attempt create additional groups...';

INSERT INTO [kioskAccessControlGroup] (
[kioskID],[kioskSiteUUID],[kacgPublicKey]
,[kaID],[kacgName],[kacgDescription]
,[kacgIsActive]
,[kacgIsEmployeeOnly],[kacgIsExternalContractorOnly]
,[kacgCreateBy],[kacgCreateUTC])
SELECT @KIOSKID,ks.kioskSiteUUID,NEWID()
,g.appid,g.name,g.description
,g.enable
,g.employeeOnly,g.externalContractor
,0,GETUTCDATE()
FROM #GROUPS AS g
FULL OUTER JOIN kioskSite AS ks ON ks.kioskID = @KIOSKID
	AND ks.kioskSiteUUID IS NOT NULL
LEFT JOIN kioskAccessControlGroup AS kacg ON kacg.kacgName = g.name COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kacg.kioskID = @KIOSKID
	AND kacg.kioskSiteUUID = ks.kioskSiteUUID
	AND kacg.kaID = g.appid
	AND kacg.kacgIsEmployeeOnly = g.employeeOnly
	AND kacg.kacgIsExternalContractorOnly = g.externalContractor
WHERE kacg.kacgID IS NULL;

PRINT 'Additional groups added successfully!';

IF OBJECT_ID('tempdb..#GROUPS') IS NOT NULL DROP TABLE #GROUPS;

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

PRINT 'Enable all group'
UPDATE [kioskAccessControlGroup]
SET kacgIsActive = 1
PRINT 'Group enabled!'

-- Remove duplicate group
DELETE
FROM [kioskAccessControlGroup]
WHERE kacgID NOT IN
(
	SELECT MIN(kacgid)
	FROM [kioskAccessControlGroup]
	GROUP BY kacgName,kioskSiteUUID
)

PRINT 'Attempt create user account based on group name...';
INSERT INTO [dbo].[kioskUser](
  [kioskID],[kuIsActive],[kuIsAccountLocked]
  ,[kuCreateBy],[kuCreateUTC]
  ,[kuIsPasswordChangeRequired],[kuPasswordHash],[kuPasswordSalt]
  ,[kuPublicKey],[kuPrivateKey]
  ,[kuIsEmployeeOrExternalContractor],[kuIsSuperuser]
  ,[kuFirstNameN]
  ,[kuLastNameN]
  ,[kuEmailN]
  ,[kuTelephoneN]
  ,[kuJobTitleN]
  ,[firstname]
  ,[lastname]
)
SELECT DISTINCT
-- Account status
@KIOSKID,1,0
-- Creation info
,0,GETUTCDATE()
-- Password setup
,0,@passwordhash,@salt
-- Keys setup
,CONVERT(VARCHAR(MAX),NEWID()),CONVERT(VARCHAR(MAX),NEWID())
,IIF(kacgIsEmployeeOnly = 1, 'Employee','Contractor'),0
-- User info
,ENCRYPTBYPASSPHRASE(@PASS,SUBSTRING(kacg.kacgName, 0, CHARINDEX(' ', kacg.kacgName)))
,ENCRYPTBYPASSPHRASE(@PASS,SUBSTRING(kacg.kacgName, CHARINDEX(' ', kacg.kacgName)  + 1, LEN(kacg.kacgName)))
,ENCRYPTBYPASSPHRASE(@PASS,REPLACE(CONCAT(LOWER(kacg.kacgName),'@onelooksystems.com'),' ','.'))
,ENCRYPTBYPASSPHRASE(@PASS,'555-5555')
,ENCRYPTBYPASSPHRASE(@PASS,'Tester')
,ENCRYPTBYPASSPHRASE(@PASS,CAST(SUBSTRING(kacg.kacgName, 0, CHARINDEX(' ', kacg.kacgName)) AS NVARCHAR(255)))
,ENCRYPTBYPASSPHRASE(@PASS,CAST(SUBSTRING(kacg.kacgName, CHARINDEX(' ', kacg.kacgName)  + 1, LEN(kacg.kacgName)) AS NVARCHAR(255)))
FROM (SELECT DISTINCT kacgName, kacgIsEmployeeOnly FROM kioskAccessControlGroup) AS kacg
LEFT JOIN kioskUser AS ku ON CONVERT(VARCHAR(MAX),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = REPLACE(CONCAT(LOWER(kacg.kacgName),'@onelooksystems.com'),' ','.')
WHERE ku.kuID IS NULL
PRINT 'Group account created successfully!';

PRINT 'Attempt to add test group account to Groups...';

INSERT INTO kioskUserAccessControlGroupMembership
	([kioskID],[kuID],[kacgID],[kuacgmCreateBy],[kuacgmCreateUTC],[kuacgmIsActive],[kioskSiteUUID])
SELECT 
@KIOSKID,ku.kuID,kacg.kacgID,0,GETUTCDATE(),1,kacg.kioskSiteUUID
FROM kioskAccessControlGroup AS kacg
LEFT JOIN kioskUser AS ku ON CONVERT(VARCHAR(MAX),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = REPLACE(CONCAT(LOWER(kacg.kacgName),'@onelooksystems.com'),' ','.')
LEFT JOIN kioskUserAccessControlGroupMembership AS kuacgm ON kuacgm.kuID = ku.kuID
	AND kuacgm.kacgID = kacg.kacgID
  AND kuacgm.kioskSiteUUID = kacg.kioskSiteUUID
  AND kuacgm.kioskID = @KIOSKID
WHERE kuacgm.kuacgmID IS NULL;

PRINT 'Group account added successfully!';

PRINT 'Attempt to provide access group account to sites...';

INSERT INTO kioskUserSite ([kioskID]
      ,[kioskSiteUUID]
      ,[kuID]
      ,[kioskUserSiteIsActive]
      ,[kioskUserSiteCreateBy]
      ,[kioskUserSiteCreateUTC])
SELECT @KIOSKID,kacg.kioskSiteUUID,ku.kuID,1,0,GETUTCDATE()
FROM kioskAccessControlGroup AS kacg
LEFT JOIN kioskUser AS ku ON CONVERT(VARCHAR(MAX),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = REPLACE(CONCAT(LOWER(kacg.kacgName),'@onelooksystems.com'),' ','.')
LEFT JOIN kioskUserSite AS kus ON kus.kuID = ku.kuID
	AND kus.kioskID = @KIOSKID
	AND kus.kioskSiteUUID = kacg.kioskSiteUUID
WHERE kus.kioskUserSiteID IS NULL;

PRINT 'Group account access provided successfully!'

PRINT 'Attempt to provide access to super admin...';
DECLARE @SUFFIX_SUPER_ADMIN_GROUP_NAME VARCHAR(255) = 'Super Admin';
INSERT INTO [kioskAccessControlPage](
[kioskID],[kioskSiteUUID],[kbcID]
,[kacgPublicKey],[kacpIsActive]
,[kacpCreateBy],[kacpCreateUTC]
)
SELECT kacf.kioskID,kacf.kioskSiteUUID,kacf.kbcID
,kacg.kacgPublicKey,1
,0,GETUTCDATE()
FROM kioskAccessControlFeature AS kacf
LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kbc 
  ON kbc.kbcID = kacf.kbcID
  AND kbc.kbcPage NOT IN('IsCompanyAdmin','courseCreate','courseCreateSubmit','courseDetails','courseOverview','courseResources')
FULL OUTER JOIN kioskAccessControlGroup AS kacg ON kacg.kioskID = kacf.kioskID
	AND kacg.kioskSiteUUID = kacf.kioskSiteUUID
	AND LOWER(kacg.kacgName) LIKE CONCAT('%',LOWER(@SUFFIX_SUPER_ADMIN_GROUP_NAME),'%')
	AND kacg.kacgIsEmployeeOnly = 1
	AND kacg.kaid = kbc.kaid
LEFT JOIN kioskAccessControlPage AS kacp ON kacp.kbcID = kacf.kbcID
	AND kacp.kioskID = kacf.kioskID
	AND kacp.kioskSiteUUID = kacf.kioskSiteUUID
	AND kacp.kacgPublicKey = kacg.kacgPublicKey
	AND kacp.kacpIsActive = 1
WHERE kacp.kacpID IS NULL
  AND kacf.kbcID IS NOT NULL
  AND kacg.kacgPublicKey IS NOT NULL
  AND kbc.kbcID IS NOT NULL;

PRINT 'Provide super admin access successfully!';

PRINT 'Attempt add super user to all group...';

INSERT INTO [dbo].[kioskUserAccessControlGroupMembership] (
  [kioskID],[kioskSiteUUID]
  ,[kuID],[kacgID],[kuacgmIsActive]
  ,[kuacgmCreateBy],[kuacgmCreateUTC]
)
SELECT 
  [group].[kioskid],[group].[kioskSiteUUID],
  [user].[kuID],[group].[kacgID],1
  ,0,GETUTCDATE()
FROM [dbo].[kioskAccessControlGroup] AS [group]
FULL OUTER JOIN [dbo].[kioskUser] AS [user]
 ON [user].[kuIsSuperuser] = 1
LEFT JOIN [dbo].[kioskUserAccessControlGroupMembership] AS [membership]
 ON [membership].[kuID] = [user].[kuID]
  AND [membership].[kacgID] = [group].[kacgID]
  AND [membership].[kioskSiteUUID] = [group].[kioskSiteUUID]
  AND [membership].[kioskID] = [group].[kioskID]
WHERE [membership].[kuacgmID] IS NULL
  AND [group].[kacgName] NOT IN('Contractor Portal Admin','CP Company Admin','CP Employee','CP Induction User'
,'CP System Admin - outdated','CP System Admin','Course Admin','Course Standard User - Contractor','Course Standard User');

PRINT 'Super user added successfully to group!';

SET NOCOUNT OFF;