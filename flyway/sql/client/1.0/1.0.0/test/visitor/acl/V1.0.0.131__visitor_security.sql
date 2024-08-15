-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 26/11/2020
-- Description: Visitor Security breadcrumb features
-- =============================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- Permit Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for permit approver
DECLARE @VISITOR_SECURITY test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('Visitor Security');

INSERT INTO @VISITOR_SECURITY (section,page,appPrefix)
VALUES ('user','userTableAllOptionsAccess','visitor')
,('visitorBadge','printAllVisitorBadges','visitor')
,('visitorBadge','printVisitorBadge','visitor')
,('visitorCalendar','CalendarDisplay','visitor')
,('visitorDisplay','myVisitorsDisplay','visitor')
,('visitorDisplay','security','visitor')
,('visitorDisplay','security_load','visitor')
,('visitorDisplay','visitorFormDisplay','visitor')
,('visitorHome','visitorHome','visitor')
,('visitorMuster','visitorMuster','visitor')
,('visitorReport','visitorReport','visitor')
,('visitorUser','savePPESafetyRequirements_submit','visitor')
,('visitorUser','saveVisitorNotes_submit','visitor')
,('visitorUser','showCurrentPPESafetyRequirements','visitor')
,('visitorUser','showCurrentVisitorHistory','visitor')
,('visitorUser','showCurrentVisitorNotes','visitor')
,('visitorUser','showCurrentVisitorPermit','visitor')
,('visitorUser','showCurrentVisitorPermitNumber','visitor')
,('visitorUser','uploadNotesFile_submit','visitor')
,('visitorUser','userModify_display','visitor')
,('visitorUser','userModify_submit','visitor')
,('visitorUser','userPhoto_submit','visitor')
;

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @VISITOR_SECURITY;
