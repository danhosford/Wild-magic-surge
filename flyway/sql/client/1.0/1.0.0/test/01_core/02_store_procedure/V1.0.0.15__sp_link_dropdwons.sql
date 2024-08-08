-- ==========================================================================================
-- Author:      Alexandre Tran
-- Create date: 12/12/2019
-- Description: 
-- * 12/12/2019 - AT - Created
-- * 12/12/2019 - AT - Ensure dependencies is not duplicating
-- ==========================================================================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.link_dropdwons(
  @linkFields test.linkFields READONLY
  ,@kioskid INT
)
AS
BEGIN

  DECLARE @fieldDependencies TABLE(
    [id] INT NOT NULL
    ,[parentid] INT NOT NULL
    ,[valueid] INT NOT NULL
    ,[site] VARCHAR(255) NOT NULL
    ,[mandatory] BIT NOT NULL DEFAULT 1
  );

  INSERT INTO @fieldDependencies(
    [id],[parentid],[valueid],[site],[mandatory]
  )
  SELECT
    [field].[formFieldID],[parent].[formFieldID]
    ,[dropdown].[fddID],[type].[kioskSiteUUID]
    ,[linked].[mandatory]
  FROM [formType] AS [type]
  INNER JOIN (
    SELECT [formname] 
    FROM @linkFields
    GROUP BY [formname]
  ) AS [form]
    ON [form].[formname] = [type].[formname]
  INNER JOIN [formField] AS [field]
    ON [field].[formtypeid] = [type].[formtypeid]
  INNER JOIN @linkFields AS [linked]
    ON [linked].[name] = [field].[formFieldName]
  INNER JOIN [formField] AS [parent]
    ON [field].[formtypeid] = [type].[formtypeid]
    AND [parent].[kioskSiteUUID] = [type].[kioskSiteUUID]
  INNER JOIN @linkFields AS [linkedparent]
    ON [linkedparent].[parent] = [parent].[formFieldName]
    AND [linkedparent].[name] = [linked].[name]
  INNER JOIN [formDropDown] AS [dropdown]
    ON [dropdown].[formfieldid] = [parent].[formFieldid]
    AND [dropdown].[fddvalue] = [linkedparent].[when];

  INSERT INTO formFieldWorkflow(
    [parentFormFieldID],
    [formFieldSelectValue],
    [formFieldSelectValueMandatory],
    [formFieldID],
    [formFieldWorkflowIsActive],
    [kioskID],
    [kioskSiteUUID]
  )
  SELECT [field].[parentid]
    ,[field].[valueid]
    ,[field].[mandatory]
    ,[field].[id]
    ,1
    ,@kioskid
    ,[field].[site]
  FROM @fieldDependencies AS [field]
  LEFT JOIN [formFieldWorkflow] AS [workflow]
    ON [workflow].[kioskid] = @kioskid
    AND [workflow].[formFieldID] = [field].[id]
    AND [workflow].[parentFormFieldID] = [field].[parentid]
    AND [workflow].[kioskSiteUUID] = [field].[site]
  WHERE [workflow].[formFieldWorkflowID] IS NULL;

END