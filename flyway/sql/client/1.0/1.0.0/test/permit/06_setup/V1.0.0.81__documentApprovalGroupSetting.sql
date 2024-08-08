-- ==========================================================
-- Author:      Shane Gibbons
-- Create date: 10/03/2021
-- Description: Add Document Approval Group Settings across multiple sites
-- CHANGELOG:
-- ==========================================================
SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

PRINT 'Create a temp table for Document Approval Group settings...';

DECLARE @documentGroupSettings TABLE (
  [dagID1] INT NOT NULL,
  [dagID2] INT NULL,
  [dagsAddedUTC] DATETIME NOT NULL,
  [dagsAddedBy] INT NOT NULL,
  [dagsIsActive] BIT NOT NULL,
  [kioskID] INT NOT NULL,
  [dagsIsMultiApprover] BIT NULL,
  [dagsDeactivateUTC] DATETIME NULL,
  [dagsDeactivateBy] INT NULL,
  [documentApprovalGroupSettingDisplayNumber] BIT NULL,
  [dagsDT] BIT NOT NULL,
  [dagsCD] BIT NOT NULL,
  [dagsEDOW] BIT NOT NULL,
  [dagsED] BIT NOT NULL,
  [dagsESA] BIT NOT NULL,
  [documentApprovalGroupSettingTypeLevel] INT NOT NULL
);


PRINT 'Insert values into the documentGroupSettings temp table...';

INSERT INTO @documentGroupSettings 
VALUES
(2, 0, GETUTCDATE(), 5, 1, @KIOSKID, 0, NULL, NULL, NULL, 0, 1, 1, 1, 0, 0)


PRINT 'Deactivate old settings...';

UPDATE [dbo].[documentApprovalGroupSetting]
SET [dagsIsActive] = 0,
    [dagsDeactivateUTC] = GETUTCDATE(),
    [dagsDeactivateBy] = 0
WHERE [dagsIsActive] = 1
AND [dagsAddedUTC] <= GETUTCDATE() 


PRINT 'Insert values into the documentApprovalGroupSetting table...';

INSERT INTO [dbo].[documentApprovalGroupSetting]
        ([dagID1],
        [dagID2],
        [dagsAddedUTC],
        [dagsAddedBy],
        [dagsIsActive],
        [kioskID],
        [kioskSiteUUID],
        [dagsIsMultiApprover],
        [dagsDeactivateUTC],
        [dagsDeactivateBy],
        [documentApprovalGroupSettingDisplayNumber],
        [dagsDT],
        [dagsCD],
        [dagsEDOW],
        [dagsED],
        [dagsESA],
        [documentApprovalGroupSettingTypeLevel])
SELECT  [documentGroupSetting].[dagID1],
        [documentGroupSetting].[dagID2],
        [documentGroupSetting].[dagsAddedUTC],
        [documentGroupSetting].[dagsAddedBy],
        [documentGroupSetting].[dagsIsActive],
        [documentGroupSetting].[kioskID],
        [site].[kioskSiteUUID],
        [documentGroupSetting].[dagsIsMultiApprover],
        [documentGroupSetting].[dagsDeactivateUTC],
        [documentGroupSetting].[dagsDeactivateBy],
        [documentGroupSetting].[documentApprovalGroupSettingDisplayNumber],
        [documentGroupSetting].[dagsDT],
        [documentGroupSetting].[dagsCD],
        [documentGroupSetting].[dagsEDOW],
        [documentGroupSetting].[dagsED],
        [documentGroupSetting].[dagsESA],
        [documentGroupSetting].[documentApprovalGroupSettingTypeLevel]
FROM    @documentGroupSettings AS [documentGroupSetting]
INNER JOIN [dbo].[kioskSite] AS [site]
  ON [site].[kioskID] = [documentGroupSetting].[kioskID]
LEFT JOIN [dbo].[documentApprovalGroupSetting] AS [documentApprovalGroupSetting]
  ON [documentApprovalGroupSetting].[dagID1] = [documentGroupSetting].[dagID1]
  AND [documentApprovalGroupSetting].[dagID2] = [documentGroupSetting].[dagID2]
  AND [documentApprovalGroupSetting].[dagsAddedUTC] = [documentGroupSetting].[dagsAddedUTC]
  AND [documentApprovalGroupSetting].[dagsAddedBy] = [documentGroupSetting].[dagsAddedBy]
  AND [documentApprovalGroupSetting].[dagsIsActive] = [documentGroupSetting].[dagsIsActive]
  AND [documentApprovalGroupSetting].[kioskID] = [documentGroupSetting].[kioskID]
  AND [documentApprovalGroupSetting].[kioskSiteUUID] = [site].[kioskSiteUUID]
  AND [documentApprovalGroupSetting].[dagsIsMultiApprover] = [documentGroupSetting].[dagsIsMultiApprover]
  AND [documentApprovalGroupSetting].[dagsDeactivateUTC] = [documentGroupSetting].[dagsDeactivateUTC]
  AND [documentApprovalGroupSetting].[dagsDeactivateBy] = [documentGroupSetting].[dagsDeactivateBy]
  AND [documentApprovalGroupSetting].[documentApprovalGroupSettingDisplayNumber] = [documentGroupSetting].[documentApprovalGroupSettingDisplayNumber]
  AND [documentApprovalGroupSetting].[dagsDT] = [documentGroupSetting].[dagsDT]
  AND [documentApprovalGroupSetting].[dagsCD] = [documentGroupSetting].[dagsCD]
  AND [documentApprovalGroupSetting].[dagsEDOW] = [documentGroupSetting].[dagsEDOW]
  AND [documentApprovalGroupSetting].[dagsED] = [documentGroupSetting].[dagsED]
  AND [documentApprovalGroupSetting].[dagsESA] = [documentGroupSetting].[dagsESA]
  AND [documentApprovalGroupSetting].[documentApprovalGroupSettingTypeLevel] = [documentGroupSetting].[documentApprovalGroupSettingTypeLevel]
WHERE [documentApprovalGroupSetting].[dagsID] IS NULL
