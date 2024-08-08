-- =============================================================================
-- Author:      Alexandre Tran
-- Create date: 03/02/2019
-- Description: Allow create test permit
-- CHANGELOG:
-- 13/05/2020 - AT - Ensure new column added to type table is created on rerun
-- 14/05/2020 - SG - Adding canEdit functionality so we can tweek this value
-- 18/05/2020 - AT - Delete type so it can be recreated/updated on second run
-- 19/05/2020 - AT - Drop store proc first due to dependencies
-- 02/06/2020 - AT - Add permit max days and limit
-- 03/06/2020 - AT - Only apply to active site
-- 08/06/2020 - SG - Setting ptCanAddSignature to default to zero
-- 11/08/2020 - JC - Setting ptCanAddWorkforce to default to zero
-- 14/08/2020 - JC - Give existing permit same settings new permit been set to
-- 22/08/2020 - AT - Rename column ptname to name
-- 08/06/2020 - SG - Setting ptCanCloserAddSignature to default to zero
-- 27/10/2020 - JC - Setting ptCanChangeApprover to default to zero
-- 22/02/2021 - DH - Change pfNarrative to nvarchar to handle hebrew characters
-- 01/11/2021 - JC - Setting ptCanChangePreApprover to default to zero
-- =============================================================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

IF OBJECT_ID('test.createPermitForm', 'P') IS NOT NULL
BEGIN
  DROP PROCEDURE test.createPermitForm
END

IF TYPE_ID('test.permitFields') IS NOT NULL
BEGIN
    DROP TYPE test.permitFields;
END

IF TYPE_ID('test.workflow') IS NOT NULL
BEGIN
    DROP TYPE test.workflow;
END

GO

IF TYPE_ID('test.permitFields') IS NULL
BEGIN
/* Create a table type. */  
  CREATE TYPE test.permitFields AS TABLE ( 
    -- Page
    [ppName] [varchar](255) NULL,
    [ppOrder] [int] NULL,
    -- Field
    [pfNarrative] [nvarchar](255) NULL,
    [pfFieldType] [varchar](255) NULL,
    [pfIsActive] [bit],
    [pfOrder] [int],
    [pfIsMandatory] [bit],
    [pfIsDefault] [bit],
    [pfClass] [varchar](255) NULL,
    [pfSection]  [varchar](255) NULL,
    [pfSelectID] [int],
    [pfSelectValue] [int],
    [pfSelectValueMandatory] [int],
    [canEdit] [int] DEFAULT 0,
    -- Type
    [name] [nvarchar](255) NULL,
    [ptIsActive] [int] NULL,
    [ptIsHazardous] [int] NULL,
    [ptPrintSetupFile] [varchar](100) NULL,
    [ptIsGeneralPermit] [int] NULL,
    [ptInitial] [varchar](50) NULL,
    [ptIsHotWorkPermit] [int] NULL,
    [ptIsLockoutPermit] [int] NULL,
    [ptLogoImage] [varchar](255) NULL,
    [ptCanSelfApprove] [int] NULL,
    [ptIsContractorSearchMandatory] [int] NULL,
    [ptIsDocumentSearchMandatory] [int] NULL,
    [ptOrder] [int] NULL,
    [ptIsPermitConflict] [int] NULL,
    [ptDisplayRequirementBar] [int] NULL,
    [ptIsDocumentAttachMandatory] [int] NULL,
    [ptUseACL] [int] NULL,
    [ptIsConflictManager] [int] NULL,
    [ptConflictManagerLocationLevel1FieldName] [varchar](10) NULL,
    [ptConflictManagerLocationLevel2FieldName] [varchar](10) NULL,
    [ptConflictManagerLocationLevel3FieldName] [varchar](10) NULL,
    [ptConflictManagerStartDateOfWorkFieldName] [varchar](10) NULL,
    [ptConflictManagerEndDateOfWorkFieldName] [varchar](10) NULL,
    [ptConflictManagerStartTimeFieldName] [varchar](10) NULL,
    [ptConflictManagerEndTimeFieldName] [varchar](10) NULL,
    [ptMandatoryToClosePermit] [int] NULL,
    [isTimeValidationStartBeforeEndTimeMandatory] [int] NULL,
    [isTimeValidationCreateInPastNotAllowed] [int] NULL,
    [maxLengthOfPermitDay] [int] NULL,
    [maxLengthOfPermitHour] [int] NULL,
    [ptColour] [varchar](10) NULL,
    [ptConflictManagerLocationLevel3AdditionalFieldName] [varchar](50) NULL,
    [ptContractorModuleInUse] [int] NULL,
    [ptApproverByLocation] [bit] NULL,
    [ptApproverByLocationLevel] [int] NULL,
    [ptValidateWorkforce] [bit] NULL,
    [ptCanAddWorkforce] [bit] DEFAULT 0,
    [ptCanAddSignature] [bit] DEFAULT 0,
    [ptValidateCompany] [bit] NULL,
    [ptCanApproverAddSignature] [bit] DEFAULT 0,
    [ptMaxExtensionDays] [int] DEFAULT 910,
    [ptMaxExtensions] [int] DEFAULT 3,
    [ptCanCloserAddSignature] [bit] DEFAULT 0,
    [ptCanChangeApprover] [bit] DEFAULT 0,
    [ptCanChangePreApprover] [bit] DEFAULT 0,
    [ptCanBeSuspended] [bit] DEFAULT 0,
    [ptCanBeSuspendedBy] [int] NULL,
    [ptCanBeRenewedBy] [int] NULL
  ); 
