-- ==========================================================================================
-- Author:      Shane Gibbons
-- Create date: 16/12/2019
-- Description: 
-- * 16/12/2019 - SG - Created
-- * 17/12/2019 - Refactor to use table type and group based on site
-- * 17/12/2019 - Refactor to ensure no duplicate are inserted
-- ==========================================================================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.populate_RISK_groups
(
  @groups test.groups READONLY
)
AS
BEGIN
  
  INSERT INTO [dbo].[riskGroupSetting](
    [kioskID],[kioskSiteUUID]
    ,[ragRequesterID]
    ,[ragAdministratorID]
    ,[ragTaskOwnerID]
    ,[ragAddedUTC]
    ,[ragAddedBy]
    ,[ragIsActive]
  )
  SELECT [risk].[kioskid],[risk].[kioskSiteUUID]
    ,[risk].[requestor],[risk].[admin],[risk].[taskowner]
    ,GETUTCDATE(),0,1
  FROM (
  SELECT [site].[kioskid],[site].[kioskSiteUUID]
    ,[group].[kacgid] AS [group],[permission].[type] AS [type]
  FROM (
    SELECT [site],[group],[type]
    FROM @groups AS [group]
    UNPIVOT(
      [group] FOR [type] IN ([requestor],[admin],[taskowner])
    ) AS [permission]
  ) AS [permission]
  INNER JOIN [kioskSite] AS [site]
    ON [site].[kioskSiteName] = [permission].[site]
  INNER JOIN [kioskAccessControlGroup] AS [group]
    ON [group].[kacgName] = [permission].[group]
    AND [group].[kioskSiteUUID] = [site].[kioskSiteUUID]
  ) AS [permission]
  PIVOT (
    MAX([permission].[group])
    FOR [permission].[type] IN ([requestor],[admin],[taskowner])
  ) AS [risk]
  LEFT JOIN [dbo].[riskGroupSetting] AS [registered]
  ON [registered].[kioskid] = [risk].[kioskID]
  AND [registered].[kioskSiteUUID] = [risk].[kioskSiteUUID]
  WHERE [registered].[ragID] IS NULL;

END