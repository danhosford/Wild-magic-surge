-- ==============================================================================
-- Author:      Jamie Conroy
-- Create date: 26/03/2020
-- Description: Set up the acl settings for the COSHH Administrator group
-- CHANGELOG:
-- 01/07/2020 - AT - Rename with correct breadcrumb name
-- ==============================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- MOC Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for MOC Approver
DECLARE @COSHH_ADMIN_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('COSHH Administrator');

INSERT INTO @COSHH_ADMIN_FEATURES (section,page,appPrefix)
VALUES ('coshhAdmin','coshhApproverFormField','coshh')
,('coshhAdmin','coshhApproverGroup','coshh')
,('coshhAdmin','coshhApproverList','coshh')
,('coshhAdmin','coshhApproverModify','coshh')
,('coshhAdmin','coshhHazardousFormField','coshh')
,('coshhAdmin','coshhHazardousFormField_submit','coshh')
,('coshhHome','coshhHome','coshh')
,('coshhMap','coshhMap','coshh')
,('coshhProduct','coshhAssessmentReview','coshh')
,('coshhProduct','coshhAssessmentReview_submit','coshh')
,('coshhProduct','coshhAssessmentReviewSelect','coshh')
,('coshhProduct','coshhPrint','coshh')
,('coshhProduct','coshhProductAllDisplay','coshh')
,('coshhProduct','coshhProductApproved','coshh')
,('coshhProduct','coshhProductApprovedDisplay','coshh')
,('coshhProduct','coshhProductApproverModify','coshh')
,('coshhProduct','coshhProductAssess','coshh')
,('coshhProduct','coshhProductAssessSelect','coshh')
,('coshhProduct','coshhProductAssessSubmit','coshh')
,('coshhProduct','coshhProductCreate','coshh')
,('coshhProduct','coshhProductDisplay','coshh')
,('coshhProduct','coshhProductModify','coshh')
,('coshhProduct','coshhProductModify_submit','coshh')
,('coshhProduct','coshhProductRejectedSelect','coshh')
,('coshhProduct','coshhProductRemoveForm_submit','coshh')
,('coshhReport','coshhReport','coshh')
,('coshhReport','coshhSDSExpiryReport','coshh')
,('coshhReport','coshhSDSExpiryReportUpdateForm','coshh')
,('coshhUser','user','coshh');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @COSHH_ADMIN_FEATURES;
