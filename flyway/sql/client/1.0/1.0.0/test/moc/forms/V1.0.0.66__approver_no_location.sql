/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 01/12/2018 10:31
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 1;
--DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

DECLARE @FORM_NAME VARCHAR(255) = 'Approver';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Approver without location - Auto generated';
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @FORM_TYPE_BUSINESS_CASE INT = 2;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FIRST_PAGE VARCHAR(255) = '1. General';
DECLARE @SECOND_PAGE VARCHAR(255) = '2. Action Items';

DECLARE @FORM_FIELDS AS test.formFields;

SET NOCOUNT ON;

PRINT 'Add new approver group...';

DECLARE @approver_groups TABLE(
  [name] VARCHAR(255) NOT NULL
);

INSERT INTO @approver_groups ([name])
VALUES ('EHS Manager');

INSERT INTO [dbo].[mocReferenceApproverType] ( [mratName], [mratIsActive], [kioskSiteUUID], [kioskID])
SELECT [group].[name],[site].[kioskSiteIsActive],[site].[kioskSiteUUID],[site].[kioskID]
FROM  @approver_groups AS [group]
FULL OUTER JOIN [dbo].[kioskSite] AS [site]
  ON [site].[kioskSiteUUID] IS NOT NULL
  AND [site].[kioskSiteIsActive] = 1
LEFT JOIN [dbo].[mocReferenceApproverType] AS [existing]
  ON [existing].[kioskID] = [site].[kioskID]
  AND [existing].[kioskSiteUUID] = [site].[kioskSiteUUID]
  AND [existing].[mratName] = [group].[name]
WHERE [existing].[mratID] IS NULL;

PRINT 'New approver group created successfully!';

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
	name,type,pagename,isActive,isMandatory
)
VALUES ('Title','textLine',@FIRST_PAGE,1,1)
,('Description of Change ','fDescription',@FIRST_PAGE,1,1)
,('Emergency change?','yesNoRadio',@FIRST_PAGE,1,1)
,('MOC Start Date','dateOfWorkStart',@FIRST_PAGE,1,1)
,('Targeted MOC Completion Date','dateOfWorkEnd',@FIRST_PAGE,1,1)
,('MOC Owner','textLine',@FIRST_PAGE,1,1)
,('Building','location',@FIRST_PAGE,1,1)
,('Location Level 2','locationLevel2CFC',@FIRST_PAGE,1,0)
,('Location Level 3','locationLevel3CFC',@FIRST_PAGE,1,0)
,('EHS Approver','mocApprover',@FIRST_PAGE,1,0)
,('MOC Approver','mocApprover',@FIRST_PAGE,1,1)
,('Attach Business Case','mocBusinessCase',@FIRST_PAGE,1,0)
,('Training Materials','checkbox',@SECOND_PAGE,1,0)
,('Personnel Training','checkbox',@SECOND_PAGE,1,0)
,('Lockout/Tag-out Procedures','checkbox',@SECOND_PAGE,1,0)
,('Commissioning or Startup Testing','checkbox',@SECOND_PAGE,1,0)
,('Communication of Change','checkbox',@SECOND_PAGE,1,0)
,('P&IDs','checkbox',@SECOND_PAGE,1,0)
,('Training Materials - Updated or created.','mocActionTask',@SECOND_PAGE,1,0)
,('Personnel Training - Affected personnel trained on the revised procedures and the training documented.','mocActionTask',@SECOND_PAGE,1,0)
,('Lockout/Tag-out Procedures - Updated or created.','mocActionTask',@SECOND_PAGE,1,0)
,('Commissioning or Startup Testing - Conducted and documented. Provide document reference number below.','mocActionTask',@SECOND_PAGE,1,0)
,('Communication of Change - Affected groups (operations, maintenance, development, etc.) notified.','mocActionTask',@SECOND_PAGE,1,0)
,('P&IDs - Updated or created.','mocActionTask',@SECOND_PAGE,1,0);


EXEC [test].[create_MOC_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@isApproverByLocation = @IS_APPROVER_BY_LOCATION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@moctype = @FORM_TYPE_BUSINESS_CASE
,@FormFields = @FORM_FIELDS;

GO

PRINT 'Add form Field approver group type...';

DECLARE @approver_formfield TABLE(
  [name] VARCHAR(255) NOT NULL
  ,[grouptypename] VARCHAR(255) NOT NULL
);

INSERT INTO @approver_formfield
VALUES('EHS Approver','EHS Manager');

INSERT INTO [dbo].[mocFieldApprover](
[kioskID],[kioskSiteUUID]
,[mocID],[mratID],[mfID],[mfaIsActive]
)
SELECT 
[field].[kioskID],[field].[kioskSiteUUID]
,[field].[formTypeID],[grouptype].[mratID],[field].[formFieldID],[field].[formFieldIsActive]
FROM [dbo].[formField] AS [field]
INNER JOIN @approver_formfield AS [approverfield]
  ON [approverfield].[name] = [field].[formFieldName]
INNER JOIN [dbo].[mocReferenceApproverType] AS [grouptype]
  ON [grouptype].[kioskID] = [field].[kioskID]
  AND [grouptype].[kioskSiteUUID] = [field].[kioskSiteUUID]
  AND [grouptype].[mratName] = [approverfield].[grouptypename]
LEFT JOIN [dbo].[mocFieldApprover] AS [existing]
  ON [existing].[kioskID] = [field].[kioskID]
  AND [existing].[kioskSiteUUID] = [field].[kioskSiteUUID]
  AND [existing].[mocID] = [field].[formTypeID]
  AND [existing].[mratID] = [grouptype].[mratID]
  AND [existing].[mfID] = [field].[formFieldID]
WHERE [existing].[mfaID] IS NULL;

PRINT 'Field approver group type setup successfully!';