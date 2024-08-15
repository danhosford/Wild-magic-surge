-- ==========================================================
-- Author:      Shane Gibbons
-- Create date: 14/01/2021
-- Description: Add requirement to permit
-- CHANGELOG:
-- ==========================================================
SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

PRINT 'Create a temp table for requirement...';

DECLARE @requirement TABLE (
  [permitName] VARCHAR(1000) NOT NULL,
  [name] VARCHAR(1000) NOT NULL,
  [site] VARCHAR(1000) NOT NULL,
  [active] BIT NOT NULL DEFAULT 1,
  [createDate] DATETIME NOT NULL,
  [createdBy] INT NOT NULL,
  [pfFieldValue] INT NOT NULL,
  [prType] INT NOT NULL,
  [prcID] INT NOT NULL,
  [pfID] INT NOT NULL
);

PRINT 'Insert values into the requirement temp table...';

INSERT INTO @requirement
VALUES
('Requirement Permit','Sample Safety Requirement', 'Ireland', 1, GETUTCDATE(), 0, 1, 1,0, 0)
,('Requirement Permit','Sample PPE Requirement', 'Ireland', 1, GETUTCDATE(), 0, 1, 3,0, 0)
,('Requirement Permit','Sample Documentation Requirement', 'Ireland', 1, GETUTCDATE(), 0, 1, 4,0, 0)
,('Requirement Permit','Sample Environmental Requirement', 'Ireland', 1, GETUTCDATE(), 0, 1, 5,0, 0)

PRINT 'Insert values into the permitRequirement table...';

INSERT INTO [dbo].[permitRequirement]
        ([prcID],
        [kioskID],
        [pfID],
        [prRequirement],
        [prType],
        [pfFieldValue],
        [ptID],
        [prIsActive],
        [kuCreateBy],
        [kuCreateUTC],
        [kioskSiteUUID])
SELECT  [requirement].[prcID],
        @KIOSKID,
        [requirement].[pfID],
        [requirement].[name],
        [requirement].[prType],
        [requirement].[pfFieldValue],
        [permitType].[ptID],
        [requirement].[active],
        [requirement].[createdBy],
        [requirement].[createDate],
        [site].[kioskSiteUUID]
FROM    @requirement AS [requirement]
INNER JOIN [dbo].[kioskSite] AS [site]
  ON  [site].[kioskSiteName] = [requirement].[site]
  AND [site].[kioskID] = @KIOSKID
INNER JOIN [dbo].[permitType] AS [permitType]
  ON [site].[kioskSiteUUID] = [permitType].[kioskSiteUUID]
  AND [permitType].[kioskID] = @KIOSKID
  AND [permitType].[name] = [requirement].[permitName]
LEFT JOIN [dbo].[permitRequirement] AS [permitRequirement]
  ON [permitRequirement].[ptID] = [permitType].[ptID]
  AND [permitRequirement].[prRequirement] = [requirement].[name]
  AND [permitRequirement].[kuDeactivateUTC] IS NULL
  AND [permitRequirement].[kuDeactivateBy] IS NULL
WHERE [permitRequirement].[ptID] IS NULL