-- ==============================================================================
-- Author:      Shane Gibbons
-- Create date: 26/11/2020
-- Description: Set up the acl settings for the COSHH Approver group
-- CHANGELOG:
-- ==============================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- COSHH Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for COSHH Approver
DECLARE @COSHH_APPROVER_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('COSHH Approver');

INSERT INTO @COSHH_APPROVER_FEATURES (section,page,appPrefix)
VALUES ('coshhHome','coshhHome','coshh')
,('coshhProduct','coshhAssessmentReview','coshh')
,('coshhProduct','coshhAssessmentReview_submit','coshh')
,('coshhProduct','coshhAssessmentReviewSelect','coshh')
,('coshhProduct','coshhPrint','coshh')
,('coshhProduct','coshhProductAllDisplay','coshh')
,('coshhProduct','coshhProductDisplay','coshh')
,('coshhReport','coshhReport','coshh')
,('coshhReport','coshhSDSExpiryReport','coshh')
,('coshhReport','coshhSDSExpiryReportUpdateForm','coshh');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @COSHH_APPROVER_FEATURES;
