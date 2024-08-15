-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 14/09/2021
-- Description: Configure Contractor System To Use this will allow for us to turn this on for other sites by simply adding new entry into variable table insert
-- CHANGELOG:
-- ==========================================================

SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

PRINT 'Creating the kioskSite Variable Table';

DECLARE @kioskSite TABLE (
  [kioskID] INT NOT NULL,
  [kioskSite] VARCHAR(255),
  [active] BIT NOT NULL DEFAULT 1,
  [createDate] DATETIME NOT NULL,
  [createdBy] INT NOT NULL,
  [contractorCanSeePermits] INT NOT NULL
);

PRINT 'Inserting data into the kioskSite Variable Table';

INSERT INTO @kioskSite 
VALUES
(@KIOSKID, 'Ireland', 1, GETUTCDATE(), 0, 4)
;

PRINT 'Inserting data into the kioskSite Variable Table';

UPDATE [kioskSite]
SET [kioskSite].[contractorCanSeePermits] = [ks].[contractorCanSeePermits],
    [kioskSite].[kioskSiteCreateUTC] = [ks].[createDate],
    [kioskSite].[kioskSiteCreateBy]= [ks].[createdBy]
FROM [dbo].[kioskSite] AS [kioskSite]
INNER JOIN @kioskSite AS [ks]
    ON [ks].[kioskID] = [kioskSite].[kioskID]
    AND [ks].[active] = [kioskSite].[kioskSiteIsActive]
    AND [ks].[kioskSite] = [kioskSite].[kioskSiteName]

SET NOCOUNT OFF;