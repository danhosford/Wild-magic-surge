-- =============================================
-- Author:      Jamie Conroy
-- Create date: 26/03/2020
-- Description: Set up the acl settings for the workflow controller group
-- Parameters:
-- Change Control: 
-- 09/12/2021 - LK - Adding permitPreApprovalDisplay breadcrumb
-- 10/01/2022 - LK - Adding noteAddFromPermitPreApprovalDisplay breadcrumb

-- =============================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- Workflow Controller list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for Workflow Controller
DECLARE @WORKFLOW_CONTROLLER_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('Workflow Controller');

INSERT INTO @WORKFLOW_CONTROLLER_FEATURES (section,page,appPrefix)
VALUES ('kiosk','kioskHome','permit')
,('permitCreate','changeApprover_submit','permit')
,('permitCreate','modifyWorkforce','permit')
,('permitCreateDisplay','permitPreApprovalDisplay','permit')
,('permitCreateNote','noteAddFromPermitPreApprovalDisplay','permit')
,('permitCreateApprover','permitReview','permit')
,('permitCreateDisplay','permitDisplay','permit')
,('permitCreateDisplay','permitDisplayFromApproved','permit')
,('permitCreateDisplay','permitDisplayFromCalendar','permit')
,('permitCreateDisplay','permitDisplayFromClosed','permit')
,('permitCreateDisplay','permitDisplayFromNotification','permit')
,('permitCreateDisplay','permitDisplayFromPermitSchedule','permit')
,('permitCreateDisplay','permitDisplayFromReport','permit')
,('permitCreateDisplay','permitDisplayFromUnapproved','permit')
,('permitCreateDisplay','permitUnapproved','permit')
,('permitCreateList','listUnapproved','permit')
,('permitCreateList','listPreApproved','permit');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @WORKFLOW_CONTROLLER_FEATURES;
