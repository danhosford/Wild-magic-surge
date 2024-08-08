-- ==============================================================================
-- Author:      Shane Gibbons
-- Create date: 26/11/2020
-- Description: Set up the acl settings for the COSHH Assessor group
-- CHANGELOG:
-- ==============================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- COSHH Assessor list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for COSHH Assessor
DECLARE @COSHH_ASSESSOR_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('COSHH Assessor');

INSERT INTO @COSHH_ASSESSOR_FEATURES (section,page,appPrefix)
VALUES ('coshhHome','coshhHome','coshh')
,('coshhProduct','coshhPrint','coshh')
,('coshhProduct','coshhProductAssess','coshh')
,('coshhProduct','coshhProductAssessSelect','coshh')
,('coshhProduct','coshhProductAssessSubmit','coshh')
,('coshhProduct','coshhProductDisplay','coshh')
,('coshhReport','coshhReport','coshh')
,('coshhReport','coshhSDSExpiryReport','coshh')
,('coshhReport','coshhSDSExpiryReportUpdateForm','coshh');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @COSHH_ASSESSOR_FEATURES;
