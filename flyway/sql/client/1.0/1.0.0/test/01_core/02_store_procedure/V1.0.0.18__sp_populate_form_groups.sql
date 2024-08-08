-- ==========================================================================================
-- Author:      Shane Gibbons
-- Create date: 17/12/2019
-- Description: 
-- * 11/12/2019 - SG - Created
-- ==========================================================================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.populate_form_groups(
  @formname VARCHAR(255)
  ,@creategroupname VARCHAR(255)
  ,@editgroupname VARCHAR(255)
  ,@moduleprefix VARCHAR(255)
  ,@kioskid INT
)
AS
BEGIN

  DECLARE @formGroup TABLE(
    [formname] VARCHAR(255) NOT NULL
    ,[creategroup] INT NOT NULL
    ,[editgroup] INT NOT NULL
    ,[site] VARCHAR(255) COLLATE Latin1_General_CI_AS
  );


  INSERT INTO @formGroup (
    [formname],[creategroup],[editgroup],[site]
  )
  SELECT
    @formname, [riskCreateGroup].[kacgID], [riskEditGroup].[kacgID], [ksa].kioskSiteUUID
  FROM [v3_sp].[dbo].[kioskApplications] AS [app]
    LEFT JOIN [dbo].[kioskSiteApplication] AS [ksa] ON [ksa].[kaID] = [app].[kaID] AND [ksa].[ksaDeactivateUTC] IS NULL
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [riskCreateGroup]
      ON [riskCreateGroup].[kacgName] = @creategroupname
      AND [riskCreateGroup].[kioskSiteUUID] = [ksa].[kioskSiteUUID]
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [riskEditGroup]
      ON [riskEditGroup].[kacgName] = @editgroupname
      AND [riskEditGroup].[kioskSiteUUID] = [ksa].[kioskSiteUUID]
  WHERE [app].[kaPrefix] = @moduleprefix
  
  
  UPDATE [dbo].[formType]
  SET [createGroupID] = [formGroup].[creategroup]
      ,[editGroupID] = [formGroup].[editgroup]
  FROM [dbo].[formType]
  INNER JOIN @formGroup AS [formGroup] 
    ON [formGroup].[formname] = [dbo].[formType].[formName]
  WHERE [dbo].[formType].[formName] = [formGroup].[formname]
  AND [dbo].[formType].[kioskID] = @kioskid
  AND [dbo].[formType].[kioskSiteUUID] = [formGroup].[site]
  AND [dbo].[formType].[formIsActive] = 1

END
GO
