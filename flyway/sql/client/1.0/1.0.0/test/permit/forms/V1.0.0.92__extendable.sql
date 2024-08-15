-- =============================================
-- Author:      Shane Gibbons
-- Create date: 30/04/2020
-- Description: Generate Extendable permit
-- Parameters:
-- CHANGELOG:
-- 19/05/2020 - JC - Ensuring both ptValidateWorkforce and ptValidateCompany are turned on
-- 25/05/2020 - PM - Removed freetext fields for contractor and contractor company, not needed
-- 22/08/2020 - AT - Use name instead of ptname
-- =============================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PERMIT_NAME VARCHAR(255) = 'Extendable';
DECLARE @PERMIT_INITIAL VARCHAR(10) = 'EX';
DECLARE @permitFields AS test.permitFields;
DECLARE @permitWorkflow AS test.workflow;

SET NOCOUNT ON;

INSERT @permitFields (
-- Page
pp.ppName,pp.ppOrder
-- Field
,[pfNarrative],[pfFieldType]
,[pfIsActive],[pfOrder],[pfIsMandatory],[pfIsDefault]
,[pfClass],[pfSection],[pfSelectID],[pfSelectValue]
,[pfSelectValueMandatory],[canEdit]
-- Type
,[name],[ptIsActive],[ptIsGeneralPermit],[ptInitial]
,[ptIsHazardous],[ptIsHotWorkPermit],[ptIsLockoutPermit]
,[ptPrintSetupFile],[ptLogoImage],[ptIsDocumentAttachMandatory]
,[ptCanSelfApprove],[ptIsContractorSearchMandatory],[ptIsDocumentSearchMandatory]
,[ptOrder]
,[ptIsPermitConflict],[ptIsConflictManager]
,[ptDisplayRequirementBar]
,[ptUseACL]
,[ptConflictManagerLocationLevel1FieldName],[ptConflictManagerLocationLevel2FieldName],[ptConflictManagerLocationLevel3FieldName],[ptConflictManagerLocationLevel3AdditionalFieldName]
,[ptConflictManagerStartDateOfWorkFieldName],[ptConflictManagerEndDateOfWorkFieldName]
,[ptConflictManagerStartTimeFieldName],[ptConflictManagerEndTimeFieldName]
,[ptMandatoryToClosePermit]
,[isTimeValidationStartBeforeEndTimeMandatory],[isTimeValidationCreateInPastNotAllowed]
,[maxLengthOfPermitDay],[maxLengthOfPermitHour]
,[ptColour],[ptContractorModuleInUse]
,[ptApproverByLocation],[ptApproverByLocationLevel]
,[ptValidateWorkforce]
,[ptCanAddWorkforce],[ptCanAddSignature],[ptValidateCompany]
)
VALUES ('Permit Detail',1,'Description of Work','pDescription',1,1,1,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Permit Detail',1,'Start Date of Work','pDateOfWorkStart',1,2,1,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Permit Detail',1,'Start Time of Work','pTimeStart',1,3,1,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Permit Detail',1,'End Date of Work','dateOfWorkEnd',1,4,1,0,'','0',0,0,0,2,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Permit Detail',1,'End Time of Work','pTimeEnd',1,5,1,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Permit Detail',1,'Location of Work','pLocation',1,6,1,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Documentation',2,'Risk Assessment','permitDocument',1,1,1,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,1,1,1,1,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Workforce',3,'Workforce','contractorSearch',1,1,0,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1)
,('Submit',4,'Permit Approver','pApprover',1,1,1,0,'','0',0,0,0,0,'Extendable',1,1,'EX',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,1,0,0,1);

INSERT INTO @permitWorkflow ([type],[in],[out],[order])
VALUES(@PERMIT_NAME,'Submitted','Awaiting Approval',1);

UPDATE [dbo].[documentApprovalGroupSetting] SET [dagsED] = 1 WHERE [dagsIsActive] = 1;

EXEC test.createPermitForm @KIOSKID=@KIOSKID
,@FormFields=@permitFields
,@workflow=@permitWorkflow;