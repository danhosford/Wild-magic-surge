-- ==============================================================================
-- Author:      Shane Gibbons
-- Create date: 26/11/2020
-- Description: Set up the acl settings for the COSHH View Only group
-- CHANGELOG:
-- ==============================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- COSHH View Only list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for COSHH View Only
DECLARE @COSHH_VIEW_ONLY_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('COSHH View Only');

INSERT INTO @COSHH_VIEW_ONLY_FEATURES (section,page,appPrefix)
VALUES ('coshhHome','coshhHome','coshh')
,('coshhMap','coshhMap','coshh')
,('coshhProduct','coshhPrint','coshh')
,('coshhProduct','coshhProductAllDisplay','coshh')
,('coshhProduct','coshhProductApproved','coshh')
,('coshhProduct','coshhProductApprovedDisplay','coshh')
,('coshhProduct','coshhProductDisplay','coshh')
,('coshhReport','coshhReport','coshh')
,('coshhReport','coshhSDSExpiryReport','coshh');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @COSHH_VIEW_ONLY_FEATURES;
