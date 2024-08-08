-- =======================================================
-- Author:      Alexandre Tran
-- Create date: 15/04/2019
-- Description: Generate compliance requirement approved
--  for testing recurring requirement for company
-- 15/0/2020 - AT - Make qualification mandatory
-- 15/0/2020 - AT - Bind qualification to requirement
-- =======================================================

SET NOCOUNT ON;

/*TRUNCATE TABLE [dbo].[cpCompanyComplianceRequirement];
TRUNCATE TABLE [dbo].[cpCompanyComplianceRequirementResponse];
TRUNCATE TABLE [dbo].[formCreate];
TRUNCATE TABLE [dbo].[formCreateMaster];
DELETE FROM [dbo].[cpCompanyQualification] WHERE cpCompanyQualificationID > 1;*/

DECLARE @YEARS INT = 4;

-- Store new generated requirement information
DECLARE @Requiments TABLE (
[cpCompanyComplianceRequirementID] INT
,[kioskID] INT
,[createdUTC] DATETIME
,[cpReferenceCompanyComplianceRequirementID] INT
);

PRINT 'Attempt to add qualifications matching requirement...';

INSERT INTO [dbo].[qualificationReferenceTable] (
	[kioskID],[kioskSiteUUID]
	,[qrName],[isCompany],[isContractor]
)
SELECT [requirement].[kioskID],[requirement].[kioskSiteUUID]
,CONCAT('Qualification ',[requirement].[cpReferenceCompanyComplianceRequirementName]),1,0
FROM [dbo].[cpReferenceCompanyComplianceRequirement] AS [requirement]
LEFT JOIN [dbo].[qualificationReferenceTable] AS [qualification]
	ON [qualification].[kioskID] = [requirement].[kioskID]
	AND [qualification].[kioskSiteUUID] = [requirement].[kioskSiteUUID]
	AND [qualification].[qrName] = CONCAT('Qualification ',[requirement].[cpReferenceCompanyComplianceRequirementName])
	AND [qualification].[isCompany] = 1
WHERE [qualification].[qrID] IS NULL;

INSERT INTO [dbo].[cpReferenceContractorCompanyQualification](
[kioskID],[kioskSiteUUID],[qrID]
,[cpReferenceContractorCompanyQualificationName],[isActive]
)
SELECT [qualification].[kioskID],[qualification].[kioskSiteUUID],[qualification].[qrID]
,[qualification].[qrName],1
FROM [dbo].[qualificationReferenceTable] AS [qualification]
LEFT JOIN [dbo].[cpReferenceContractorCompanyQualification] AS [reference]
	ON [reference].[kioskID] = [qualification].[kioskID]
	AND [reference].[kioskSiteUUID] = [qualification].[kioskSiteUUID]
	AND [reference].[cpReferenceContractorCompanyQualificationName] = [qualification].[qrName]
WHERE [reference].[cpReferenceContractorCompanyQualificationID] IS NULL
	AND [qualification].[isCompany] = 1;

INSERT INTO [dbo].[contractorQualificationType](
	[kioskID],[kioskSiteUUID],[qrID]
	,[cqtName],[cqtIsActive]
	,[cqtIsCompanyQualification]
	,[cqtAddedBy],[cqtAddedUTC]
	,[cqtIsMandatory],[cpReferenceCompanyComplianceRequirementID]
	,[cqtValidity],[cqtNotificationDays],[cqtValidityDays]
	,[cqtAutoAssign],[isGlobal]
	,[courseID]
)
SELECT [reference].[kioskID],[reference].[kioskSiteUUID],[reference].[qrID]
,[reference].[qrName],1
,IIF([reference].[isCompany] = 1,1,0)
,0,GETUTCDATE()
,1,[requirement].[cpReferenceCompanyComplianceRequirementID]
,1,30,365
,0,0
,0
FROM [dbo].[qualificationReferenceTable] AS [reference]
INNER JOIN [dbo].[cpReferenceCompanyComplianceRequirement] AS [requirement]
  ON [requirement].[kioskID] = [reference].[kioskid]
  AND [requirement].[kioskSiteUUID] = [reference].[kioskSiteUUID]
  AND [requirement].[cpReferenceCompanyComplianceRequirementName] = TRIM(REPLACE([reference].[qrName],'Qualification',''))
