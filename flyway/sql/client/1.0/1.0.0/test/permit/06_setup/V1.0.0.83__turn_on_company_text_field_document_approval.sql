-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 29/09/2021
-- Description: Change Company from dropdown to textfield on Tatooine when creating documents.
-- CHANGELOG:
-- ==========================================================
SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

PRINT 'Create @setting Variable Table'

DECLARE @setting TABLE(
[kioskID] INT NOT NULL,
[site] VARCHAR(255),
[companyDropdown] BIT NOT NULL DEFAULT 1
);

INSERT INTO @setting
VALUES
(@KIOSKID, 'Tatooine', 0)
;

UPDATE [documentApprovalGroupSetting]
SET [documentApprovalGroupSetting].[dagsCD] = [setting].[companyDropdown]
FROM [dbo].[documentApprovalGroupSetting] AS [documentApprovalGroupSetting]
INNER JOIN [dbo].[kioskSite] AS [site]
	ON [site].[kioskID] = [documentApprovalGroupSetting].[kioskID]
	AND [site].[kioskSiteUUID] = [documentApprovalGroupSetting].kioskSiteUUID
INNER JOIN @setting AS [setting]
	ON [setting].[kioskID] = [site].[kioskID]
	AND [setting].[site] = [site].[kioskSiteName]
WHERE [documentApprovalGroupSetting].[dagsIsActive] = 1
AND [documentApprovalGroupSetting].[dagsCD] = 1
