-- ==========================================================
-- Author:      Nick King
-- Create date: 21/04/2020
-- Description: Setup signature permit
-- * 06/05/2020 - NK - Added ptCanApproverAddSignature
-- * 08/06/2020 - SG - Setting ptCanAddSignature to 1 and adding Workforce tab
-- * 22/08/2020 - AT - Use name instead of ptname
-- * 14/10/2020 - SG - Added ptCanCloserAddSignature 
-- ==========================================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PERMIT_NAME VARCHAR(255) = 'Signature';
DECLARE @PERMIT_INITIAL VARCHAR(10) = 'SI';
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
,[ptCanAddWorkforce],[ptCanAddSignature],[ptValidateCompany],[ptCanApproverAddSignature],[ptCanCloserAddSignature],[ptCanChangeApprover]
)
VALUES ('Permit Detail',1,'Description of Work','pDescription',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,0,0,0,0,'',0,0,0,0,1,1,0,1,1,1)
,('Permit Detail',1,'Date of Work','pDateOfWorkStart',1,2,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,0,0,0,0,'',0,0,0,0,1,1,0,1,1,1)
,('Permit Detail',1,'Start Time of Work','pTimeStart',1,3,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,0,0,0,0,'',0,0,0,0,1,1,0,1,1,1)
,('Permit Detail',1,'End Time of Work','pTimeEnd',1,4,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,0,0,0,0,'',0,0,0,0,1,1,0,1,1,1)
,('Permit Detail',1,'Location of Work','pLocation',1,5,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,0,0,0,0,'',0,0,0,0,1,1,0,1,1,1)
,('Permit Detail',1,'Approver','pApprover',1,6,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,0,0,0,0,'',0,0,0,0,1,1,0,1,1,1)
,('Workforce',2,'Workforce','contractorSearch',1,1,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,1,'','','','0','','','','',1,0,0,0,0,'',0,0,0,0,1,1,0,1,1,1)
;

INSERT INTO @permitWorkflow ([type],[in],[out],[order])
VALUES(@PERMIT_NAME,'Submitted','Awaiting Approval',1);

EXEC test.createPermitForm @KIOSKID=@KIOSKID
,@FormFields=@permitFields
,@workflow=@permitWorkflow;

INSERT INTO [dbo].[permitTypeAddWorkforceStatus]
      ([ptID]
      ,[permitStatusID]
      ,[ptawsIsActive]
      ,[ptawsAddedUTC]
      ,[ptawsAddedBy]
      ,[kioskID])
SELECT [pt].[ptID]
        ,2
        ,1
        ,GETUTCDATE()
        ,0
        ,@KIOSKID
FROM  [dbo].[permitType] AS [pt]
WHERE [pt].[ptName] = @PERMIT_NAME
AND   [pt].[kioskID] = @KIOSKID