LEFT JOIN [dbo].[contractorQualificationType] AS [qualification]
	ON [qualification].[kioskID] = [reference].[kioskID]
	AND [qualification].[kioskSiteUUID] = [reference].[kioskSiteUUID]
	AND [qualification].[cqtName] = [reference].[qrName]
	AND [qualification].[cpReferenceCompanyComplianceRequirementID] = [requirement].[cpReferenceCompanyComplianceRequirementID]
WHERE [qualification].[cqtID] IS NULL;

PRINT 'Qualifications matching requirement added successfully!';

PRINT 'Attempt create old requirement...';

WHILE @YEARS > 0
BEGIN
	INSERT INTO [dbo].[cpCompanyComplianceRequirement] (
	[kioskID],[cpCompanyID]
	,[cpReferenceCompanyComplianceRequirementID]
	,[cpCompanyComplianceRequirementDueDate]
	,[cpCompanyComplianceRequirementDescription]
	,[cpCompanyComplianceRequirementIsActive]
	,[cpCompanyComplianceRequirementCreateBy],[cpCompanyComplianceRequirementCreateUTC]
	,[cpReferenceContractorCompanyQualificationID],[cpCompanyComplianceRequirementPublicKey]
	)
	OUTPUT inserted.[cpCompanyComplianceRequirementID],  inserted.[kioskID],inserted.[cpCompanyComplianceRequirementCreateUTC], inserted.[cpReferenceCompanyComplianceRequirementID] INTO @Requiments
	SELECT [company].[kioskID], [company].[cpCompanyID]
	,[requirement].[cpReferenceCompanyComplianceRequirementID]
	,DATEADD(YEAR,-(@YEARS),DATEADD(MONTH,1,GETUTCDATE()))
	,CONCAT('Recurring auto-test ',CAST(NEWID() AS VARCHAR(255)))
	,1
	,0,DATEADD(YEAR,-(@YEARS),DATEADD(DAY, -5, DATEADD(MONTH,1,GETUTCDATE())))
	,[qualification].[cpReferenceContractorCompanyQualificationID],CAST(NEWID() AS varchar(255))
	FROM [dbo].[cpCompanyMaster] AS [company]
	LEFT JOIN [dbo].[cpCompanySites] AS [site]
	  ON [site].[cpCompanyID] = [company].[cpCompanyID]
	  AND [site].[cpCompanyVersion] = [company].[cpCompanyVersion]
	LEFT JOIN [dbo].[cpReferenceCompanyComplianceRequirement] AS [requirement]
	  ON [requirement].[kioskID] = [company].[kioskID]
	  AND [requirement].[kioskSiteUUID] = [site].[kioskSiteUUID]
	LEFT JOIN [dbo].[qualificationReferenceTable] AS [reference]
	  ON [reference].[kioskID] = [requirement].[kioskID]
	  AND [reference].[kioskSiteUUID] = [requirement].[kioskSiteUUID]
	  AND [reference].[qrName] = CONCAT('Qualification ',[requirement].[cpReferenceCompanyComplianceRequirementName])
	  AND [reference].[isCompany] = 1
	LEFT JOIN [dbo].[cpReferenceContractorCompanyQualification] AS [qualification]
	  ON [qualification].[kioskID] = [reference].[kioskID]
	  AND [qualification].[kioskSiteUUID] = [reference].[kioskSiteUUID]
	  AND [qualification].[qrID] = [reference].[qrID]
	WHERE [site].[kioskSiteUUID] IS NOT NULL;
	
	SET @YEARS -= 1;
END

PRINT 'Historical requirement created successfully!';

PRINT 'Attempt approve Historical document compliance requirement created...';
INSERT INTO [dbo].[cpCompanyComplianceRequirementResponse](
  [kioskID]
  ,[cpCompanyComplianceRequirementID],[cpCompanyComplianceRequirementResponseStatusID]
  ,[cpCompanyComplianceRequirementResponseAddedBy]
  ,[cpCompanyComplianceRequirementResponseCreateUTC]
  ,[cpCompanyComplianceRequirementResponseComment]
  ,[cpCompanyComplianceRequirementResponseExpiry]
  ,[cpCompanyComplianceRequirementQualificationExpires]
)
SELECT [requirement].[kioskID]
,[requirement].[cpCompanyComplianceRequirementID],2
,0,DATEADD(DAY,3,[requirement].[createdUTC])
,'Auto test approved'
,DATEADD(YEAR,1,[requirement].[createdUTC])
,1
FROM @Requiments AS [requirement]
LEFT JOIN [dbo].[cpReferenceCompanyComplianceRequirement] AS [type]
  ON [type].[cpReferenceCompanyComplianceRequirementID] = [requirement].[cpReferenceCompanyComplianceRequirementID]
