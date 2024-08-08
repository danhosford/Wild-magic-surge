-- =========================================================================================================
-- Author:      Shane Gibbons
-- Create date: 28/09/2021
-- Description: Permit Receiver breadcrumb features
-- CHANGELOG:
-- 28/09/2021 - SG - Adding new breadcrumbs for Permit Receiver
-- =========================================================================================================
DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- Permit Receiver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for permit receiver
DECLARE @PERMIT_RECEIVER_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('Permit Receiver');

INSERT INTO @PERMIT_RECEIVER_FEATURES (section,page,appPrefix)
VALUES ('configureACLGroup','configureACLGroup','permit')
,('contractor','contractor','permit')
,('contractor','contractorAdd','permit')
,('contractor','contractorCompany','permit')
,('contractor','contractorCompanyEdit','permit')
,('contractor','contractorEdit','permit')
,('contractor','qualification','permit')
,('contractor','qualificationEdit','permit')
,('kiosk','kioskHome','permit')
,('map','map','permit')
,('permitCalendar','permitCalendar','permit')
,('permitCalendar','permitCalendarDisplayPermit','permit')
,('permitCreate','allTemplates','permit')
,('permitCreate','modifyWorkforce','permit')
,('permitCreate','permitCreate','permit')
,('permitCreate','permitCreateAttach','permit')
,('permitCreate','permitCreateProcess','permit')
,('permitCreate','permitSelect','permit')
,('permitCreate','savedTemplates','permit')
,('permitCreateApprover','permitReview','permit')
,('permitCreateCancel','permitCancel','permit')
,('permitCreateClose','permitClose','permit')
,('permitCreateDisplay','permitDisplay','permit')
,('permitCreateDisplay','permitDisplayFromApproved','permit')
,('permitCreateDisplay','permitDisplayFromCalendar','permit')
,('permitCreateDisplay','permitDisplayFromClosed','permit')
,('permitCreateDisplay','permitDisplayFromNotification','permit')
,('permitCreateDisplay','permitDisplayFromPermitSchedule','permit')
,('permitCreateDisplay','permitDisplayFromReport','permit')
,('permitCreateDisplay','permitDisplayFromUnapproved','permit')
,('permitCreateDisplay','permitUnapproved','permit')
,('permitCreateDisplay','renew','permit')
,('permitCreateDisplay','suspend','permit')
,('permitCreateList','listApproved','permit')
,('permitCreateList','listClosed','permit')
,('permitCreateList','listImportantPermit','permit')
,('permitCreateList','listMySubmitted','permit')
,('permitCreateList','listUnapproved','permit')
,('permitCreateNote','noteAddFromPermitDisplay','permit')
,('permitCreateNote','noteAddFromPermitSchedule','permit')
,('permitCreatePrint','print','permit')
,('permitCreateReview','permitReview','permit')
,('permitCreateSubmit','permitSubmit','permit')
;

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @PERMIT_RECEIVER_FEATURES;
