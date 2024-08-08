-- ==========================================================================================
-- Author:      Jamie Conroy
-- Create date: 11/12/2019
-- Description: 
-- * 11/12/2019 - JC - Created
-- * 11/12/2019 - AT - Update to ensure form field match a form
-- * 12/12/2019 - AT - Remove the need of kiosk id
-- * 12/12/2019 - AT - Change to appropriate column name
-- ==========================================================================================
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.populate_formDropDowns(
  @FormDropDown test.formDropDowns READONLY
  ,@kioskid INT
)
AS
BEGIN

  DECLARE @formFieldDropdown TABLE(
    [formFieldid] VARCHAR(255) NOT NULL
    ,[kioskID] INT NOT NULL
    ,[fieldname] VARCHAR(255) NOT NULL
    ,[value] VARCHAR(255) NOT NULL
    ,[alternativeValue] VARCHAR(255)
    ,[isActive] BIT NOT NULL DEFAULT 1
  );

  INSERT INTO @formFieldDropdown (
    [formFieldid],[isActive]
    ,[kioskid],[fieldname]
    ,[value],[alternativeValue]
  )
  SELECT
    [field].[formFieldID],[dropdown].[isActive]
    ,@kioskid,[field].[formFieldName]
    ,[dropdown].[value],[dropdown].[alternativeValue]
  FROM formType AS [type]
  INNER JOIN (
    SELECT [formname] 
    FROM @FormDropDown
    GROUP BY [formname]
  ) AS [form]
    ON [form].[formname] = [type].[formname]
  INNER JOIN [formField] AS [field]
    ON [field].[formtypeid] = [type].[formtypeid]
  INNER JOIN @formDropDown AS [dropdown]
    ON [dropdown].[fieldname] = [field].[formFieldName];

	INSERT INTO formDropDown(
    [formFieldID],
    [fddValue],
    [kioskID],
    [fddIsActive],
    [fddCreateBy],
    [fddCreateUTC],
    [kioskSiteUUID],
    [fddAlternateValue]
  )
  SELECT 
    [formFieldTable].[formFieldID],
    [formDropDownTable].[value],
    @kioskid,
    [formDropDownTable].[isActive],
    0,
    GETUTCDATE(),
    [formFieldTable].[kiosksiteuuid],
    [formDropDownTable].[alternativeValue]
  FROM @formDropDown AS [formDropDownTable] 
  INNER JOIN [formField] AS [formFieldTable]
    ON [formFieldTable].[formFieldName] = [formDropDownTable].[fieldname]
  INNER JOIN [formType] AS [formTypeTable] 
    ON [formFieldTable].[formTypeID] = [formTypeTable].[formtypeId]
  LEFT JOIN [formDropDown] AS [dropdown]
    ON [dropdown].[fddValue] = [formDropDownTable].[value]
  WHERE [dropdown].[formFieldID] IS NULL;

END
GO
