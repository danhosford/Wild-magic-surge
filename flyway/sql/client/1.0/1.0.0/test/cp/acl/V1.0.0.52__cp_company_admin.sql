-- ==============================================================================
-- Author:      SHane Gibbons
-- Create date: 03/07/2020
-- Description: Set up the acl settings for the CP Company Admin group
-- CHANGELOG:
-- 13/04/2021 - JC - Ensure test account has access to issueCourseAccess
-- ==============================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- CP Company Admin list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for CP Company Admin
DECLARE @CP_COMPANY_ADMIN_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('CP Company Admin');

INSERT INTO @CP_COMPANY_ADMIN_FEATURES (section,page,appPrefix)
VALUES ('cpCompany','canAddQualificationsInCompanyDetails','cp')
,('cpCompany','canSeeComplianceTab','cp')
,('cpCompany','cpCompanyComplianceAddNote_display','cp')
,('cpCompany','cpCompanyComplianceAddNote_submit','cp')
,('cpCompany','cpCompanyComplianceRequirementResponse_submit','cp')
,('cpCompany','cpCompanyComplianceRequirementsTable','cp')
,('cpCompany','cpCompanyComplianceResponseFiles','cp')
,('cpCompany','cpCompanyComplianceResponseHistory','cp')
,('cpCompany','cpCompanyComplianceResponseTable','cp')
,('cpCompany','cpCompanyComplianceTable','cp')
,('cpCompany','cpCompanyComplianceUploadHistory','cp')
,('cpCompany','cpCompanyDetails','cp')
,('cpCompany','cpCompanyEdit','cp')
,('cpCompany','cpCompanyEdit_submit','cp')
,('cpCompany','cpCompanyLogoUpload','cp')
,('cpCompany','deleteQualificationLink','cp')
,('cpCompany','editCompanyQualification_display','cp')
,('cpCompany','hasFullWorkforceRights','cp')
,('cpCompany','isCompanyAdmin','cp')
,('cpCompany','manageCompanyQualifications','cp')
,('cpCompany','showCurrentQualifications','cp')
,('cpCompany','uploadCompanyComplianceFiles_submit','cp')
,('cpCompany','uploadCompanyLogo_submit','cp')
,('cpCompany','uploadQualificationFile_submit','cp')
,('cpHome','cpHome','cp')
,('cpQuestionnaireCreate','questionnaireCreate','cp')
,('cpQuestionnaireCreate','questionnaireCreateSubmit','cp')
,('cpQuestionnaireCreate','savedTemplates','cp')
,('cpQuestionnaireDisplay','questionnaireDisplay','cp')
,('cpQuestionnaireDisplay','questionnaireDisplay','cp')
,('cpWorkforce','cpWorkforceEdit','cp')
,('cpWorkforce','cpWorkforceEdit_submit','cp')
,('cpWorkforce','deleteQualificationLink','cp')
,('cpWorkforce','editWorkforceQualification_display','cp')
,('cpWorkforce','issueCourseAccess','cp')
,('cpWorkforce','manageWorkforceQualifications','cp')
,('cpWorkforce','saveWorkforceQualification_submit','cp')
,('cpWorkforce','showCurrentQualifications','cp')
,('cpWorkforce','updateWorkforceQualificationStatus','cp')
,('cpWorkforce','updateWorkforceQualificationStatus_submit','cp')
,('cpWorkforce','updateWorkforceStatus_submit','cp')
,('cpWorkforce','uploadQualificationFile_submit','cp');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @CP_COMPANY_ADMIN_FEATURES;
