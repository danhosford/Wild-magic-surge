-- ==============================================================================
-- Author:      Shane Gibbons
-- Create date: 26/11/2020
-- Description: Set up the acl settings for the COSHH Requestor group
-- CHANGELOG:
-- ==============================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- COSHH Requestor list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for COSHH Requestor
DECLARE @COSHH_REQUESTOR_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('COSHH Requestor');

INSERT INTO @COSHH_REQUESTOR_FEATURES (section,page,appPrefix)
VALUES ('coshhHome','coshhHome','coshh')
,('coshhProduct','coshhPrint','coshh')
,('coshhProduct','coshhProductCreate','coshh')
,('coshhProduct','coshhProductDisplay','coshh')
,('coshhProduct','coshhProductModify','coshh')
,('coshhProduct','coshhProductModify_submit','coshh')
,('coshhProduct','coshhProductRejectedSelect','coshh');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @COSHH_REQUESTOR_FEATURES;
