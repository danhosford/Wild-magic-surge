-- ==========================================================================================
-- Author:      Jamie Conroy
-- Create date: 04/01/2021
-- Description: Set up the acl settings for the MOC Administrator group
-- CHANGELOG:
-- 26/11/2021 - Enabling new breadcrumb for "Change MOC Owner" option
-- ==========================================================================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

-- MOC Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for MOC Approver
DECLARE @MOC_APPROVER_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('MOC Administrator');

INSERT INTO @MOC_APPROVER_FEATURES (section,page,appPrefix)
VALUES ('moc','mocHome','moc')
,('moc','mocNotification', 'moc')
,('mocActionTask', 'mocActionTaskAction', 'moc')
,('mocActionTask', 'mocActionTaskAction_submit', 'moc')
,('mocActionTask', 'mocActionTaskConditionAcceptance', 'moc')
,('mocActionTask', 'mocActionTaskConditionAcceptance_submit', 'moc')
,('mocActionTask', 'mocActionTaskConditionForm','moc')
,('mocActionTask', 'mocActionTaskConditionForm_submit', 'moc')
,('mocActionTask', 'mocActionTaskConditionList', 'moc')
,('mocActionTask', 'mocActionTaskCreate', 'moc')
,('mocActionTask', 'mocActionTaskCreate_submit', 'moc')
,('mocActionTask', 'mocActionTaskDisplay', 'moc')
,('mocActionTask', 'mocActionTaskDisplayFromMOC','moc')
,('mocActionTask', 'mocActionTaskDisplayFromMy','moc')
,('mocActionTask', 'mocActionTaskHistory','moc')
,('mocActionTask', 'mocActionTaskList','moc')
,('mocActionTask', 'mocActionTaskReminderForm','moc')
,('mocActionTask', 'mocActionTaskReminderForm_submit','moc')
,('mocActionTask', 'mocMyActionTaskList','moc')
,('mocActionTask', 'mocUploadActionTaskFiles','moc')
,('mocAdmin', 'mocFieldApproverType','moc')
,('mocAdmin', 'mocFieldApproverType_submit','moc')
,('mocApprover', 'mocAddNewGroup','moc')
,('mocApprover', 'mocAdminApproverByLocation','moc')
,('mocApprover', 'mocAdminApproverModify','moc')
,('mocApprover', 'mocAdminApproverModify_submit','moc')
,('mocApprover', 'mocAdminApprovers','moc')
,('mocApprover', 'mocApprover','moc')
,('mocApprover', 'mocCreateApproverList','moc')
,('mocApprover', 'mocCreateApproverModify','moc')
,('mocApprover', 'mocCreateApproverModify_submit','moc')
,('mocApprover', 'mocCreateApproverModify_submit','moc')
,('mocCreate', 'mocCreate','moc')
,('mocCreate', 'mocCreateSubmit','moc')
,('mocCreate', 'savedTemplates','moc')
,('mocDisplay', 'kbcSectionHeading','moc')
,('mocDisplay', 'kbcSectionHeading','moc')
,('mocDisplay', 'kbcSectionHeading','moc')
,('mocDisplay', 'mocActivate_submit','moc')
,('mocDisplay', 'mocApprovalForm','moc')
,('mocDisplay', 'mocApprovalForm_submit','moc')
,('mocDisplay', 'mocCloseForm','moc')
,('mocDisplay', 'mocCloseForm_submit','moc')
,('mocDisplay', 'mocDetailsDisplay','moc')
,('mocDisplay', 'mocDisplay','moc')
,('mocDisplay', 'mocDisplayFromActive','moc')
,('mocDisplay', 'mocDisplayFromAwaitingApproval','moc')
,('mocDisplay', 'mocDisplayFromAwaitingClosure','moc')
,('mocDisplay', 'mocDisplayFromAwaitingMyApproval','moc')
,('mocDisplay', 'mocDisplayFromAwaitingMyClosure','moc')
,('mocDisplay', 'mocDisplayFromPending','moc')
,('mocDisplay', 'mocFormTable','moc')
,('mocDisplay', 'mocHistory','moc')
,('mocDisplay', 'mocList','moc')
,('mocDisplay', 'mocListMyActive','moc')
,('mocDisplay', 'mocListMyApproval','moc')
,('mocDisplay', 'mocListMyAwaiting','moc')
,('mocDisplay', 'mocListMyPending','moc')
,('mocDisplay', 'mocPdf','moc')
,('mocDisplay', 'mocSendForApproval','moc')
,('mocDisplay', 'mocSendForApproval_submit','moc')
,('mocDisplay', 'mocSendForClosure','moc')
,('mocDisplay', 'mocSendForClosure_submit','moc')
,('mocReport', 'mocActionTaskReport','moc')
,('mocReport', 'mocReport','moc')
,('mocUser', 'user','moc')
,('mocUser', 'userAdd','moc')
,('user', 'userTableAllOptionsAccess','moc')
,('mocReport', 'requests','moc')
,('mocReport', 'tasks','moc')
,('mocDisplay', 'mocChangeOwner_submit','moc')
;

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @MOC_APPROVER_FEATURES;