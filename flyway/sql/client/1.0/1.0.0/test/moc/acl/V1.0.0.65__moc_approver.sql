-- ==========================================================================================
-- Author:      Jamie Conroy
-- Create date: 26/03/2020
-- Description: Set up the acl settings for the MOC Approver group
-- CHANGELOG:
-- 01/07/2020 - AT - Remove uncessary space in pages name making not existing breadcrumb
-- ==========================================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- MOC Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for MOC Approver
DECLARE @MOC_APPROVER_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('MOC Approver');

INSERT INTO @MOC_APPROVER_FEATURES (section,page,appPrefix)
VALUES ('moc','mocHome','moc')
,('mocActionTask','mocActionTaskConditionForm','moc')
,('mocActionTask','mocActionTaskConditionForm_submit','moc')
,('mocActionTask','mocActionTaskConditionList','moc')
,('mocActionTask','mocActionTaskDisplay','moc')
,('mocActionTask','mocActionTaskDisplayFromMOC','moc')
,('mocActionTask','mocActionTaskDisplayFromMy','moc')
,('mocActionTask','mocActionTaskHistory','moc')
,('mocActionTask','mocActionTaskList','moc')
,('mocDisplay','kbcSectionHeading','moc')
,('mocDisplay','mocApprovalForm','moc')
,('mocDisplay','mocApprovalForm_submit','moc')
,('mocDisplay','mocCloseForm','moc')
,('mocDisplay','mocCloseForm_submit','moc')
,('mocDisplay','mocDetailsDisplay','moc')
,('mocDisplay','mocApprovalForm_submit','moc')
,('mocDisplay','mocDisplay','moc')
,('mocDisplay','mocDisplayFromAwaitingMyApproval','moc')
,('mocDisplay','mocDisplayFromAwaitingMyClosure','moc')
,('mocDisplay','mocFormTable','moc')
,('mocDisplay','mocHistory','moc')
,('mocDisplay','mocList','moc')
,('mocDisplay','mocListMyAwaiting','moc')
,('mocDisplay','mocNoteAdd_submit','moc')
,('mocDisplay','mocNoteDisplay','moc')
,('mocDisplay','mocPdf','moc');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @MOC_APPROVER_FEATURES;