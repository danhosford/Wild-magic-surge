-- ==========================================================
-- Author:      Alexandre Tran
-- Create date: 01/12/2018
-- Description: TESTING ONLY SCRIPT - Setup COSHH Assess
-- * 01/12/2018 - AT - Created
-- * 11/05/2020 - AT - Set up admin form type
-- ==========================================================

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Assess Product';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'COSHH Assess Product - Auto generated';
DECLARE @FORM_APPROVER_LEVEL INT = 1;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_TYPE_ASSESS INT = 2;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'General';

DECLARE @FORM_FIELDS AS test.formFields;

SET NOCOUNT ON;

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
	name,type,pagename,isActive,isMandatory
)
VALUES ('COSHH Location','locationTree',@FIRST_PAGE_NAME,1,1)
,('Is this product hazardous to supply','yesNoRadio',@FIRST_PAGE_NAME,1,0)
,('Emergency Contact Number','textLine',@FIRST_PAGE_NAME,1,0);


EXEC [test].[create_COSHH_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@coshhtype = @FORM_TYPE_ASSESS
,@FormFields = @FORM_FIELDS;

INSERT INTO [formTypeAdministrationSetting](
[formTypeAdministrationSettingIsActive],[formTypeAdministrationSettingFormType]
,[formTypeAdministrationSettingCreateBy],[formTypeAdministrationSettingCreateUTC]
,[formTypePublicKey],[kioskID],[kioskSiteUUID])
SELECT 1,@FORM_TYPE_ASSESS,0,GETUTCDATE()
,[type].[formTypePublicKey],[type].[kioskID],[type].[kioskSiteUUID]
FROM [dbo].[formType] AS [type]
LEFT JOIN [dbo].[formTypeAdministrationSetting] AS [register]
  ON [register].[kioskID] = [type].[kioskID]
  AND [register].[kioskSiteUUID] = [type].[kioskSiteUUID]
  AND [register].[formTypePublicKey] = [type].[formTypePublicKey]
WHERE [register].[formTypeAdministrationSettingID] IS NULL
  AND [type].[formName] = @FORM_NAME
  AND [type].[formNarrative] = @FORM_DESCRIPTION;