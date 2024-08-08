-- ==============================================================================
-- Author:      SHane Gibbons
-- Create date: 03/07/2020
-- Description: Set up the acl settings for the CP System Admin group
-- CHANGELOG:
-- 12/04/2021 - JC - Ensure test account has access to issueCourseAccess to replicate live system
-- ==============================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- CP System Admin list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for CP System Admin
DECLARE @CP_SYSTEM_ADMIN_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('CP System Admin');

INSERT INTO @CP_SYSTEM_ADMIN_FEATURES (section,page,appPrefix)
VALUES ('cpCompany','canAddQualificationsInCompanyDetails','cp')
,('cpCompany','canSeeComplianceTab','cp')
,('cpCompany','canSeeDocumentsTab','cp')
,('cpCompany','canSeeRatingsTab','cp')
,('cpCompany','canSeeUsersTab','cp')
,('cpCompany','checkExistence_submit','cp')
,('cpCompany','companyTableAllOptionsAccess','cp')
,('cpCompany','complianceRequirementLevel2_display','cp')
,('cpCompany','cpCompanyAdd','cp')
,('cpCompany','cpCompanyAdd_submit','cp')
,('cpCompany','cpCompanyComplianceAddNote_display','cp')
,('cpCompany','cpCompanyComplianceAddNote_submit','cp')
,('cpCompany','cpCompanyComplianceRequirementResponse_submit','cp')
,('cpCompany','cpCompanyComplianceRequirementsTable','cp')
,('cpCompany','cpCompanyComplianceResponseFiles','cp')
,('cpCompany','cpCompanyComplianceResponseHistory','cp')
,('cpCompany','cpCompanyComplianceResponses','cp')
,('cpCompany','cpCompanyComplianceResponseStatus_submit','cp')
,('cpCompany','cpCompanyComplianceResponseStatusUpdate_display','cp')
,('cpCompany','cpCompanyComplianceResponseTable','cp')
,('cpCompany','cpCompanyComplianceTable','cp')
,('cpCompany','cpCompanyComplianceUploadForm_display','cp')
,('cpCompany','cpCompanyComplianceUploadHistory','cp')
,('cpCompany','cpCompanyDetails','cp')
,('cpCompany','cpCompanyDocument_submit','cp')
,('cpCompany','cpCompanyDocumentsTable','cp')
,('cpCompany','cpCompanyDocumentUploadForm_display','cp')
,('cpCompany','cpCompanyEdit','cp')
,('cpCompany','cpCompanyEdit_submit','cp')
,('cpCompany','cpCompanyList','cp')
,('cpCompany','cpCompanyPendingTable','cp')
,('cpCompany','cpCompanyRatingAdd_display','cp')
,('cpCompany','cpCompanyRatingAdd_submit','cp')
,('cpCompany','cpCompanyTable','cp')
,('cpCompany','cpCompanyUserTable','cp')
,('cpCompany','cpCompanyVersionComparision_display','cp')
,('cpCompany','cpComplianceRequirementEdit','cp')
,('cpCompany','cpComplianceRequirementEdit_submit','cp')
,('cpCompany','deleteQualificationLink','cp')
,('cpCompany','documentatTableOptionAccess','cp')
,('cpCompany','documentTableOptionAccess','cp')
,('cpCompany','editCompanyQualification_display','cp')
,('cpCompany','hasFullWorkforceRights','cp')
,('cpCompany','isSysAdmin','cp')
,('cpCompany','manageCompanyQualifications','cp')
,('cpCompany','pendingCompanies','cp')
,('cpCompany','saveCompanyDocument_submit','cp')
,('cpCompany','saveCompanyQualification_submit','cp')
,('cpCompany','showCurrentQualifications','cp')
,('cpCompany','updateCompanyComplianceRequirementStatus_submit','cp')
,('cpCompany','updateCompanyDocumentStatus_submit','cp')
,('cpCompany','updateCompanyQualificationStatus_submit','cp')
,('cpCompany','updateCompanyStatus_submit','cp')
,('cpCompany','updateCpStatus_submit','cp')
,('cpCompany','updateResponseSection','cp')
,('cpCompany','uploadCompanyComplianceFiles_submit','cp')
,('cpCompany','uploadQualificationFile_submit','cp')
,('cpHome','canSearchCompany','cp')
,('cpHome','canSeeBasicAdminSection','cp')
,('cpHome','canSeeSubmittedDataSection','cp')
,('cpHome','cpHome','cp')
,('cpHome','cpNotification','cp')
,('cpQuestionnaireCreate','questionnaireCreate','cp')
,('cpQuestionnaireCreate','questionnaireCreateSubmit','cp')
,('cpQuestionnaireCreate','savedTemplates','cp')
,('cpQuestionnaireDisplay','questionnaireDisplay','cp')
,('cpQuestionnaireDisplay','questionnaireDisplay','cp')
,('cpQuestionnaireDisplay','questionnaireReview','cp')
,('cpQuestionnaireDisplay','questionnairesPending','cp')
,('cpQuestionnaireDisplay','saveInvalidFields_submit','cp')
,('cpQuestionnaireDisplay','updateQuestionnaireStatus_submit','cp')
,('cpReports','complianceReport','cp')
,('cpReports','insuranceReport','cp')
,('cpReports','ratingsReport','cp')
,('cpReports','workforceInductionReport','cp')
,('cpReports','workforceReport','cp')
,('cpSites','cpSitesEdit','cp')
,('cpSites','cpSitesEdit_submit','cp')
,('cpSites','cpSitesList','cp')
,('cpSites','cpSitesTable','cp')
,('cpUser','cpUserEdit_submit','cp')
,('cpUser','user','cp')
,('cpUser','userAdd','cp')
,('cpWorkforce','cpWorkforceEdit','cp')
,('cpWorkforce','cpWorkforceEdit_submit','cp')
,('cpWorkforce','cpWorkforceTable','cp')
,('cpWorkforce','deleteQualificationLink','cp')
,('cpWorkforce','editWorkforceQualification_display','cp')
,('cpWorkforce','issueCourseAccess','cp')
,('cpWorkforce','manageWorkforceQualifications','cp')
,('cpWorkforce','saveWorkforceQualification_submit','cp')
,('cpWorkforce','showCurrentQualifications','cp')
,('cpWorkforce','updateWorkforceQualificationStatus','cp')
,('cpWorkforce','updateWorkforceQualificationStatus_submit','cp')
,('cpWorkforce','updateWorkforceStatus_submit','cp')
,('cpWorkforce','uploadQualificationFile_submit','cp')
,('user','userTableAllOptionsAccess','cp');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @CP_SYSTEM_ADMIN_FEATURES;
