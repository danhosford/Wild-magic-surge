-- =============================================
-- Author:      Alexandre Tran
-- Create date: 25/08/2020
-- Description: Generate Lockout/Tagout permit
-- Parameters:
-- CHANGELOG:
-- 25/08/2020 - AT - Move out from general
-- 28/08/2020 - JC - Insert energy magnitude and sources
-- 30/08/2020 - AT - Fix loto permit name
-- =============================================

SET NOCOUNT ON;

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PERMIT_NAME VARCHAR(255) = 'Lockout / Tagout';
DECLARE @PERMIT_INITIAL VARCHAR(10) = 'LT';
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

PRINT 'Create energySources variable table...';

DECLARE @energySources TABLE (
  [energySourceName] VARCHAR(255) NOT NULL
  ,[isActive] BIT NOT NULL
  ,[kioskID] INT NOT NULL
);

PRINT 'Insert Into energySources table...';

INSERT INTO @energySources 
VALUES
('Electricity',1, @KIOSKID),
('Wind',1, @KIOSKID),
('Water',1, @KIOSKID)

PRINT 'Create energyMagnitudes variable table...';

DECLARE @energyMagnitudes TABLE (
  [energyMagnitudeName] VARCHAR(255) NOT NULL
  ,[isActive] BIT NOT NULL
  ,[kioskID] INT NOT NULL
  ,[energySourceID] INT IDENTITY(1,1)
);

PRINT 'Insert Into energyMagnitudes table...';

INSERT INTO @energyMagnitudes 
VALUES
('50 KW',1, @KIOSKID),
('5 KW',1, @KIOSKID),
('15 KW',1, @KIOSKID)

PRINT 'Create lotoWorkflow table...';

DECLARE @lotoWorkflow TABLE (
  [pwStatusIn] INT NOT NULL
  ,[pwStatusOut] INT NOT NULL
  ,[pwIsActive] BIT NOT NULL
  ,[pwCreateBy] INT NOT NULL
  ,[pwCreateUTC] DATETIME NOT NULL
  ,[pwOrder] INT NOT NULL
);

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
,[ptCanAddWorkforce],[ptCanAddSignature],[ptValidateCompany]
)
VALUES ('General Details',1,'Scope of work to be performed','pDescription',1,7,1,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Date of Work','pDateOfWorkStart',1,4,1,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Location of Work','pLocation',1,8,1,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Permit Reviewer','pApprover',1,3,1,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Section 1A &#x3a; General Information','sectionDetail',1,1,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'The PAP is the person currently logged in to the permit system.','sectionDetail',1,2,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'WO &#x23;','textLine',1,5,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Equipment ID or Description','textarea',1,6,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Floor','locationLevel2CFC',1,9,1,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Room','locationLevel3CFC',1,10,1,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Section 1B &#x3a; Hand-Off for LOTO Activities','sectionDetail',1,12,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Is hand over required','yesNoRadio',1,13,1,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Area Manager &#x2f; Owner &#x2f; Designee','textLine',1,15,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('General Details',1,'Room Number&#x3a;','textLine',1,11,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0)
,('LOTO Details',2,'LOTO Details','lotoField1',1,1,0,0,'','0',0,0,0,@PERMIT_NAME,1,0,@PERMIT_INITIAL,0,0,1,NULL,NULL,0,0,0,0,1,0,0,0,1,'','','','0','','','','',0,1,1,0,24,'',0,0,0,0,0,0,0);
;

INSERT INTO @permitWorkflow ([type],[in],[out],[order])
VALUES(@PERMIT_NAME,'Submitted','Awaiting Approval',1);

EXEC test.createPermitForm @KIOSKID=@KIOSKID
,@FormFields=@permitFields
,@workflow=@permitWorkflow;

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[lotoEnergySources]
      ([lotoEnergySourceName],
      [lotoEnergySourceIsActive],
      [kioskID],[kioskSiteUUID]
    )
    SELECT  TOP(@batchSize) 
      [energySources].[energySourceName], 
      [energySources].[isActive], 
      [energySources].[kioskID], 
      [site].[kioskSiteUUID]
    FROM @energySources AS [energySources]
    INNER JOIN [dbo].[kioskSite] AS [site]
      ON [site].[KIOSKID] = @KIOSKID
    LEFT JOIN [dbo].[lotoEnergySources] b
      ON b.lotoEnergySourceName = [energySources].[energySourceName]
    WHERE b.lotoEnergySourceName IS NULL;

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative Energy Sources insertion: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;

END

PRINT 'Batch update lotoEnergyMagnitudes table...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[lotoEnergyMagnitudes](
      [lotoEnergyMagnitudeName],
      [lotoEnergyMagnitudeIsActive],
      [kioskID],
      [kioskSiteUUID],
      [lotoEnergySourceID])
    SELECT TOP(@batchSize) 
      [energyMagnitudes].[energyMagnitudeName], 
      [energyMagnitudes].[isActive], 
      [energyMagnitudes].[kioskID], 
      [site].[kioskSiteUUID],
      row_number() OVER (ORDER BY [site].KIOSKID ASC)
    FROM @energyMagnitudes AS [energyMagnitudes]
    INNER JOIN [dbo].[kioskSite] AS [site]
      ON [site].[KIOSKID] = @KIOSKID
    LEFT JOIN [dbo].[lotoEnergyMagnitudes] b
      ON b.lotoEnergyMagnitudeName = [energyMagnitudes].[energyMagnitudeName]
    WHERE b.lotoEnergyMagnitudeName IS NULL;

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative Energy Magnitudes insertion:: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;
