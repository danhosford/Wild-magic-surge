-- =====================================================
-- Author:      Alexandre Tran
-- Create date: 30/01/2019
-- Description: Create random permit type
-- 18/05/2020 - AT - Reduce number of permit type
-- 22/08/2020 - AT - Use name instead of ptname
-- =====================================================
DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PERMIT_NAME VARCHAR(255) = 'PermitType';
DECLARE @PERMIT_INITIAL VARCHAR(10) = 'PT';
DECLARE @permitFields AS test.permitFields;
DECLARE @permitWorkflow AS test.workflow;

SET NOCOUNT ON;

INSERT @permitFields (
-- Page
ppName,ppOrder
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
,[ptCanAddWorkforce],[ptCanAddSignature],[ptValidateCompany]
)
VALUES ('Permit Detail',1,'Description of Work','pDescription',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0)
,('Permit Detail',1,'Date of Work','pDateOfWorkStart',1,2,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0)
,('Permit Detail',1,'Start Time of Work','pTimeStart',1,3,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0)
,('Permit Detail',1,'End Time of Work','pTimeEnd',1,4,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0)
,('Permit Detail',1,'Location of Work','pLocation',1,5,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0)
,('Permit Detail',1,'Permit Approver','pApprover',1,6,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,1,1,0,0,'',0,0,0,0,0,0,0);

INSERT INTO @permitWorkflow ([type],[in],[out],[order])
VALUES(@PERMIT_NAME,'Submitted','Awaiting Approval',1);

DECLARE @counter INT;
SET @counter = 1;
WHILE @counter < 3 BEGIN
	UPDATE @permitFields
	SET [name] = CONCAT(@PERMIT_NAME,@counter)

	EXEC test.createPermitForm @KIOSKID=@KIOSKID
	,@FormFields=@permitFields
	,@workflow=@permitWorkflow;

	SET @counter += 1;
END


      