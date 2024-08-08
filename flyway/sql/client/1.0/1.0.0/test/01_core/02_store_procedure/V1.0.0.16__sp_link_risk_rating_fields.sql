-- ==========================================================================================
-- Author:      Shane Gibbons
-- Create date: 19/12/2019
-- Description: 
-- * 19/12/2019 - SG - Created
-- ==========================================================================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.link_risk_rating_fields(
  @linkFields test.linkFields READONLY
  ,@kioskid INT
)
AS
BEGIN

  DECLARE @fieldDependencies TABLE(
    [id] INT NOT NULL
    ,[orderid] INT NOT NULL
    ,[typeid] INT NOT NULL
    ,[name] VARCHAR(255) NOT NULL
    ,[site] VARCHAR(255) NOT NULL
  );

  INSERT INTO @fieldDependencies(
    [id]
    ,[orderid]
    ,[typeid]
    ,[name]
    ,[site]
  )
  SELECT
    [parent].[formFieldID]
    ,[parent].[formFieldOrder]
    ,[field].[formTypeID]
    ,[linked].[name]
    ,[type].[kioskSiteUUID]
  FROM [formType] AS [type]
  INNER JOIN [formField] AS [parent]
    ON [parent].[formtypeid] = [type].[formtypeid]
    AND [parent].[kioskSiteUUID] = [type].[kioskSiteUUID]
  INNER JOIN [formField] AS [field]
    ON [field].[formtypeid] = [type].[formtypeid]
	AND (
		[field].[formFieldOrder] = ([parent].[formFieldOrder] + 1)
	 OR [field].[formFieldOrder] = ([parent].[formFieldOrder] + 2))
  INNER JOIN @linkFields AS [linked]
    ON [linked].[name] = [field].[formFieldName]
  INNER JOIN @linkFields AS [linkedparent]
    ON [linkedparent].[parent] = [parent].[formFieldName]
    AND [linkedparent].[name] = [linked].[name];

  
  UPDATE [formField]
  SET [parentFormFieldID] = [field].[id]
  FROM [formField]
  INNER JOIN @fieldDependencies AS [field]
    ON [field].[name] = [formField].[formFieldName]
    AND (
      [field].[orderid] = ([formField].[formFieldOrder] - 1)
      OR [field].[orderid] = ([formField].[formFieldOrder] - 2)
  )
  WHERE [formField].[formTypeID] = [field].[typeid]
  AND [formField].[kioskID] = @kioskid
  AND [formField].[kioskSiteUUID] = [field].[site]
  AND [formField].[formFieldIsActive] = 1
  AND [formField].[parentFormFieldID] = 0;
    

END