WHERE [type].[cpReferenceCompanyComplianceRequirementIsDocumentRequest] = 1;

PRINT 'Approved all Historical document compliance requirement created successfully!';

PRINT 'Attempt approved all Historical questionaire compliance requirement created...';
DECLARE @LAST_ID INT = (SELECT MAX(fcid) FROM formCreate);
DECLARE @REFERENCE_NAME VARCHAR(255) = 'OG-xxxx';

INSERT INTO [dbo].[formCreate](
  [fcid],[kioskID],[formCreatePublicKey]
  ,[version],[formNumber]
  ,[formStatus]
  ,[formCreateBy],[formCreateUTC]
  ,[formTypeID],[cpCompanyComplianceRequirementID]
  ,[formDescription]
  ,[formDateOfWorkStart],[formTimeOfWorkStart]
  ,[formDateOfWorkEnd],[formTimeOfWorkEnd]
)
SELECT  ISNULL(@LAST_ID,0) + [requirement].[cpCompanyComplianceRequirementID]
,[requirement].[kioskID],NEWID()
,1,@REFERENCE_NAME
,2
,0,DATEADD(HOUR,2,[requirement].[createdUTC])
,[type].[formTypeID],[requirement].[cpCompanyComplianceRequirementID]
,'Auto-complete via automated test system'
,DATEADD(HOUR,4,[requirement].[createdUTC]),DATEADD(HOUR,4,[requirement].[createdUTC])
,DATEADD(DAY,2,[requirement].[createdUTC]),DATEADD(DAY,2,[requirement].[createdUTC])
FROM @Requiments AS [requirement]
LEFT JOIN [dbo].[cpReferenceCompanyComplianceRequirement] AS [type]
  ON [type].[cpReferenceCompanyComplianceRequirementID] = [requirement].[cpReferenceCompanyComplianceRequirementID]
WHERE [type].[cpReferenceCompanyComplianceRequirementIsQuestionnaireRequest] = 1;

PRINT 'Approved all Historical questionaire compliance requirement created successfully!';

PRINT 'Attempt add qualification matching compliance requirement...';

INSERT INTO [dbo].[cpCompanyQualification] (
	[kioskID],[cpCompanyID],[cpCompanyComplianceRequirementResponseID]
	,[cpReferenceContractorCompanyQualificationID]
	,[cpCompanyQualificationComment]
	,[cpCompanyQualificationFromDT]
	,[cpCompanyQualificationNoExpiryDT],[cpCompanyQualificationExpiryDT]
	,[cpCompanyQualificationIsActive]
	,[cpCompanyQualificationAddedBy],[cpCompanyQualificationAddedDT]
	,[kfuID]
)
SELECT [response].[kioskID],[requirement].[cpCompanyID],[response].[cpCompanyComplianceRequirementResponseID]
,[requirement].[cpReferenceContractorCompanyQualificationID]
,'Auto qualification from automated test system'
,[requirement].[cpCompanyComplianceRequirementCreateUTC]
,0,[response].[cpCompanyComplianceRequirementResponseExpiry]
,1
,0,[response].[cpCompanyComplianceRequirementResponseCreateUTC]
,0
FROM [dbo].[cpCompanyComplianceRequirementResponse] AS [response]
LEFT JOIN [dbo].[cpCompanyComplianceRequirement] AS [requirement]
	ON [requirement].[kioskID] = [response].[kioskID]
	AND [requirement].[cpCompanyComplianceRequirementID] = [response].[cpCompanyComplianceRequirementID]
LEFT JOIN [dbo].[cpCompanyQualification] AS [qualification]
	ON [qualification].[kioskID] = [response].[kioskID]
	AND [qualification].[cpCompanyID] = [requirement].[cpCompanyID]
	AND [qualification].[cpCompanyComplianceRequirementResponseID] = [response].[cpCompanyComplianceRequirementResponseID]
	AND [qualification].[cpReferenceContractorCompanyQualificationID] = [requirement].[cpReferenceContractorCompanyQualificationID]
WHERE [qualification].[cpCompanyQualificationID] IS NULL;

PRINT 'Qualifications added successfully to companies!';

PRINT 'Attempt to run job recurring once to update';
  
EXEC msdb.dbo.sp_start_job N'Recurring Compliance Requirement' ;  

PRINT 'Job recurring ran successfully!';