-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 26/11/2020
-- Description: Visitor Booker breadcrumb features
-- =============================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- Permit Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for permit approver
DECLARE @VISITOR_BOOKER test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('Visitor Booker');

INSERT INTO @VISITOR_BOOKER (section,page,appPrefix)
VALUES ('visitorCreate','visitorCreate','visitor')
,('visitorCreate','visitorCreateSubmit','visitor')
,('visitorCreate','VisitorCreateSubmitted','visitor')
,('visitorDisplay','myVisitorsDisplay','visitor')
,('visitorDisplay','security','visitor')
,('visitorDisplay','security_load','visitor')
,('visitorHome','visitorHome','visitor')
,('visitorMuster','visitorMuster','visitor')
;

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @VISITOR_BOOKER;
