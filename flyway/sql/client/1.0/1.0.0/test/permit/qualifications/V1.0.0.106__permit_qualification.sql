-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 12/05/2020
-- Description: Add qualification to permit
-- CHANGELOG:
-- 22/08/2020 - AT - Switch to name for permit type
-- ==========================================================
SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

PRINT 'Create a temp table for qualification...';

DECLARE @qualification TABLE (
  [permitName] VARCHAR(1000) NOT NULL,
  [qualification] VARCHAR(1000) NOT NULL,
  [site] VARCHAR(1000) NOT NULL,
  [active] BIT NOT NULL DEFAULT 1,
  [createDate] DATETIME NOT NULL,
  [createdBy] INT NOT NULL,
  [pfFieldValue] INT NOT NULL,
  [prType] INT NOT NULL,
  [prcID] INT NOT NULL,
  [pfID] INT NOT NULL
);

PRINT 'Insert values into the qualification temp table...';

INSERT INTO @qualification 
VALUES
('Extendable','Sample Qualification', 'Ireland', 1, GETUTCDATE(), 0, 1, 2,0, 0)

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
SELECT  [qualification].[prcID],
        @KIOSKID,
        [qualification].[pfID],
        [contractorQualificationType].[cqtID],
        [qualification].[prType],
        [qualification].[pfFieldValue],
        [permitType].[ptID],
        [qualification].[active],
        [qualification].[createdBy],
        [qualification].[createDate],
        [site].[kioskSiteUUID]
FROM    @qualification AS [qualification]
INNER JOIN [dbo].[kioskSite] AS [site]
  ON  [site].[kioskSiteName] = [qualification].[site]
  AND [site].[kioskID] = @KIOSKID
INNER JOIN [dbo].[contractorQualificationType] AS [contractorQualificationType]
  ON [site].[kioskSiteUUID] = [contractorQualificationType].[kioskSiteUUID]
  AND [contractorQualificationType].[kioskID] = @KIOSKID
  AND [contractorQualificationType].[cqtName] = [qualification].[qualification]
INNER JOIN [dbo].[permitType] AS [permitType]
  ON [site].[kioskSiteUUID] = [permitType].[kioskSiteUUID]
  AND [permitType].[kioskID] = @KIOSKID
  AND [permitType].[name] = [qualification].[permitName]
LEFT JOIN [dbo].[permitRequirement] AS [permitRequirement]
  ON [permitRequirement].[ptID] = [permitType].[ptID]
  AND [permitRequirement].[prRequirement] = CONVERT(VARCHAR(255),[contractorQualificationType].[cqtID])
  AND [permitRequirement].[kuDeactivateUTC] IS NULL
  AND [permitRequirement].[kuDeactivateBy] IS NULL
WHERE [permitRequirement].[ptID] IS NULL
