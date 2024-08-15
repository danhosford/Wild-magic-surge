-- =============================================
-- Author:      Jamie Conroy
-- Create date: 25/03/2020
-- Description: Generate pre approval permit
-- Parameters:
-- 22/08/2020 - AT - Use name instead of ptname
-- =============================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PERMIT_NAME VARCHAR(255) = 'PreApproval';
DECLARE @PERMIT_INITIAL VARCHAR(10) = 'PA';
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
,[pfSelectValueMandatory]
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
,[ptCanAddWorkforce],[ptCanAddSignature],[ptValidateCompany],[ptCanChangePreApprover]
)
VALUES ('Permit Detail',1,'Description of Work','pDescription',1,1,1,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'Date of Work','pDateOfWorkStart',1,2,1,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'Start Time of Work','pTimeStart',1,3,1,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'End Time of Work','pTimeEnd',1,4,1,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'Location of Work','pLocation',1,5,1,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'Host Email Address','email',1,6,0,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'Sub-Location 2','locationLevel2CFC',1,7,0,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'Sub-Location 3','locationLevel3CFC',1,8,0,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Permit Detail',1,'Pre Approver','preApprover',1,9,0,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1)
,('Workforce',2,'Workforce Selection','contractorSearch',1,1,0,0,'','0',0,0,0,'PreApproval',1,1,'PA',0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0,1);

INSERT INTO @permitWorkflow ([type],[in],[out],[order])
VALUES(@PERMIT_NAME,'Submitted','Awaiting Pre-Approval',1);

EXEC test.createPermitForm @KIOSKID=@KIOSKID
,@FormFields=@permitFields
,@workflow=@permitWorkflow;
