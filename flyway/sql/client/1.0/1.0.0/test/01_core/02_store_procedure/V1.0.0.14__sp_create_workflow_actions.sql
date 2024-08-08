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

CREATE OR ALTER PROCEDURE test.create_workflow_actions
(
  @name VARCHAR(255)
  ,@MainParentName VARCHAR(255) = NULL
  ,@DisplayText VARCHAR(255) = NULL
  ,@OpenVia VARCHAR(255) = NULL
  ,@kioskid INT
)
AS

DECLARE @DEFAULT_LANG VARCHAR(255) = 'en_IE';
DECLARE @SYSTEM_USER_ID UNIQUEIDENTIFIER = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER);
  
IF @DisplayText IS NOT NULL

  BEGIN
  
    DECLARE @NewTranslation TABLE(
      [uuid] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
      ,[text] VARCHAR(255) NOT NULL
    );
    
    INSERT INTO @NewTranslation ([text])
    values (@DisplayText);
    
    -- Add display text into language table
    INSERT INTO [language].[translations] (
      [uuid],
      [parent],
      [language],
      [text],
      [kioskuuid],
      [createdby],
      [updatedby]
    )
    SELECT
      [newtran].[uuid],
      [newtran].[uuid],
      @DEFAULT_LANG,
      [newtran].[text],
      [kiosk].[kioskUUID],
      @SYSTEM_USER_ID,
      @SYSTEM_USER_ID
    FROM @NewTranslation AS [newtran]
    LEFT JOIN [v3_sp].[dbo].[kiosk] AS [kiosk] 
      ON [kiosk].[kioskid] = @kioskid
    LEFT JOIN [language].[translations] AS [translation] 
      ON [translation].[text] = [newtran].[text]
    WHERE [translation].[uuid] IS NULL
  END
  
IF @MainParentName IS NOT NULL

  BEGIN
  
    -- Create the workflow action for the form
    INSERT INTO [workflow].[actions] (
      [kioskuuid],
      [form],
      [displayText],
      [open],
      [parentForm],
      [createdby],
      [createdon],
      [updatedby],
      [updatedon],
      [hint]
    )
    SELECT
      [kiosk].[kioskUUID],
      [subform].[uuid],
      [hint].[text],
      @OpenVia,
      [form].[uuid],
      @SYSTEM_USER_ID,
      [form].[formCreateUTC],
      @SYSTEM_USER_ID,
      [form].[formCreateUTC],
      [hint].[uuid]
    FROM [dbo].[formType] AS [subform]
    INNER JOIN [dbo].[formType] AS [form] 
      ON [form].[kioskSiteUUID] = [subform].[kioskSiteUUID]
      AND [form].[formName] = @MainParentName
      AND [form].[kioskID] = [subform].[kioskID]
    INNER JOIN [v3_sp].[dbo].[kiosk] AS [kiosk] 
      ON [kiosk].[kioskid] = [subform].[kioskID]
    LEFT JOIN [language].[hints] AS [hint] 
      ON [hint].[text] = @DisplayText
    LEFT JOIN [workflow].[actions] AS [action] 
      ON [action].[uuid] = [subform].[uuid]
      AND [action].[kioskuuid] = [kiosk].[kioskUUID]
      AND [action].[parentForm] = [form].[uuid]
    WHERE [action].[uuid] IS NULL
    AND [subform].[formName] = @name;
  END