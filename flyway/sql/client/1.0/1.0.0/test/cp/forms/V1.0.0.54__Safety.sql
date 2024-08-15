/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 03/01/2019 15:40
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Safety';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Safety test form - Auto generated';
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'General';

DECLARE @FORM_FIELDS AS test.formFields;

SET NOCOUNT ON;

PRINT 'Add Safety form if not exist';
-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
  name,type,pagename,isActive,isMandatory
)
VALUES ('Do you lock the door?','yesNoRadio',@FIRST_PAGE_NAME,1,1)
,('Are you a robot?','checkbox',@FIRST_PAGE_NAME,1,0)
,('Comment','fDescription',@FIRST_PAGE_NAME,1,1);


EXEC [test].[create_CP_Form]
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@isApproverByLocation = @IS_APPROVER_BY_LOCATION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@FormFields = @FORM_FIELDS;

PRINT 'Safety form added successfully!';

PRINT 'Add document type safety...';
-- Add document upload type
INSERT INTO [dbo].[cpReferenceCompanyComplianceRequirement]
    ([kioskID],[kioskSiteUUID]
    ,[cpReferenceCompanyComplianceRequirementName],[cpReferenceCompanyComplianceRequirementIsActive]
    ,[cpReferenceCompanyComplianceRequirementIsDocumentRequest],[cpReferenceCompanyComplianceRequirementIsQuestionnaireRequest]
        ,[formTypeID]
        ,[cpReferenceCompanyComplianceRequirementIsDefault])
  SELECT ks.kioskID, ks.kioskSiteUUID
  ,CONCAT(@FORM_NAME,' Cert.',' - ',ks.kioskSiteName), 1,
  1,0
  ,0, 0  
  FROM dbo.kioskSite AS ks
  LEFT JOIN dbo.cpReferenceCompanyComplianceRequirement AS rccr ON rccr.formTypeID = 0
    AND rccr.kioskID = ks.kioskID
    AND rccr.kioskSiteUUID = ks.kioskSiteUUID
    AND rccr.cpReferenceCompanyComplianceRequirementName = @FORM_NAME
  WHERE rccr.cpReferenceCompanyComplianceRequirementID IS NULL;

PRINT 'Safety document type added successfully!';