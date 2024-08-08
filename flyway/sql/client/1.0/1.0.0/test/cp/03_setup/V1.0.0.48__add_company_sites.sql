-- ================================================================================
-- Author:      Jamie Conroy
-- Create date: 15/09/202021
-- Description: Put onelook systems onto the US Central site
-- ================================================================================

SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

PRINT 'Creating the kioskSite Variable Table';

DECLARE @companySite TABLE (
  [kioskID] INT NOT NULL,
  [kioskSite] VARCHAR(255),
  [company] VARCHAR(255),
  [active] BIT NOT NULL DEFAULT 1,
  [createDate] DATETIME NOT NULL,
  [createdBy] INT NOT NULL
);

PRINT 'Inserting data into the kioskSite Variable Table';

INSERT INTO @companySite 
VALUES
(@KIOSKID, 'US Central','OneLook Systems', 1, GETUTCDATE(), 0)
;

PRINT 'Inserting data into the cpCompanySites Table';

INSERT INTO [cpCompanySites] (
            [cpCompanyID],
            [cpCompanyVersion],
            [kioskSiteID],
            [kioskSiteUUID],
            [kioskID])
SELECT      [company].[cpCompanyID],
            [company].[cpCompanyVersion],
            [site].[kioskSiteID],
            [site].[kioskSiteUUID],
            [companySite].[kioskID]
FROM @companySite AS [companySite]
INNER JOIN cpCompany AS [company]
  ON [company].[kioskID] = [companySite].[kioskID]
INNER JOIN kioskSite AS [site]
  ON [site].[kioskSiteName] = [companySite].[kioskSite]
  AND [site].[kioskID] = [companySite].[kioskID]
WHERE [company].[cpCompanyVersion]= (SELECT MAX([cpCompanyVersion])
					FROM [dbo].[cpCompany] AS [version]
					WHERE CONVERT(VARCHAR(MAX),DECRYPTBYPASSPHRASE(@PASS,[version].[cpCompanyName])) = [companySite].[company])

SET NOCOUNT OFF;