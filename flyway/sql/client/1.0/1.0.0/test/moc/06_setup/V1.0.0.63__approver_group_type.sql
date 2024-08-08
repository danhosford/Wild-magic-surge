SET NOCOUNT ON;

DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

DECLARE @approver_groups TABLE(
	[name] VARCHAR(255) NOT NULL
);

DECLARE @accounts TABLE(
	[email] VARCHAR(255) NOT NULL
);

INSERT INTO @accounts ([email])
VALUES ('ehs.manager@onelooksystems.com');

INSERT INTO @approver_groups ([name])
VALUES ('EHS Manager');

INSERT INTO [dbo].[mocReferenceApproverType] ( [mratName], [mratIsActive], [kioskSiteUUID], [kioskID])
SELECT [group].[name],[site].[kioskSiteIsActive],[site].[kioskSiteUUID],[site].[kioskID]
FROM  @approver_groups AS [group]
FULL OUTER JOIN [dbo].[kioskSite] AS [site]
	ON [site].[kioskSiteUUID] IS NOT NULL
	AND [site].[kioskSiteIsActive] = 1
LEFT JOIN [dbo].[mocReferenceApproverType] AS [existing]
	ON [existing].[kioskID] = [site].[kioskID]
	AND [existing].[kioskSiteUUID] = [site].[kioskSiteUUID]
	AND [existing].[mratName] = [group].[name]
WHERE [existing].[mratID] IS NULL;

PRINT 'Provide site access to account';

INSERT INTO [dbo].[kioskUserSite]([kioskID],[kioskSiteUUID]
	,[kuID],[kioskUserSiteIsActive]
	,[kioskUserSiteCreateBy],[kioskUserSiteCreateUTC]
)
SELECT [user].[kioskid],[siteserved].[kioskSiteUUID]
,[user].[kuid],[siteserved].[kioskSiteIsActive]
,0,GETUTCDATE()
FROM @accounts AS [approver]
INNER JOIN [dbo].[kioskUser] AS [user]
	ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuemailN])) = [approver].[email]
FULL OUTER JOIN [dbo].[kioskSite] AS [siteserved]
	ON [siteserved].[kioskid] = [user].[kioskid]
	AND [siteserved].[kioskSiteIsActive] = 1
LEFT JOIN [dbo].[kioskUserSite] AS [existing]
	ON [existing].[kioskid] = [user].[kioskid]
	AND [existing].[kioskSiteUUID] = [siteserved].[kioskSiteUUID]
	AND [existing].[kuid] = [user].[kuid]
WHERE [existing].[kioskUserSiteID] IS NULL
;
PRINT 'Site access to account successfull!';

PRINT 'Attempt to add accounts to groups membership...';

INSERT INTO [kioskUserAccessControlGroupMembership] (
[kioskID],[kioskSiteUUID],[kuID]
,[kacgID],[kuacgmIsActive]
,[kuacgmCreateBy],[kuacgmCreateUTC]
)
SELECT [group].[kioskid],[group].[kioskSiteUUID],[user].[kuid]
,[group].[kacgID],[group].[kacgIsActive]
,0,GETUTCDATE()
FROM @accounts AS [approver]
INNER JOIN [dbo].[kioskUser] AS [user]
	ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuemailN])) = [approver].[email]
INNER JOIN [dbo].[kioskUserSite] AS [siteserved]
	ON [siteserved].[kioskid] = [user].[kioskid]
	AND [siteserved].[kuid] = [user].[kuid]
	AND [siteserved].[kioskUserSiteIsActive] = 1
INNER JOIN [dbo].[mocGroupSetting] AS [mocsetting]
	ON [mocsetting].[kioskid] = [siteserved].[kioskid]
	AND [mocsetting].[kioskSiteUUID] = [siteserved].[kioskSiteUUID]
	AND [mocsetting].[mgsDeactivateUTC] IS NULL
INNER JOIN [dbo].[kioskAccessControlGroup] AS [group]
	ON [group].[kioskid] = [siteserved].[kioskid]
	AND [group].[kioskSiteUUID] = [siteserved].[kioskSiteUUID]
	AND [group].[kacgID] = [mocsetting].[mgsApproverID]
LEFT JOIN [dbo].[kioskUserAccessControlGroupMembership] AS [existing]
	ON [existing].[kioskid] = [group].[kioskid]
	AND [existing].[kioskSiteUUID] = [group].[kioskSiteUUID]
	AND [existing].[kuid] = [user].[kuid]
	AND [existing].[kacgID] = [group].[kacgID]
WHERE [existing].[kuacgmID] IS NULL;

PRINT 'Group membership added successfully!';

PRINT 'Allow EHS Manager to access all sites...';

INSERT INTO [dbo].[mocApproverList] ([kioskID],[kioskSiteUUID],[malIsActive]
 ,[kuPublicKey],[kuID]
 ,[malCreateBy],[malCreateUTC],[malIsDefault])
SELECT [siteserved].[kioskid],[siteserved].[kioskSiteUUID],[siteserved].[kioskUserSiteIsActive]
,[user].[kuPublicKey],[user].[kuid]
,0,GETUTCDATE(),1
FROM [dbo].[kioskUserSite] AS [siteserved]
INNER JOIN [dbo].[kioskUser] AS [user]
	ON [user].[kioskID] = [siteserved].[kioskid]
	AND [user].[kuid] = [siteserved].[kuid]
INNER JOIN @accounts AS [approver]
	ON [approver].[email] = CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuemailN]))
LEFT JOIN [dbo].[mocApproverList] AS [existing]
	ON [existing].[kioskid] = [siteserved].[kioskid]
	AND [existing].[kioskSiteUUID] = [siteserved].[kioskSiteUUID]
	AND [existing].[kuPublicKey] = [user].[kuPublicKey]
WHERE [existing].[malID] IS NULL;

INSERT INTO [dbo].[mocApproverType](
[kioskID],[kioskSiteUUID]
,[matIsActive],[malID],[mratID]
)
SELECT [approver].[kioskid],[approver].[kioskSiteUUID]
,[approver].[malIsActive],[approver].[malID],[registeredtype].[mratID]
FROM [dbo].[mocApproverList] AS [approver]
INNER JOIN [dbo].[kioskUser] AS [user]
	ON [user].[kioskid] = [approver].[kioskid]
	AND [user].[kuPublicKey] = [approver].[kuPublicKey]
INNER JOIN @accounts AS [account]
	ON [account].[email] = CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuemailN]))
FULL OUTER JOIN @approver_groups AS [group]
	ON [group].[name] IS NOT NULL
INNER JOIN [dbo].[mocReferenceApproverType] AS [registeredtype]
	ON [registeredtype].[kioskid] = [approver].[kioskid]
	AND [registeredtype].[kioskSiteUUID] = [approver].[kioskSiteUUID]
	AND [registeredtype].[mratName] = [group].[name]
LEFT JOIN [dbo].[mocApproverType] AS [existing]
	ON [existing].[kioskid] = [approver].[kioskid]
	AND [existing].[kioskSiteUUID] = [approver].[kioskSiteUUID]
	AND [existing].[malid] = [approver].[malid]
	AND [existing].[mratID] = [registeredtype].[mratID]
WHERE [existing].[matID] IS NULL;

PRINT 'EHS Manager sites access successfull!';
