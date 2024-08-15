-- =============================================
-- Description: Permit Approver breadcrumb features
-- 14/05/2020 - SG - Adding new breadcrumb
-- 23/06/2020 - DH - Adding new breadcrumb for removing permit tags
-- 10/09/2020 - BOL - Adding new breadcrumb for modify workforce
-- 03/12/2020 - JC - Adding new breadcrumbs Suspend, Renew and View suspended permits
-- 11/10/2021 - JO - Adding new breadcrumb changeReceiver
-- =============================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- Permit Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for permit approver
DECLARE @PERMIT_APPROVER_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('Approve Permit');

INSERT INTO @PERMIT_APPROVER_FEATURES (section,page,appPrefix)
VALUES ('kiosk','kioskHome','permit')
,('permitCreate','permitCreate','permit')
,('permitCreate','permitCreateProcess','permit')
,('permitCreate','permitSelect','permit')
,('permitCreateSubmit','permitSubmit','permit')
,('kiosk','kioskNotification','permit')
,('map','map','permit')
,('map','mapPermit','permit')
,('permitCalendar','permitCalendar','permit')
,('permitCalendar','permitCalendarDisplayPermit','permit')
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
,('permitCreateList','listApproved','permit')
,('permitCreateList','listClosed','permit')
,('permitCreateList','listUnapproved','permit')
,('permitCreateNote','noteAddFromPermitDisplay','permit')
,('permitCreateNote','noteAddFromPermitSchedule','permit')
,('permitCreatePrint','print','permit')
,('permitCreateReview','permitReview','permit')
,('permit','permitRequirement','permit')
,('permit','permitRequirementBasic','permit')
,('permitCreateDisplay','saveField','permit')
,('permitCreateTags','removeTag_submit','permit')
,('permitCreateTags','tagAdd_submit','permit')
,('permitCreate','modifyWorkforce','permit')
,('permitCreateDisplay','renew','permit')
,('permitCreateDisplay','permitDisplayFromSuspended','permit')
,('permitCreateDisplay','suspend','permit')
,('permitCreateDisplay','permitDisplayFromSuspended','permit')
,('permitCreateList','listSuspended','permit')
,('permitCreate','changeApprover_submit','permit')
,('permitCreate','changeReceiver','permit')
;

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @PERMIT_APPROVER_FEATURES;
