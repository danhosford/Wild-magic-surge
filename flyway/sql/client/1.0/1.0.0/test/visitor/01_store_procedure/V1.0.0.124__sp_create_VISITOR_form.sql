-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 25/11/2020
-- Description: Store procedure - Visitor Booking
-- * 25/11/2020 - JC - Created
-- ==========================================================

EXEC dbadmin.registerSchema @name='test',@role='dbo',@ALLOW_SELECT=1
GO

CREATE OR ALTER PROCEDURE test.create_VISITOR_Form
(
@name VARCHAR(255)
,@prefix VARCHAR(255)
,@description VARCHAR(255)
,@ApproverLevel INT
,@formAfterSubmitCustomFile VARCHAR(255) = ''
,@visitorType INT
,@FormFields test.formFields READONLY  
)
AS
BEGIN

  DECLARE @MODULE_PREFIX VARCHAR(255) = 'visitor';
  DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());;

  DECLARE @RANDOMISE_QUESTION BIT = 1;
  DECLARE @WRONG_ANSWER BIT = 1;

  DECLARE @BC_FORM TABLE(
    id INT
    ,moduleID INT
    ,publickey VARCHAR(255)
    ,kioskSiteUUID VARCHAR(255) COLLATE Latin1_General_CI_AS
  );

  DECLARE @BC_FORM_PAGE TABLE(
    id INT
    ,name VARCHAR(255) COLLATE Latin1_General_CI_AS
    ,formid INT
  )

  INSERT INTO dbo.formType (
      [kioskID],[formModuleID]
      ,[formName],[formNarrative],[formIsActive]
      ,[formCreateBy],[formCreateUTC]
      ,[formTypePublicKey]
      ,[kioskSiteUUID]
      ,[formBeforeSubmitCustomFile],[formAfterSubmitCustomFile]
      ,[formTypeRandomiseQuestions]
      ,[formNumWrongAnswers]
      ,[approvalLevel])
  OUTPUT INSERTED.formTypeID,INSERTED.formModuleID,INSERTED.formTypePublicKey,INSERTED.kioskSiteUUID INTO @BC_FORM
  SELECT @KIOSKID
      ,[app].[kaID]
      -- Form setting
      ,@name
      ,@description
      ,1
      -- Creation
      ,0
      ,GETUTCDATE()
      ,CONVERT(VARCHAR(MAX),NEWID())
      ,[ksa].[kioskSiteUUID]
      -- Form params
      ,''
      ,@formAfterSubmitCustomFile
      ,@RANDOMISE_QUESTION,
      @WRONG_ANSWER,
      @ApproverLevel
  FROM [v3_sp].[dbo].[kioskApplications] AS [app]
  LEFT JOIN [dbo].[kioskSiteApplication] AS [ksa] 
    ON [ksa].[kaID] = [app].[kaID]
    AND [ksa].[ksaDeactivateUTC] IS NULL
  LEFT JOIN [formType] AS [ft] 
    ON [ft].[kioskSiteUUID] = [ksa].[kioskSiteUUID]
    AND  [ft].[formModuleID] = [app].[kaID]
    AND [ft].[kioskID] = [ksa].[kioskID]
    AND [ft].[formIsActive] = 1
  WHERE [app].[kaPrefix] = @MODULE_PREFIX
    AND  [ft].[formTypeID] IS NULL;

  -- Create the pages
  INSERT INTO formPage(
    [formTypeID]
    ,[formTypePublicKey]
    ,[kioskID]
    ,[kioskSiteUUID]
    ,[formPageName]
    ,[formPageOrder]
    ,[formPageIsActive]
    ,[formPageCreateBy]
    ,[formPageCreateUTC]
  )
  OUTPUT INSERTED.formPageID, INSERTED.formPageName, INSERTED.formTypeID INTO @BC_FORM_PAGE
  SELECT [bcf].[id]
    ,[bcf].[publickey]
    ,@KIOSKID
    ,[bcf].[kioskSiteUUID]
    ,[p].[pagename]
    ,1
    ,1
    ,0
    ,GETUTCDATE()
  FROM @BC_FORM AS [bcf]
  FULL OUTER JOIN (SELECT DISTINCT pagename FROM @FormFields) AS [p] 
    ON [p].[pagename] IS NOT NULL
  LEFT JOIN [formPage] AS [fp] 
    ON [fp].[formTypeID] = [bcf].[id]
    AND [fp].[kioskID] = @KIOSKID
    AND [fp].[kioskSiteUUID] = [bcf].[kioskSiteUUID]
    AND [fp].[formPageName] = [p].[pagename]  
  WHERE [fp].[formPageID] IS NULL;

  INSERT INTO formField (
  [formFieldName]
  ,[formFieldType]
  ,[formFieldIsActive]
  ,[formFieldIsMandatory]
  ,[formFieldOrder]
  ,[formFieldUseDefaultOrder]
  ,[maxCharacters]
  ,[formFieldIsRandomQuestion]
  ,[formTypeID]
  ,[formTypePublicKey]
  ,[formFieldPageID]
  ,[kioskID]
  ,[kioskSiteUUID]
  ,[formFieldCreateBy]
  ,[formFieldCreateUTC]
  ,[formFieldToolTip]
  )
  SELECT
  [bcff].[name]
  ,[bcff].[type]
  ,[bcff].[isActive]
  ,[bcff].[isMandatory]
  ,[bcff].[orderIndex]
  ,[bcff].[useDefaultOrder]
  ,[bcff].[maxCharacters]
  ,[bcff].[isRandomQuestion]
  ,[bcf].[id]
  ,[bcf].[publickey]
  ,[bfp].[id]
  ,@KIOSKID
  ,[bcf].[kioskSiteUUID]
  ,0
  ,GETUTCDATE()
  ,'Thank You Mario! But our princess is in another castle!'
  FROM @FormFields AS [bcff]
  LEFT JOIN @BC_FORM_PAGE AS [bfp]
    ON [bfp].[name] = [bcff].[pagename]
  LEFT JOIN @BC_FORM AS [bcf] 
    ON [bcf].[id] = [bfp].[formid]
  LEFT JOIN [formField] AS [ff] 
    ON [ff].[formFieldName] = [bcff].[name]
    AND [ff].[formFieldType] = [bcff].[type]
    AND [ff].[kioskSiteUUID] = [bcf].[kioskSiteUUID]
    AND [ff].[formFieldPageID] = [bfp].[id]
  WHERE [ff].[formFieldID] IS NULL;

  INSERT INTO [formTypeAdministrationSetting](
    [formTypeAdministrationSettingIsActive]
    ,[formTypeAdministrationSettingFormType]
    ,[formTypeAdministrationSettingCreateBy]
    ,[formTypeAdministrationSettingCreateUTC]
    ,[formTypePublicKey]
    ,[kioskID]
    ,[kioskSiteUUID])
  SELECT 1
    ,@visitorType
    ,0
    ,GETUTCDATE()
    ,[type].[formTypePublicKey]
    ,[type].[kioskID]
    ,[type].[kioskSiteUUID]
  FROM [v3_sp].[dbo].[kioskApplications] AS [app] 
  LEFT JOIN [dbo].[formType] AS [type]
    ON [type].[formModuleID] = [app].[kaID]
    AND [type].[formName] = @name
  INNER JOIN [dbo].[kioskSite] AS [site]
    ON [site].[kioskID] = [type].[kioskID]
    AND [site].[kioskSiteUUID] = [type].[kioskSiteUUID]
  LEFT JOIN [dbo].[formTypeAdministrationSetting] AS [register]
    ON [register].[kioskID] = [type].[kioskID]
    AND [register].[kioskSiteUUID] = [type].[kioskSiteUUID]
    AND [register].[formTypePublicKey] = [type].[formTypePublicKey]
  WHERE [register].[formTypeAdministrationSettingID] IS NULL
  AND [app].[kaPrefix] = @prefix

END
GO
