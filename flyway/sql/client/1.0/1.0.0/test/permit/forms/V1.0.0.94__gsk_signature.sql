-- ==========================================================
-- Author:      Alexandre Tran
-- Create date: 17/09/2020
-- Description: Setup GSK signature permit
-- 28/09/2020 - JC - Ensuring the permit fields are linked 
-- ==========================================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PERMIT_NAME VARCHAR(255) = 'GSK Signature';
DECLARE @PERMIT_INITIAL VARCHAR(10) = 'GSK';
DECLARE @permitFields AS test.permitFields;
DECLARE @permitWorkflow AS test.workflow;
DECLARE @count INT = 0;
DECLARE @batchSize INT = 50;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

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
,[ptCanAddWorkforce],[ptCanAddSignature],[ptValidateCompany],[ptCanApproverAddSignature]
) VALUES 
('Permit Detail',1,'Description of Work','pDescription',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Date of Work','pDateOfWorkStart',1,2,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Start Time of Work','pTimeStart',1,4,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'End Time of Work','pTimeEnd',1,5,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Building','pLocation',1,6,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'End Date of Work','dateOfWorkEnd',1,3,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Area','locationLevel2CFC',1,7,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Additional Location Details','textarea',1,8,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Other Permits Required','sectionDetail',1,14,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Hot Work','yesNoRadio',1,15,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Red Tag','yesNoRadio',1,16,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Confined Space','yesNoRadio',1,17,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Contractor Plant and equipment to be used','textarea',1,10,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'High Voltage','yesNoRadio',1,18,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'Plant and equipment to be worked on:','textarea',1,9,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'ECC Number:','yesNoNARadio',1,11,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Permit Detail',1,'ECC Number:','textLine',1,12,0,0,'1627','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'Weekend Work','yesNoRadio',1,2,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'If answering YES to weekend work and method statement not required, rational required.','textarea',1,3,0,0,'1629','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'l','blankLine',1,5,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'Lifting Equipment Controls','sectionDetail',1,6,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'Fork Lift / Crane reviewed & size appropriately for lift(s)?','yesNoNARadio',1,7,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'Certification of all lifting equipment received, reviewed & within date?','yesNoNARadio',1,8,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'Forklift of Crane driver / banks man trained & competent - All record reviewed?','yesNoNARadio',1,9,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Hazard and Precautions',11,'Has sufficient resources been allocated for weekend eg, GSK Supervision, First Aid, Authorised worker etc','yesNoRadio',1,4,0,0,'1629','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Safety Boots','checkbox',1,1,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Harness','checkbox',1,13,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Gloves','checkbox',1,3,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Hard Hat','checkbox',1,9,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Chemical Suit','checkbox',1,12,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Other PPE Required','textarea',1,25,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Glove type','textLine',1,4,0,0,'1639','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Safety Glasses (light eye protection)','checkbox',1,5,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Safety Goggles (EN166B)','checkbox',1,6,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Face Visor (EN166B)','checkbox',1,7,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'High vis clothing','checkbox',1,2,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Hearing protection','checkbox',1,8,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Respiratory protection','checkbox',1,10,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Respiratory protection type','textLine',1,11,0,0,'1649','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'Lab Coat','checkbox',1,15,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('PPE &amp; Approval',12,'GMP Garb','checkbox',1,16,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Documentation',2,'Attach Document (1)','attachment',1,4,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Documentation',2,'Attach Document (2)','attachment',1,5,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Documentation',2,'Attach Document (3)','attachment',1,6,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Documentation',2,'Does work require a Method Statement / Risk Assessment?','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Documentation',2,'References: (Method Statement/Risk Assessment, Drawing No., LSOP):','textarea',1,3,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Documentation',2,'Justify','textarea',1,2,0,0,'1656','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Documentation',2,'Risk Assessment &#x2f; Method Statement&#x3a;','permitDocument',1,7,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Workforce',13,'Are contractors working on this job?','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Workforce',13,'Workforce','contractorSearch',1,2,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Will the work require working at height','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Can the work be completed from a podium ladder','yesNoRadio',1,2,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Scaffold','yesNoRadio',1,4,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Scaffold inspected, Scafftag has been signed','yesNoRadio',1,6,0,0,'1664','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Suitable ladder access in place','yesNoRadio',1,7,0,0,'1664','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Comments','textarea',1,8,0,0,'1664','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Mobile Elevated Working Platform (MEWP)','yesNoRadio',1,9,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'MEWP checklist completed by the operator','yesNoRadio',1,10,0,0,'1668','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Lifting equipment has been checked and fit for use','yesNoRadio',1,11,0,0,'1668','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Harness has been checked by user and is fit for use','yesNoRadio',1,13,0,0,'1668','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'MEWP been used on suitable firm ground','yesNoRadio',1,15,0,0,'1668','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Comments','textarea',1,16,0,0,'1668','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'.','blankLine',1,17,0,0,'1662','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Ladder','yesNoRadio',1,18,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Is the  work short duration and low risk','yesNoRadio',1,19,0,0,'1675','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Is the floor space/ ground conditions level, firm and free from trip hazards','yesNoRadio',1,20,0,0,'1675','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Has a GA3 form been completed for the ladder','yesNoRadio',1,21,0,0,'1675','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'.','blankLine',1,22,0,0,'1662','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'.','blankLine',1,3,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'.','blankLine',1,23,0,0,'1662','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Is there safe access to the work area','yesNoRadio',1,28,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Is there a safe method of taking materials to the area','yesNoRadio',1,29,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Is there adequate edge protection in place','yesNoRadio',1,30,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Is a personal fall protection system in place and used with a safely designed anchorage point (Specify)','textarea',1,32,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Emergency arrangements :Is there suitable access equipment readily available to rescue a person suspended in a harness (Please specify)','textarea',1,14,0,0,'1668','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Scaffold erected by a competent person and handover cert received','yesNoRadio',1,5,0,0,'1664','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Comments','textarea',1,24,0,0,'1662','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Operator trained to use MEWP','yesNoRadio',1,12,0,0,'1668','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Will work require access via CAT C Roof?','yesNoRadio',1,25,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Additional Approval Required','sectionDetail',1,26,0,0,'1690','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Will work require penetrating Roof?','yesNoRadio',1,27,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Specify what will be put in place.','textarea',1,31,0,0,'1684','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Is an exclusion zone required around the works and in the area below?','yesNoRadio',1,34,0,0,'1662','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Work at height',3,'Proceed to next tab.','sectionDetail',1,35,0,0,'1662','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Have all underground drawings being checked and attached','yesNoRadio',1,4,0,0,'1712','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Is the operator trained in the use of the cable avoidance tool (CAT)','yesNoRadio',1,8,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'What shoring  mechanism(s) will be used','sectionDetail',1,10,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Benching','checkbox',1,11,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Battering','checkbox',1,12,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Step','checkbox',1,13,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Trench box','checkbox',1,14,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Other','textLine',1,15,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Details of the excavators and associated equipment to be used','textLine',1,18,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Details of safe egress and exit arrangements','textLine',1,19,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'.','blankLine',1,16,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Size and Depth of excavation','textLine',1,3,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Includes all earthworks and above surface penetration works eg footpath, plinths, floors','sectionDetail',1,1,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Have cable avoidance tool (CAT) being used to trace and mark services','yesNoRadio',1,6,0,0,'1712','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Details of the method for spoil removal','textLine',1,17,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'No mechanical digging within 500 millimetres of any known services&#x21;','sectionDetail',1,39,0,0,'1727','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Will the work involve penetrating the surface?','yesNoRadio',1,2,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Electricity','checkbox',1,23,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'If No, DO NOT CONTINUE','sectionDetail',1,5,0,0,'1696','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'If No, DO NOT CONTINUE','sectionDetail',1,7,0,0,'1709','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Verify Certification is up to Date','textLine',1,9,0,0,'1697','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Identification of Service&#x28;s&#x29;','sectionDetail',1,22,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Buried Services','sectionDetail',1,21,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Proceed to next tab.','sectionDetail',1,20,0,0,'1712','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Gas &#x2f; Air','checkbox',1,25,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Towns Water','checkbox',1,27,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Sprinkler Main','checkbox',1,29,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Drains','checkbox',1,31,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Communications','checkbox',1,33,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Other','checkbox',1,35,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Trial trenches to be hand dug to locate services&#x3f;','yesNARadio',1,37,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Excavation to be carried out by mechanical means','yesNARadio',1,38,0,0,'1712','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Drawing Ref. &#x2f; Comments','textLine',1,24,0,0,'1713','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Drawing Ref. &#x2f; Comments','textLine',1,26,0,0,'1720','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Drawing Ref. &#x2f; Comments','textLine',1,28,0,0,'1721','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Drawing Ref. &#x2f; Comments','textLine',1,30,0,0,'1722','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Drawing Ref. &#x2f; Comments','textLine',1,32,0,0,'1723','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Drawing Ref. &#x2f; Comments','textLine',1,34,0,0,'1724','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Excavation',5,'Detail Service &#x2f; Drawing Ref. &#x2f; Comments','textLine',1,36,0,0,'1725','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Energy Sources','sectionDetail',1,3,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Electrical','checkbox',1,4,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Pneumatic','checkbox',1,5,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Hydraulic Pump','checkbox',1,6,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Hydraulic Line','checkbox',1,7,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Water','checkbox',1,8,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Gas','checkbox',1,9,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Chemical or Coolant','checkbox',1,10,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'If only one Energy Source is selected, Simple LOTO is required; If multiple Energy Sources are selected, Complex LOTO is required;','sectionDetail',1,22,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'LOTO Type','dropdown',1,13,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'A second LOTO verification is required by a second Authorised worker prior to issuing this permit','sectionDetail',1,25,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Is there a LOTO Complex document for the equipment?','yesNoRadio',1,14,0,0,'1744','0',0,125,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Name of authorised worker','textLine',1,16,0,0,'1757','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Confirm LOTO is applied before issuing PTW','yesNoRadio',1,17,0,0,'1757','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'LOTO reference number','textLine',1,18,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Confirm GSK lock has been applied by permit issuer','yesNoRadio',1,19,0,0,'1757','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Confirm GSK lock has been applied by affected workers','yesNoRadio',1,20,0,0,'1757','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Exception to LOTO, work on live equipment requires method statement and EHS Manager / Engineering Head Approval','sectionDetail',1,15,0,0,'1754','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Record equipment isolated / Isolation points','textarea',1,21,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Is LOTO feasible','yesNoRadio',1,2,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Method Statement Required','sectionDetail',1,23,0,0,'1746','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'LOTO Complex document name.','textLine',1,24,0,0,'1744','0',0,125,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Is LOTO required','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Compressed Air','checkbox',1,11,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Other','textarea',1,12,0,0,'1757','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Lock out &#x2f; Tag out &#x28;LOTO&#x29;',6,'Proceed to next tab.','sectionDetail',1,26,0,0,'1757','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Line Break',9,'Will the work require the opening of existing services (e.g. process/ gas/ water/ air)','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Line Break',9,'Has the line been depressurised','yesNoRadio',1,3,0,0,'1761','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Line Break',9,'Provide justification','textLine',1,4,0,0,'1762','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Line Break',9,'Where will the content be drained/ dispersed too','textLine',1,5,0,0,'1761','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Line Break',9,'Has LOTO been applied?','yesNoRadio',1,2,0,0,'1761','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Line Break',9,'Comments','textarea',1,6,0,0,'1761','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Line Break',9,'Proceed to next tab.','sectionDetail',1,7,0,0,'1761','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Permit Approver','pApprover',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Does work require a method statement? - Yes','sectionDetail',1,8,0,0,'1656','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Other Permits Required - Red Tag - Yes','sectionDetail',1,5,0,0,'1622','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Other Permits Required - Hot Work - Yes','sectionDetail',1,4,0,0,'1621','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Other Permits Required - Confined Space - Yes','sectionDetail',1,6,0,0,'1623','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Other Permits Required - High Voltage - Yes','sectionDetail',1,7,0,0,'1625','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Will work require access via Roof / walk on ceiling? - Yes','sectionDetail',1,9,0,0,'','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Will work require penetrating Roof / walk on ceiling? - Yes','sectionDetail',1,10,0,0,'','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Will the work require penetrating the surface by 4 inches? -  Yes','sectionDetail',1,11,0,0,'','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Will the work require the opening of existing services (e.g. process/ gas/ water/ air) - Yes','sectionDetail',1,12,0,0,'1761','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Chemical Suit - Checked','sectionDetail',1,15,0,0,'1641','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Additional Approval required','yesNARadio',1,13,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'Additional Approver','approver',1,14,0,0,'1779','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'yes na','yesNARadio',1,14,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'yes no na','yesNoNARadio',1,15,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Submit',14,'yes no','yesNoRadio',1,16,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'A full asbestos removal permit is required and must be attached to this general permit.','sectionDetail',1,9,0,0,'1782','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Is an asbestos removal permit required&#x3f;','yesNoRadio',1,8,0,0,'1789','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'State additional controls&#x3a;','textarea',1,10,0,0,'1782','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Will the work disturb any existing structures, ie Demolition, Drilling, Ground Disturbance?','yesNoRadio',1,2,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'No further action required, proceed to next section/tab.','sectionDetail',1,3,0,0,'1784','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Was the building constructed after 2000?','yesNoRadio',1,4,0,0,'1784','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'No further action required, proceed to next section/tab.','sectionDetail',1,5,0,0,'1786','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Has the asbestos register been reviewed?','yesNoRadio',1,6,0,0,'1786','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Have Asbestos Containing Materials (ACM’s) been found?','yesNoRadio',1,7,0,0,'1788','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Section B','sectionDetail',1,12,0,0,'1788','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'A Full Asbestos Survey is required.','sectionDetail',1,13,0,0,'1788','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Asbestos survey required in location','textLine',1,14,0,0,'1788','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'All other work to stop in this immediate area until Asbestos Survey Results are received.','sectionDetail',1,15,0,0,'1788','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Contract survey company is','textLine',1,16,0,0,'1788','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Have arrangements been made to exclude unauthorised access?','yesNoRadio',1,17,0,0,'1788','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Contact local area management & make exclusion area until survey is completed.','sectionDetail',1,18,0,0,'1795','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Has Asbestos survey contractor competency been confirmed?','yesNoRadio',1,19,0,0,'1795','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Stop work & contact Asbestos survey contractor.','sectionDetail',1,20,0,0,'1797','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Asbestos Survey may begin.   Proceed to next section/tab.','sectionDetail',1,21,0,0,'1797','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Section A','sectionDetail',1,1,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Section C','sectionDetail',1,22,0,0,'1789','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'A Full Asbestos Removal Permit will be required which must be attached to this permit.','sectionDetail',1,23,0,0,'1789','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Has Asbestos removal contractor competency been confirmed?','yesNoRadio',1,25,0,0,'1789','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Stop work & contact asbestos removal contractor.','sectionDetail',1,27,0,0,'1803','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Work in the immediate area to stop until Asbestos has been removed.','sectionDetail',1,24,0,0,'1789','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'No further action required, proceed to next section/tab.','sectionDetail',1,11,0,0,'1789','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'If Yes - Asbestos removal may begin proceed to next tab.','sectionDetail',1,26,0,0,'1803','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asbestos',4,'Drop Down Test','dropdown',1,28,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('ATEX',10,'Are works being performed in an Atex area?','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('ATEX',10,'Have the works been agreed with the supervisor?','yesNoRadio',1,2,0,0,'1808','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('ATEX',10,'Specify Name','textLine',1,3,0,0,'1809','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('ATEX',10,'Please Justify','textLine',1,4,0,0,'1809','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('ATEX',10,'Are all flammable substances removed?','yesNoRadio',1,5,0,0,'1808','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('ATEX',10,'Please Specify','textLine',1,6,0,0,'1812','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('ATEX',10,'Proceed to next tab.','sectionDetail',1,7,0,0,'1808','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Asphyxiant gas to be used&#x3f; E.g. Nitrogen, Argon.','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Can compressed air be used&#x3f;','yesNoRadio',1,3,0,0,'1815','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Use Compressed Air','sectionDetail',1,4,0,0,'1816','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Is location of use inside building or an enclosed area&#x3f;','yesNoRadio',1,6,0,0,'1816','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Ensure asphyxiant risk is assessed as line item in RAMS.','sectionDetail',1,7,0,0,'1818','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Gas to be used&#x3a;','textLine',1,8,0,0,'1818','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'RAMS section refrence &#x28;asphyxiation risk&#x29;&#x3a;','textLine',1,9,0,0,'1818','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Does RAMS state use of O2&#x25; depletion monitors required by each individual on the job&#x3f;','yesNoRadio',1,10,0,0,'1816','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Amend RAMS to include use of individual O2&#x25; depletion monitors.','sectionDetail',1,11,0,0,'1822','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Has equipment been leak tested &#x28;to be done in an external well ventilated area&#x29;, daily requirement&#x3f;','yesNoRadio',1,12,0,0,'1816','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Perform leak test prior to bringing asphyxiant gas cylinder&#x2f;regulator&#x2f;equipment indoors.','sectionDetail',1,13,0,0,'1824','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Does RAMS state removal of cylinder from indoor area when unattended&#x3f;','yesNoRadio',1,14,0,0,'1816','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Amend RAMS to remove cylinder from indoor area when not controlled by individual with O2&#x25; depletion monitors.','sectionDetail',1,15,0,0,'1826','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Do RAMS include area specific O2&#x25; depletion calculation under leakage scenario&#x3f;','yesNoRadio',1,16,0,0,'1828','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Contact EHS representative for area specific calculation to be performed.','sectionDetail',1,17,0,0,'1828','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Is minimum O2&#x25; level on leakage scenario below 19.5&#x25;&#x3f;','yesNoRadio',1,18,0,0,'1816','0',0,0,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'Contact EHS representative for approval.','sectionDetail',1,19,0,0,'1830','0',0,1,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'blank','blankLine',1,2,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'blank','blankLine',1,5,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('Asphyxiant Gas Use',7,'blank','blankLine',1,20,0,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('GxP',8,'Cleaning Method Statement CDMS Ref and Accountable person &#x28;text field&#x29;','textLine',1,5,0,0,'1836','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('GxP',8,'Cleaning Method Statement required','yesNARadio',1,4,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('GxP',8,'Swab plate or Swab Handle will be removed to allow new flooring &#x2f; door installation','yesNoRadio',1,2,0,0,'1838','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('GxP',8,'Does the proposed work impact GxP but not require an ECC or Change Control &#x28;e.g. adjacent to clean area, swabbing regime linked to minor facility works &#x28;flooring, decoration, joinery&#x29;','yesNoRadio',1,1,1,0,'','0',0,0,0,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
,('GxP',8,'GxP Approval','approver',1,3,0,0,'1838','0',0,1,1,@PERMIT_NAME,1,1,@PERMIT_INITIAL,0,0,0,NULL,NULL,0,1,1,0,1,1,0,1,0,'','','','0','','','','',1,1,1,5,0,'',0,0,0,0,1,1,0,1)
;

INSERT INTO @permitWorkflow ([type],[in],[out],[order])
VALUES(@PERMIT_NAME,'Submitted','Awaiting Approval',1);

EXEC test.createPermitForm @KIOSKID=@KIOSKID
,@FormFields=@permitFields
,@workflow=@permitWorkflow;

PRINT 'Create linked Permit Field variable table...';

DECLARE @linkedPermitField TABLE (
  [associatedNarrative] VARCHAR(255) NOT NULL
  ,[associatedFieldType] VARCHAR(255) NOT NULL
  ,[narrative] VARCHAR(255) NOT NULL
  ,[fieldType] VARCHAR(255) NOT NULL
  ,[pfSelectValue] INT NOT NULL
  ,[pfIsMandatory] INT NOT NULL
  ,[pfSelectValueMandatory] INT NOT NULL
  ,[kioskID] INT NOT NULL
  ,[name] VARCHAR(255) NOT NULL
);

PRINT 'Insert Into linked Permit Field table...';

INSERT INTO @linkedPermitField 
VALUES
('ECC Number:','yesNoNARadio','ECC Number:','textLine',1,0,1, @KIOSKID, @PERMIT_NAME)
,('Does work require a Method Statement / Risk Assessment?','yesNoRadio','Justify','textarea',0,0,1, @KIOSKID, @PERMIT_NAME)
--Work at height
,('Will the work require working at height', 'yesNoRadio', 'Can the work be completed from a podium ladder', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Scaffold', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Scaffold', 'yesNoRadio', 'Scaffold erected by a competent person and handover cert received', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Scaffold', 'yesNoRadio', 'Scaffold inspected, Scafftag has been signed', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Scaffold', 'yesNoRadio', 'Suitable ladder access in place', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Scaffold', 'yesNoRadio', 'Comments', 'textarea', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Mobile Elevated Working Platform (MEWP)', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Is the work short duration and low risk', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Mobile Elevated Working Platform (MEWP)', 'yesNoRadio','MEWP checklist completed by the operator','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Mobile Elevated Working Platform (MEWP)', 'yesNoRadio','Lifting equipment has been checked and fit for use','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Mobile Elevated Working Platform (MEWP)', 'yesNoRadio','Operator trained to use MEWP','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Mobile Elevated Working Platform (MEWP)', 'yesNoRadio','Harness has been checked by user and is fit for use','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Mobile Elevated Working Platform (MEWP)', 'yesNoRadio','Emergency arrangements :Is there suitable access equipment readily available to rescue a person suspended in a harness (Please specify)','textarea', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Mobile Elevated Working Platform (MEWP)', 'yesNoRadio','MEWP been used on suitable firm ground','yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Ladder', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Ladder', 'yesNoRadio','Is the work short duration and low risk','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Ladder', 'yesNoRadio','Is the floor space/ ground conditions level, firm and free from trip hazards','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Ladder', 'yesNoRadio','Has a GA3 form been completed for the ladder','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Will work require access via CAT C Roof?', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will work require access via CAT C Roof?', 'yesNoRadio','Additional Approval Required', 'sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Will work require penetrating Roof?', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Is there safe access to the work area', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Is there a safe method of taking materials to the area', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Is there adequate edge protection in place', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Is there adequate edge protection in place', 'yesNoRadio','Specify what will be put in place.','textarea', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Is a personal fall protection system in place and used with a safely designed anchorage point (Specify)', 'textarea', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Is an exclusion zone required around the works and in the area below?', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work require working at height', 'yesNoRadio', 'Proceed to next tab.', 'sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
--Asbestos
,('Will the work disturb any existing structures, ie Demolition, Drilling, Ground Disturbance?', 'yesNoRadio', 'No further action required, proceed to next section/tab.', 'sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work disturb any existing structures, ie Demolition, Drilling, Ground Disturbance?', 'yesNoRadio', 'Was the building constructed after 2000?', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Was the building constructed after 2000?', 'yesNoRadio','Has the asbestos register been reviewed?','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Has the asbestos register been reviewed?','yesNoRadio','Have Asbestos Containing Materials (ACM’s) been found?', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Have Asbestos Containing Materials (ACM’s) been found?', 'yesNoRadio','Is an asbestos removal permit required&#x3f;','yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is an asbestos removal permit required&#x3f;','yesNoRadio','A full asbestos removal permit is required and must be attached to this general permit.','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is an asbestos removal permit required&#x3f;','yesNoRadio','State additional controls&#x3a;','textarea', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Has the asbestos register been reviewed?','yesNoRadio','Section B', 'sectionDetail', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Has the asbestos register been reviewed?','yesNoRadio','A Full Asbestos Survey is required.', 'sectionDetail', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Has the asbestos register been reviewed?','yesNoRadio','Asbestos survey required in location', 'textLine', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Has the asbestos register been reviewed?','yesNoRadio','All other work to stop in this immediate area until Asbestos Survey Results are received.', 'sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Has the asbestos register been reviewed?','yesNoRadio','Contract survey company is', 'textLine', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Has the asbestos register been reviewed?','yesNoRadio','Have arrangements been made to exclude unauthorised access?', 'yesNoRadio', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Have arrangements been made to exclude unauthorised access?', 'yesNoRadio','Contact local area management & make exclusion area until survey is completed.','sectionDetail', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Have arrangements been made to exclude unauthorised access?', 'yesNoRadio','Has Asbestos survey contractor competency been confirmed?','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Has Asbestos survey contractor competency been confirmed?','yesNoRadio','Asbestos Survey may begin.   Proceed to next section/tab.','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Has Asbestos survey contractor competency been confirmed?','yesNoRadio','Stop work & contact asbestos removal contractor.','sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Have Asbestos Containing Materials (ACM’s) been found?', 'yesNoRadio','Section C','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Have Asbestos Containing Materials (ACM’s) been found?', 'yesNoRadio','A Full Asbestos Removal Permit will be required which must be attached to this permit.','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Have Asbestos Containing Materials (ACM’s) been found?', 'yesNoRadio','Work in the immediate area to stop until Asbestos has been removed.','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Have Asbestos Containing Materials (ACM’s) been found?', 'yesNoRadio','Has Asbestos removal contractor competency been confirmed?','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Has Asbestos removal contractor competency been confirmed?','yesNoRadio','If Yes - Asbestos removal may begin proceed to next tab.','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Has Asbestos survey contractor competency been confirmed?','yesNoRadio','Stop work & contact asbestos removal contractor.','sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
--Excavation
,('Will the work involve penetrating the surface?','yesNoRadio', 'Size and Depth of excavation','textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio', 'Have all underground drawings being checked and attached','textLine', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Have all underground drawings being checked and attached','textLine', 'If No, DO NOT CONTINUE', 'sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Have cable avoidance tool (CAT) being used to trace and mark services','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Have cable avoidance tool (CAT) being used to trace and mark services','yesNoRadio','If No, DO NOT CONTINUE', 'sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Is the operator trained in the use of the cable avoidance tool (CAT)','yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is the operator trained in the use of the cable avoidance tool (CAT)','yesNoRadio','Verify Certification is up to Date','textLine',1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','What shoring mechanism(s) will be used','sectionDetail',1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Benching', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Battering', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Step', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Trench box', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Other', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Details of the method for spoil removal', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Details of the excavators and associated equipment to be used', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Details of safe egress and exit arrangements', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Buried Services','sectionDetail',1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Identification of Service&#x28;s&#x29;','sectionDetail',1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Electricity', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Drawing Ref. &#x2f; Comments', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Gas &#x2f; Air', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Towns Water', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Sprinkler Main', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Drains', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Communications', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Other', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Other', 'checkbox','Detail Service &#x2f; Drawing Ref. &#x2f; Comments','textLine', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Trial trenches to be hand dug to locate services&#x3f;', 'yesNARadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work involve penetrating the surface?','yesNoRadio','Excavation to be carried out by mechanical means', 'yesNARadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Excavation to be carried out by mechanical means', 'yesNARadio','No mechanical digging within 500 millimetres of any known services&#x21;','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
--Lock out / Tag out (LOTO)
,('Is LOTO required', 'yesNoRadio', 'Is LOTO feasible', 'yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'LOTO Complex document name.', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'LOTO Type', 'yesNoRadio', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Is there a LOTO Complex document for the equipment?', 'yesNoRadio', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Energy Sources', 'sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Electrical', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Pneumatic', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Hydraulic Pump', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Hydraulic Line', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Water', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Gas', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Chemical or Coolant', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Compressed Air', 'checkbox', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Other', 'textarea', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO feasible', 'yesNoRadio', 'Exception to LOTO, work on live equipment requires method statement and EHS Manager / Engineering Head Approval', 'sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Name of authorised worker', 'textLine', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Confirm LOTO is applied before issuing PTW', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'LOTO reference number', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Confirm GSK lock has been applied by permit issuer', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Confirm GSK lock has been applied by affected workers', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Record equipment isolated / Isolation points', 'textarea', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'If only one Energy Source is selected, Simple LOTO is required; If multiple Energy Sources are selected, Complex LOTO is required;', 'sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'Method Statement Required', 'sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Is LOTO required', 'yesNoRadio', 'A second LOTO verification is required by a second Authorised worker prior to issuing this permit', 'sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
--Asphyxiant Gas Use
,('Asphyxiant gas to be used&#x3f; E.g. Nitrogen, Argon.', 'yesNoRadio', 'Can compressed air be used&#x3f;', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Can compressed air be used&#x3f;', 'yesNoRadio','Use Compressed Air','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Can compressed air be used&#x3f;', 'yesNoRadio','Is location of use inside building or an enclosed area&#x3f;','yesNoRadio', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Is location of use inside building or an enclosed area&#x3f;','yesNoRadio','Ensure asphyxiant risk is assessed as line item in RAMS.','sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Is location of use inside building or an enclosed area&#x3f;','yesNoRadio','Gas to be used&#x3a;','textLine', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Is location of use inside building or an enclosed area&#x3f;','yesNoRadio','RAMS section refrence &#x28;asphyxiation risk&#x29;&#x3a;','textLine', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Can compressed air be used&#x3f;', 'yesNoRadio','Does RAMS state removal of cylinder from indoor area when unattended&#x3f;','yesNoRadio', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Does RAMS state removal of cylinder from indoor area when unattended&#x3f;','yesNoRadio','Amend RAMS to include use of individual O2&#x25; depletion monitors.','sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Can compressed air be used&#x3f;', 'yesNoRadio','Has equipment been leak tested &#x28;to be done in an external well ventilated area&#x29;, daily requirement&#x3f;','yesNoRadio', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Has equipment been leak tested &#x28;to be done in an external well ventilated area&#x29;, daily requirement&#x3f;','yesNoRadio', 'Perform leak test prior to bringing asphyxiant gas cylinder&#x2f;regulator&#x2f;equipment indoors.', 'sectionDetail',  0,0,1, @KIOSKID, @PERMIT_NAME)
,('Can compressed air be used&#x3f;', 'yesNoRadio','Does RAMS state use of O2&#x25; depletion monitors required by each individual on the job&#x3f;','yesNoRadio', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Does RAMS state use of O2&#x25; depletion monitors required by each individual on the job&#x3f;','yesNoRadio','Amend RAMS to remove cylinder from indoor area when not controlled by individual with O2&#x25; depletion monitors.','sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Do RAMS include area specific O2&#x25; depletion calculation under leakage scenario&#x3f;','yesNoRadio','Do RAMS include area specific O2&#x25; depletion calculation under leakage scenario&#x3f;','yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Do RAMS include area specific O2&#x25; depletion calculation under leakage scenario&#x3f;','yesNoRadio','Contact EHS representative for area specific calculation to be performed.','sectionDetail', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Can compressed air be used&#x3f;', 'yesNoRadio','Is minimum O2&#x25; level on leakage scenario below 19.5&#x25;&#x3f;','yesNoRadio', 0,0,1, @KIOSKID, @PERMIT_NAME)
,('Is minimum O2&#x25; level on leakage scenario below 19.5&#x25;&#x3f;','yesNoRadio','Contact EHS representative for approval.', 'sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
--GxP
,('Does the proposed work impact GxP but not require an ECC or Change Control &#x28;e.g. adjacent to clean area, swabbing regime linked to minor facility works &#x28;flooring, decoration, joinery&#x29;','yesNoRadio','Swab plate or Swab Handle will be removed to allow new flooring &#x2f; door installation', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Does the proposed work impact GxP but not require an ECC or Change Control &#x28;e.g. adjacent to clean area, swabbing regime linked to minor facility works &#x28;flooring, decoration, joinery&#x29;','yesNoRadio','GxP Approval','approver', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Cleaning Method Statement required','yesNARadio','Cleaning Method Statement CDMS Ref and Accountable person &#x28;text field&#x29;','textLine', 1,0,1, @KIOSKID, @PERMIT_NAME)
--Line Break
,('Will the work require the opening of existing services (e.g. process/ gas/ water/ air)', 'yesNoRadio', 'Has LOTO been applied?', 'yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work require the opening of existing services (e.g. process/ gas/ water/ air)', 'yesNoRadio', 'Has the line been depressurised', 'yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Has the line been depressurised', 'yesNoRadio','Provide justification','textLine', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work require the opening of existing services (e.g. process/ gas/ water/ air)', 'yesNoRadio', 'Where will the content be drained/ dispersed too','textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
--ATEX
,('Are works being performed in an Atex area?','yesNoRadio', 'Have the works been agreed with the supervisor?', 'yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Have the works been agreed with the supervisor?', 'yesNoRadio', 'Specify Name', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Have the works been agreed with the supervisor?', 'yesNoRadio', 'Please Justify', 'textLine', 0,0,0, @KIOSKID, @PERMIT_NAME)
,('Are works being performed in an Atex area?','yesNoRadio', 'Are all flammable substances removed?', 'yesNoRadio', 1,0,1, @KIOSKID, @PERMIT_NAME)
,('Are all flammable substances removed?', 'yesNoRadio', 'Please Specify', 'textLine', 0,0,0, @KIOSKID, @PERMIT_NAME)
--Hazard and Precautions
,('Weekend Work', 'yesNoRadio', 'If answering YES to weekend work and method statement not required, rational required.', 'textarea', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Weekend Work', 'yesNoRadio', 'Has sufficient resources been allocated for weekend eg, GSK Supervision, First Aid, Authorised worker etc', 'yesNoRadio', 1,0,0, @KIOSKID, @PERMIT_NAME)
--PPE & Approval
,('Gloves', 'checkbox', 'Glove type', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Respiratory protection', 'checkbox','Respiratory protection type', 'textLine', 1,0,0, @KIOSKID, @PERMIT_NAME)
--Submit
,('Hot Work','yesNoRadio','Other Permits Required - Hot Work - Yes','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Red Tag','yesNoRadio','Other Permits Required - Red Tag - Yes','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Confined Space','yesNoRadio','Other Permits Required - Confined Space - Yes','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('High Voltage','yesNoRadio','Other Permits Required - High Voltage - Yes','sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)
,('Does work require a Method Statement / Risk Assessment?','yesNoRadio', 'Does work require a method statement? - Yes','sectionDetail',  1,0,0, @KIOSKID, @PERMIT_NAME)
,('Will the work require the opening of existing services (e.g. process/ gas/ water/ air) - Yes', 'sectionDetail','Will the work require the opening of existing services (e.g. process/ gas/ water/ air) - Yes', 'sectionDetail',  1,0,0, @KIOSKID, @PERMIT_NAME)
,('Additional Approval required', 'yesNARadio', 'Additional Approver', 'approver', 1,0,1, @KIOSKID, @PERMIT_NAME) 
,('Chemical Suit','checkbox', 'Chemical Suit - Checked', 'sectionDetail', 1,0,0, @KIOSKID, @PERMIT_NAME)


SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();


      UPDATE TOP(@batchSize) [field]
      SET [field].[pfClass] = [associated].[pfid],
          [field].[pfSelectValue] = [linked].[pfSelectValue],
          [field].[pfSelectValueMandatory] = [linked].[pfSelectValueMandatory],
          [field].[pfIsMandatory] = [linked].[pfIsMandatory] 
      FROM @linkedPermitField AS [linked]
      INNER JOIN [permitType] AS [type]
        ON [type].[Name] = [linked].[name]
        AND [type].[kioskID] = [linked].[kioskID]
      INNER JOIN [permitField] AS [field]
        ON [field].[pfNarrative] = [linked].[narrative]
        AND [field].[pfFieldType] = [linked].[fieldType]
        AND [field].[kioskID] = [type].kioskID
        AND [field].[kioskSiteUUID] = [type].kioskSiteUUID
      INNER JOIN [permitField] AS [associated]
        ON [associated].[ptID] = [type].[ptID]
        AND [associated].[kioskID] = [type].[kioskID]
        AND [associated].[kioskSiteUUID] = [type].[kioskSiteUUID]
        AND [associated].[pfNarrative] = [linked].[associatedNarrative]
        AND [associated].[pfFieldType] = [linked].[associatedFieldType]
      LEFT JOIN [permitField] AS [historical]
        ON [historical].[pfID] = [field].[pfID]
        AND [historical].[pfPublicKey] = [field].[pfPublicKey]       
        AND [historical].[kioskID] = [field].[kioskID]
        AND [historical].[kioskSiteUUID] = [field].[kioskSiteUUID]
      WHERE [historical].[pfID] IS NOT NULL 
      AND ([field].[pfClass] != [associated].[pfid]
        OR [field].[pfClass] IS NULL)

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative linked permit field update: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;