END

GO

IF TYPE_ID('test.workflow') IS NULL
BEGIN

    CREATE TYPE test.workflow AS TABLE ( 
        [type] VARCHAR(255) NOT NULL,
        [in] VARCHAR(255) NOT NULL,
        [out] VARCHAR(255) NOT NULL,
        [order] INT NOT NULL
     );
END

GO

CREATE OR ALTER PROCEDURE test.createPermitForm
(
@KIOSKID INT
,@FormFields test.permitFields READONLY
,@workflow test.workflow READONLY
)
AS
BEGIN
    
    INSERT INTO permitType (
        [kioskID],[kioskSiteUUID]
        ,[ptCreateBy],[ptCreateUTC]
        ,[ptName],[name],[ptIsActive],[ptIsGeneralPermit],[ptInitial]
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
        ,[ptMaxExtensionDays],[ptMaxExtensions],[ptCanCloserAddSignature], [ptCanChangeApprover], [ptCanChangePreApprover]
        ,[ptCanBeSuspended]
        ,[ptCanBeSuspendedBy]
        ,[ptCanBeRenewedBy]
        )
    SELECT DISTINCT @KIOSKID,ks.kioskSiteUUID
        ,0,GETUTCDATE()
        ,pt.[name],pt.[name],pt.[ptIsActive],pt.[ptIsGeneralPermit],pt.[ptInitial]
        ,pt.[ptIsHazardous],pt.[ptIsHotWorkPermit],pt.[ptIsLockoutPermit]
        ,pt.[ptPrintSetupFile],pt.[ptLogoImage],pt.[ptIsDocumentAttachMandatory]
        ,pt.[ptCanSelfApprove],pt.[ptIsContractorSearchMandatory],pt.[ptIsDocumentSearchMandatory]
        ,pt.[ptOrder]
        ,pt.[ptIsPermitConflict],pt.[ptIsConflictManager]
        ,pt.[ptDisplayRequirementBar]
        ,pt.[ptUseACL]
        ,pt.[ptConflictManagerLocationLevel1FieldName],pt.[ptConflictManagerLocationLevel2FieldName],pt.[ptConflictManagerLocationLevel3FieldName],pt.[ptConflictManagerLocationLevel3AdditionalFieldName]
        ,pt.[ptConflictManagerStartDateOfWorkFieldName],pt.[ptConflictManagerEndDateOfWorkFieldName]
        ,pt.[ptConflictManagerStartTimeFieldName],pt.[ptConflictManagerEndTimeFieldName]
        ,pt.[ptMandatoryToClosePermit]
        ,pt.[isTimeValidationStartBeforeEndTimeMandatory],pt.[isTimeValidationCreateInPastNotAllowed]
        ,pt.[maxLengthOfPermitDay],pt.[maxLengthOfPermitHour]
        ,pt.[ptColour],pt.[ptContractorModuleInUse]
        ,pt.[ptApproverByLocation],pt.[ptApproverByLocationLevel]
        ,pt.[ptValidateWorkforce]
        ,pt.[ptCanAddWorkforce],pt.[ptCanAddSignature],pt.[ptValidateCompany],pt.[ptCanApproverAddSignature]
        ,pt.[ptMaxExtensionDays],pt.[ptMaxExtensions],pt.[ptCanCloserAddSignature], pt.[ptCanChangeApprover], pt.[ptCanChangePreApprover]
        ,pt.[ptCanBeSuspended]
        ,pt.[ptCanBeSuspendedBy]
        ,pt.[ptCanBeRenewedBy]
    FROM kioskSite AS ks
    FULL OUTER JOIN @FormFields AS pt ON pt.[name] IS NOT NULL
    LEFT JOIN permitType AS pt2 ON pt2.name = pt.name COLLATE SQL_Latin1_General_CP1_CI_AS
      AND pt2.kioskID = @KIOSKID
      AND pt2.kioskSiteUUID = ks.kioskSiteUUID
    WHERE pt2.ptID IS NULL
        AND ks.[kioskSiteIsActive] = 1;

    UPDATE [permit]
    SET [permit].[ptIsActive] = [fields].[ptIsActive]
        ,[permit].[ptIsGeneralPermit] = [fields].[ptIsGeneralPermit]
        ,[permit].[ptInitial] = [fields].[ptInitial]
        ,[permit].[ptIsHazardous] = [fields].[ptIsHazardous]
        ,[permit].[ptIsHotWorkPermit] = [fields].[ptIsHotWorkPermit]
        ,[permit].[ptIsLockoutPermit] = [fields].[ptIsLockoutPermit]
        ,[permit].[ptPrintSetupFile] = [fields].[ptPrintSetupFile]
        ,[permit].[ptLogoImage] = [fields].[ptLogoImage]
        ,[permit].[ptIsDocumentAttachMandatory] = [fields].[ptIsDocumentAttachMandatory]
        ,[permit].[ptCanSelfApprove] = [fields].[ptCanSelfApprove]
        ,[permit].[ptIsContractorSearchMandatory] = [fields].[ptIsContractorSearchMandatory]
        ,[permit].[ptIsDocumentSearchMandatory] = [fields].[ptIsDocumentSearchMandatory]
        ,[permit].[ptOrder] = [fields].[ptOrder]
        ,[permit].[ptIsPermitConflict] = [fields].[ptIsPermitConflict]
        ,[permit].[ptIsConflictManager] = [fields].[ptIsConflictManager]
        ,[permit].[ptDisplayRequirementBar] = [fields].[ptDisplayRequirementBar]
        ,[permit].[ptUseACL] = [fields].[ptUseACL]
        ,[permit].[ptConflictManagerLocationLevel1FieldName] = [fields].[ptConflictManagerLocationLevel1FieldName]
        ,[permit].[ptConflictManagerLocationLevel2FieldName] = [fields].[ptConflictManagerLocationLevel2FieldName]
        ,[permit].[ptConflictManagerLocationLevel3FieldName] = [fields].[ptConflictManagerLocationLevel3FieldName]
        ,[permit].[ptConflictManagerLocationLevel3AdditionalFieldName] = [fields].[ptConflictManagerLocationLevel3AdditionalFieldName]
        ,[permit].[ptConflictManagerStartDateOfWorkFieldName] = [fields].[ptConflictManagerStartDateOfWorkFieldName]
        ,[permit].[ptConflictManagerEndDateOfWorkFieldName] = [fields].[ptConflictManagerEndDateOfWorkFieldName]
        ,[permit].[ptConflictManagerStartTimeFieldName] = [fields].[ptConflictManagerStartTimeFieldName]
        ,[permit].[ptConflictManagerEndTimeFieldName] = [fields].[ptConflictManagerEndTimeFieldName]
        ,[permit].[ptMandatoryToClosePermit] = [fields].[ptMandatoryToClosePermit]
        ,[permit].[isTimeValidationStartBeforeEndTimeMandatory] = [fields].[isTimeValidationStartBeforeEndTimeMandatory]
        ,[permit].[isTimeValidationCreateInPastNotAllowed] = [fields].[isTimeValidationCreateInPastNotAllowed]
        ,[permit].[maxLengthOfPermitDay] = [fields].[maxLengthOfPermitDay]
        ,[permit].[maxLengthOfPermitHour] = [fields].[maxLengthOfPermitHour]
        ,[permit].[ptColour] = [fields].[ptColour]
        ,[permit].[ptContractorModuleInUse] = [fields].[ptContractorModuleInUse]
        ,[permit].[ptApproverByLocation] = [fields].[ptApproverByLocation]
        ,[permit].[ptApproverByLocationLevel] = [fields].[ptApproverByLocationLevel]
        ,[permit].[ptValidateWorkforce] = [fields].[ptValidateWorkforce]
        ,[permit].[ptCanAddWorkforce] = [fields].[ptCanAddWorkforce]
        ,[permit].[ptCanAddSignature] = [fields].[ptCanAddSignature]
        ,[permit].[ptValidateCompany] = [fields].[ptValidateCompany]
        ,[permit].[ptCanApproverAddSignature] = [fields].[ptCanApproverAddSignature]
        ,[permit].[ptMaxExtensionDays] = [fields].[ptMaxExtensionDays]
        ,[permit].[ptMaxExtensions] = [fields].[ptMaxExtensions]
        ,[permit].[ptCanCloserAddSignature] = [fields].[ptCanCloserAddSignature]
        ,[permit].[ptCanChangeApprover] = [fields].[ptCanChangeApprover]
        ,[permit].[ptCanChangePreApprover] = [fields].[ptCanChangePreApprover]
        ,[permit].[ptCanBeSuspended] = [fields].[ptCanBeSuspended]
        ,[permit].[ptCanBeSuspendedBy] = [fields].[ptCanBeSuspendedBy]
        ,[permit].[ptCanBeRenewedBy] = [fields].[ptCanBeRenewedBy]
    FROM [permitType] AS [permit]
    INNER JOIN @FormFields AS [fields] 
        ON [fields].[name] = [permit].[name]
    WHERE ([permit].[ptIsActive] != [fields].[ptIsActive] 
        OR [permit].[ptIsActive] IS NULL)
    OR ([permit].[ptIsGeneralPermit] != [fields].[ptIsGeneralPermit] 
        OR [permit].[ptIsGeneralPermit] IS NULL)
    OR ([permit].[ptInitial] != [fields].[ptInitial] 
        OR [permit].[ptInitial] IS NULL)
    OR ([permit].[ptIsHazardous] != [fields].[ptIsHazardous]
        OR [permit].[ptIsHazardous] IS NULL)
    OR ([permit].[ptIsHotWorkPermit] != [fields].[ptIsHotWorkPermit] 
        OR [permit].[ptIsHotWorkPermit] IS NULL)
    OR ([permit].[ptIsLockoutPermit] != [fields].[ptIsLockoutPermit] 
        OR [permit].[ptIsLockoutPermit] IS NULL)
    OR ([permit].[ptPrintSetupFile] != [fields].[ptPrintSetupFile] 
        OR [permit].[ptPrintSetupFile] IS NULL)
    OR ([permit].[ptLogoImage] != [fields].[ptLogoImage] 
        OR [permit].[ptLogoImage] IS NULL)
    OR ([permit].[ptIsDocumentAttachMandatory] != [fields].[ptIsDocumentAttachMandatory] 
        OR [permit].[ptIsDocumentAttachMandatory] IS NULL)
    OR ([permit].[ptCanSelfApprove] != [fields].[ptCanSelfApprove] 
        OR [permit].[ptCanSelfApprove] IS NULL)
    OR ([permit].[ptIsContractorSearchMandatory] != [fields].[ptIsContractorSearchMandatory] 
        OR [permit].[ptIsContractorSearchMandatory] IS NULL)
    OR ([permit].[ptIsDocumentSearchMandatory] != [fields].[ptIsDocumentSearchMandatory] 
        OR [permit].[ptIsDocumentSearchMandatory] IS NULL)
    OR ([permit].[ptOrder] != [fields].[ptOrder] 
        OR [permit].[ptOrder] IS NULL)
    OR ([permit].[ptIsPermitConflict] != [fields].[ptIsPermitConflict] 
        OR [permit].[ptIsPermitConflict] IS NULL)
    OR ([permit].[ptIsConflictManager] != [fields].[ptIsConflictManager] 
        OR [permit].[ptIsConflictManager] IS NULL)
    OR ([permit].[ptDisplayRequirementBar] != [fields].[ptDisplayRequirementBar] 
        OR [permit].[ptDisplayRequirementBar] IS NULL)
    OR ([permit].[ptUseACL] != [fields].[ptUseACL] 
        OR [permit].[ptUseACL] IS NULL)
    OR ([permit].[ptConflictManagerLocationLevel1FieldName] != [fields].[ptConflictManagerLocationLevel1FieldName] 
        OR [permit].[ptConflictManagerLocationLevel1FieldName] IS NULL)
    OR ([permit].[ptConflictManagerLocationLevel2FieldName] != [fields].[ptConflictManagerLocationLevel2FieldName] 
        OR [permit].[ptConflictManagerLocationLevel2FieldName] IS NULL)
    OR ([permit].[ptConflictManagerLocationLevel3FieldName] != [fields].[ptConflictManagerLocationLevel3FieldName] 
        OR [permit].[ptConflictManagerLocationLevel3FieldName] IS NULL)
    OR ([permit].[ptConflictManagerLocationLevel3AdditionalFieldName] != [fields].[ptConflictManagerLocationLevel3AdditionalFieldName] 
        OR [permit].[ptConflictManagerLocationLevel3AdditionalFieldName] IS NULL)
    OR ([permit].[ptConflictManagerStartDateOfWorkFieldName] != [fields].[ptConflictManagerStartDateOfWorkFieldName] 
        OR [permit].[ptConflictManagerStartDateOfWorkFieldName] IS NULL)
    OR ([permit].[ptConflictManagerEndDateOfWorkFieldName] != [fields].[ptConflictManagerEndDateOfWorkFieldName] 
        OR [permit].[ptConflictManagerEndDateOfWorkFieldName] IS NULL)
    OR ([permit].[ptConflictManagerStartTimeFieldName] != [fields].[ptConflictManagerStartTimeFieldName] 
        OR [permit].[ptConflictManagerStartTimeFieldName] IS NULL)
    OR ([permit].[ptConflictManagerEndTimeFieldName] != [fields].[ptConflictManagerEndTimeFieldName] 
        OR [permit].[ptConflictManagerEndTimeFieldName] IS NULL)
    OR ([permit].[ptMandatoryToClosePermit] != [fields].[ptMandatoryToClosePermit] 
        OR [permit].[ptMandatoryToClosePermit] IS NULL)
    OR ([permit].[isTimeValidationStartBeforeEndTimeMandatory] != [fields].[isTimeValidationStartBeforeEndTimeMandatory] 
        OR [permit].[isTimeValidationStartBeforeEndTimeMandatory] IS NULL)
    OR ([permit].[isTimeValidationCreateInPastNotAllowed] != [fields].[isTimeValidationCreateInPastNotAllowed] 
        OR [permit].[isTimeValidationCreateInPastNotAllowed] IS NULL)
    OR ([permit].[maxLengthOfPermitDay] != [fields].[maxLengthOfPermitDay] 
        OR [permit].[maxLengthOfPermitDay] IS NULL)
    OR ([permit].[maxLengthOfPermitHour] != [fields].[maxLengthOfPermitHour] 
        OR [permit].[maxLengthOfPermitHour] IS NULL)
    OR ([permit].[ptColour] != [fields].[ptColour] 
        OR [permit].[ptColour] IS NULL)
    OR ([permit].[ptContractorModuleInUse] != [fields].[ptContractorModuleInUse] 
        OR [permit].[ptContractorModuleInUse] IS NULL)
    OR ([permit].[ptApproverByLocation] != [fields].[ptApproverByLocation] 
        OR [permit].[ptApproverByLocation] IS NULL)
    OR ([permit].[ptApproverByLocationLevel] != [fields].[ptApproverByLocationLevel] 
        OR [permit].[ptApproverByLocationLevel] IS NULL)
    OR ([permit].[ptValidateWorkforce] != [fields].[ptValidateWorkforce] 
        OR [permit].[ptValidateWorkforce] IS NULL)
    OR ([permit].[ptCanAddWorkforce] != [fields].[ptCanAddWorkforce] 
        OR [permit].[ptCanAddWorkforce] IS NULL)
    OR ([permit].[ptCanAddSignature] != [fields].[ptCanAddSignature] 
        OR [permit].[ptCanAddSignature] IS NULL)
    OR ([permit].[ptValidateCompany] != [fields].[ptValidateCompany] 
        OR [permit].[ptValidateCompany] IS NULL)
    OR ([permit].[ptCanApproverAddSignature] != [fields].[ptCanApproverAddSignature] 
        OR [permit].[ptCanApproverAddSignature] IS NULL)
    OR ([permit].[ptMaxExtensionDays] != [fields].[ptMaxExtensionDays] 
        OR [permit].[ptMaxExtensionDays] IS NULL)
    OR ([permit].[ptMaxExtensions] != [fields].[ptMaxExtensions] 
        OR [permit].[ptMaxExtensions] IS NULL)
    OR ([permit].[ptCanCloserAddSignature] != [fields].[ptCanCloserAddSignature] 
        OR [permit].[ptCanCloserAddSignature] IS NULL)
    OR ([permit].[ptCanChangeApprover] != [fields].[ptCanChangeApprover] 
        OR [permit].[ptCanChangeApprover] IS NULL)
    OR ([permit].[ptCanChangePreApprover] != [fields].[ptCanChangePreApprover] 
        OR [permit].[ptCanChangePreApprover] IS NULL)
    OR ([permit].[ptCanBeSuspended] != [fields].[ptCanBeSuspended] 
        OR [permit].[ptCanBeSuspended] IS NULL)
    OR ([permit].[ptCanBeSuspendedBy] != [fields].[ptCanBeSuspendedBy] 
        OR [permit].[ptCanBeSuspendedBy] IS NULL)
    OR ([permit].[ptCanBeRenewedBy] != [fields].[ptCanBeRenewedBy] 
        OR [permit].[ptCanBeRenewedBy] IS NULL)

    INSERT INTO [permitPage](
        [kioskID],[kioskSiteUUID]
        ,[ptID],[ppName],[ppOrder]
        ,[ppIsActive]
        ,[ppCreateBy],[ppCreateUTC]
    )
    SELECT DISTINCT 
        pt.kioskID,pt.kioskSiteUUID
        ,pt.ptID,pf.ppName,pf.ppOrder
        ,1
        ,0,GETUTCDATE()
    FROM @FormFields AS pf
    LEFT JOIN permitType AS pt ON pt.name = pf.name COLLATE SQL_Latin1_General_CP1_CI_AS
    LEFT JOIN permitPage AS pp ON pp.kioskID = pt.kioskid
      AND pp.kioskSiteUUID = pt.kioskSiteUUID
      AND pp.ptID = pt.ptID
      AND pp.ppName = pf.ppName COLLATE SQL_Latin1_General_CP1_CI_AS
    WHERE pp.ppID IS NULL
        AND pf.ppName IS NOT NULL;


    INSERT INTO [permitField](
        [kioskID],[kioskSiteUUID],[ptID]
        ,[pfPublicKey],[pfNarrative]
        ,[pfFieldType],[pfIsActive],[pfOrder]
        ,[pfIsMandatory],[pfIsDefault]
        ,[ppID]
        ,[pfClass],[pfSection]
        ,[pfSelectID],[pfSelectValue],[pfSelectValueMandatory]
        ,[pfCreateBy],[pfCreateUTC],[canEdit]
    )
    SELECT DISTINCT pt.kioskID,pt.kioskSiteUUID,pt.ptID
        ,NEWID(),ff.pfNarrative
        ,ff.pfFieldType,ff.pfIsActive,ff.pfOrder
        ,ff.pfIsMandatory, ff.pfIsDefault
        ,pp.ppID
        ,ff.pfClass,ff.pfSection
        ,ff.pfSelectID,ff.pfSelectValue,ff.pfSelectValueMandatory
        ,0,GETUTCDATE(),ff.canEdit
    FROM @FormFields AS ff
    LEFT JOIN permitType AS pt ON pt.name = ff.name COLLATE SQL_Latin1_General_CP1_CI_AS
    LEFT JOIN permitPage AS pp ON pp.kioskID = pt.kioskid
      AND pp.kioskSiteUUID = pt.kioskSiteUUID
      AND pp.ptID = pt.ptID
      AND pp.ppName = ff.ppName COLLATE SQL_Latin1_General_CP1_CI_AS
    LEFT JOIN permitField AS pf2 ON pf2.kioskID = pt.kioskID
      AND pf2.kioskSiteUUID = pt.kioskSiteUUID
      AND pf2.ptID = pt.ptID
      AND pf2.pfNarrative = ff.pfNarrative COLLATE SQL_Latin1_General_CP1_CI_AS
      AND pf2.pfFieldType = ff.pfFieldType COLLATE SQL_Latin1_General_CP1_CI_AS
      AND pf2.ppID = pp.ppID
    WHERE pf2.pfID IS NULL
        AND ff.name IS NOT NULL;

    INSERT INTO [dbo].[permitWorkflow](
        [kioskID],[kioskSiteUUID]
        ,[ptID],[pwStatusIn],[pwStatusOut]
        ,[pwIsActive],[pwOrder]
        ,[pwCreateBy],[pwCreateUTC]
    )
    SELECT DISTINCT pt.kioskID,pt.kioskSiteUUID
        ,pt.ptID,statusin.[permitStatusID],statusout.[permitStatusID]
        ,1,pw.[order]
        ,0,GETUTCDATE()
    FROM @workflow AS pw
    LEFT JOIN permitType AS pt ON UPPER(pt.name) = UPPER(pw.[type])
    LEFT JOIN v3_sp.dbo.permitStatus AS statusin ON UPPER(statusin.[permitStatus]) = UPPER(pw.[in])
    LEFT JOIN v3_sp.dbo.permitStatus AS statusout ON UPPER(statusout.[permitStatus]) = UPPER(pw.[out])
    LEFT JOIN [dbo].[permitWorkflow] AS pw2 ON pw2.kioskID = pt.kioskID
        AND pw2.kioskSiteUUID = pt.kioskSiteUUID
        AND pw2.ptID = pt.ptID
        AND pw2.pwStatusIn = statusin.[permitStatusID]
        AND pw2.pwStatusOut = statusout.[permitStatusID]
    WHERE pw2.pwID IS NULL;

    INSERT INTO [dbo].[permitDropDownLocation](
        [kioskID],[kioskSiteUUID],[pddlIsActive]
        ,[pfID],[klID])
    SELECT DISTINCT pt.kioskID,pt.kioskSiteUUID,1
        ,pf.pfID,kl.klID
    FROM @FormFields AS ff
    LEFT JOIN permitType AS pt ON pt.name = ff.name
    LEFT JOIN permitField AS pf ON pf.kioskID = pt.kioskID
        AND pf.kioskSiteUUID = pt.kioskSiteUUID
        AND pf.ptID = pt.ptID
        AND pf.pfFieldType = 'pLocation'
    LEFT JOIN kioskLocation AS kl ON kl.kioskID = pt.kioskID
        AND kl.kioskSiteUUID = pt.kioskSiteUUID
        AND kl.klLevel = 0
    LEFT JOIN permitDropDownLocation AS pddl ON pddl.kioskID = pt.kioskID
        AND pddl.kioskSiteUUID = pt.kioskSiteUUID
        AND pddl.klID = kl.klID
        AND pddl.pfID = pf.pfID
        AND pddl.pddlIsActive = 1
    WHERE pddl.pddlID IS NULL
        AND ff.pfFieldType = 'pLocation';

    INSERT INTO [dbo].[permitTypeACL](
        [kioskID],[kioskSiteUUID]
        ,[ptID],[ptACLGrantAccessToKUID],[ptACLIsActive]
        ,[ptACLCreateBy],[ptACLCreateUTC]
    )
    SELECT pt.kioskID,pt.kioskSiteUUID
        ,pt.ptID,kuacg.kuID,1
        ,0,GETUTCDATE()
    FROM kioskAccessControlGroup AS kacg
    LEFT JOIN kioskUserAccessControlGroupMembership AS kuacg ON kuacg.kioskID = kacg.kioskID
        AND kuacg.kioskSiteUUID = kacg.kioskSiteUUID
        AND kuacg.kacgID = kacg.kacgID
    FULL OUTER JOIN permitType AS pt ON pt.ptID IS NOT NULL
    LEFT JOIN permitTypeACL AS ptacl ON ptacl.kioskID = pt.kioskID
        AND ptacl.kioskSiteUUID = pt.kioskSiteUUID
        AND ptacl.ptID = pt.ptID
        AND ptacl.ptACLGrantAccessToKUID = kuacg.kuID
        AND ptacl.ptACLIsActive = 1
    WHERE ptacl.ptACLID IS NULL
        AND kacg.kacgName = 'Create Permit';

END
GO