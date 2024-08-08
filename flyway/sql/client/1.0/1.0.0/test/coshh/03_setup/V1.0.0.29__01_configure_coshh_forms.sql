-- ============================================================================
-- Author:      Jamie Conroy
-- Create date: 20/05/2020
-- Description: TESTING ONLY SCRIPT - Configure COSHH Form
-- * 20/05/2020 - JC - Include update script to enable coshh product search
-- * 07/06/2020 - AT - Ensure pass is taken from env
-- * 16/07/2020 - BOL - Fix update to turn on COSHH Product Search, initial value is NULL not 0
-- * 27/11/2020 - SG - Updating all the UPDATES/INSERTS here so they apply across all sites
-- * 30/11/2020 - SG - Removing @USER_KUID and making it an INNER JOIN in the batch update
-- * 30/11/2020 - SG - Updating UPDATES/INSERTS so the correct kiosk/site is being updated
-- * 02/12/2020 - SG - Changing inner SELECT's into JOIN's so it performs better
-- * 02/12/2020 - SG - Adding raw data into variable tables so we can add more
-- ============================================================================
SET NOCOUNT ON;

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @count INT = 0;
DECLARE @batchSize INT = 50;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

-- Ignore old COSHH form types. Use one added in build setup. 
UPDATE formType SET formIsActive = 0, formName = 'OLD - Assess Product' WHERE formTypePublicKey = '67D2A631C67712B6889AF320241A83E9-159607E0-994B-29F2-963C3BD8F4BF2CBE';

PRINT 'Create userSettings variable table...';
DECLARE @userSettings TABLE (
    [kioskID] INT NOT NULL
    ,[kuEmailN] VARCHAR(255) NOT NULL
    ,[coshhApproverIsActive] BIT NOT NULL
);

PRINT 'Insert Into userSettings table...';
INSERT INTO @userSettings 
VALUES (@KIOSKID,'coshh.approver@onelooksystems.com',1);

PRINT 'Create coshhApproverReference variable table...';
DECLARE @coshhApproverReference TABLE (
    [kioskID] INT NOT NULL
    ,[coshhReferenceApproverTypeName] VARCHAR(255) NOT NULL
    ,[coshhReferenceApproverTypeIsActive] BIT NOT NULL
);

PRINT 'Insert Into coshhApproverReference table...';
INSERT INTO @coshhApproverReference 
VALUES (@KIOSKID,'EHS',1);

PRINT 'Add system admin tester account as a coshh approver...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[coshhApprover](
      [kioskID]
      ,[kioskSiteUUID]
      ,[kuID]
      ,[coshhApproverIsActive])
    SELECT TOP(@batchSize)
      [userSettings].[kioskID]
      ,[site].[kioskSiteUUID]
      ,[user].[kuID]
      ,[userSettings].[coshhApproverIsActive]
    FROM @userSettings AS [userSettings]
    INNER JOIN [dbo].[kioskSite] AS [site]
      ON [site].[kioskID] = [userSettings].[kioskID]
    INNER JOIN [kioskUser] AS [user]
      ON [user].[kioskID] = [site].[kioskID]
      AND DECRYPTBYPASSPHRASE(@PASS,[user].[kuEmailN]) = [userSettings].[kuEmailN]
    LEFT JOIN [dbo].[coshhApprover] AS [historical]
      ON [historical].[kuID] = [user].[kuID]
      AND [historical].[coshhApproverIsActive] = [userSettings].[coshhApproverIsActive]
      AND [historical].[kioskID] = [site].[kioskID]
      AND [historical].[kioskSiteUUID] = [site].[kioskSiteUUID]
    WHERE [site].[KIOSKID] = @KIOSKID
      AND [historical].[kuID] IS NULL;

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative add COSHH approver: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END


PRINT 'Add coshh approver group EHS...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[coshhReferenceApproverType](
      [kioskID]
      ,[kioskSiteUUID]
      ,[coshhReferenceApproverTypeName]
      ,[coshhReferenceApproverTypeIsActive])
    SELECT TOP(@batchSize) 
      [site].[kioskID]
      ,[site].[kioskSiteUUID]
      ,[coshhApproverReference].[coshhReferenceApproverTypeName]
      ,[coshhApproverReference].[coshhReferenceApproverTypeIsActive]
    FROM @coshhApproverReference AS [coshhApproverReference]
    INNER JOIN [dbo].[kioskSite] AS [site]
      ON [site].[kioskID] = [coshhApproverReference].[kioskID]
    LEFT JOIN [dbo].[coshhReferenceApproverType] AS [historical]
      ON [historical].[kioskID] = [site].[kioskID]
      AND [historical].[kioskSiteUUID] = [site].[kioskSiteUUID]
      AND [historical].[coshhReferenceApproverTypeIsActive] = [coshhApproverReference].[coshhReferenceApproverTypeIsActive]
      AND [historical].[coshhReferenceApproverTypeName] = [coshhApproverReference].[coshhReferenceApproverTypeName]
    WHERE [site].[KIOSKID] = @KIOSKID
      AND [historical].[kioskSiteUUID] IS NULL;

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative add COSHH approver group EHS: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END


PRINT 'Add system admin tester account to coshh approver group EHS...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[coshhApproverType](
      [kioskID]
      ,[kioskSiteUUID]
      ,[coshhReferenceApproverTypeID]
      ,[coshhApproverID]
      ,[coshhApproverTypeIsActive])
    SELECT TOP(@batchSize) 
      [site].[kioskID]
      ,[site].[kioskSiteUUID]
      ,MAX([coshhReferenceApproverType].[coshhReferenceApproverTypeID])
      ,MAX([coshhApprover].[coshhApproverID])
      ,1
    FROM [dbo].[kioskSite] AS [site]
    INNER JOIN [dbo].[coshhApprover] AS [coshhApprover]
      ON [coshhApprover].[kioskID] = [site].[kioskID]
      AND [coshhApprover].[kioskSiteUUID] = [site].[kioskSiteUUID]
    INNER JOIN [dbo].[coshhReferenceApproverType] AS [coshhReferenceApproverType]
      ON [coshhReferenceApproverType].[kioskID] = [site].[kioskID]
      AND [coshhReferenceApproverType].[kioskSiteUUID] = [site].[kioskSiteUUID]
    LEFT JOIN [dbo].[coshhApproverType] AS [historical]
      ON [historical].[kioskID] = [site].[kioskID]
      AND [historical].[kioskSiteUUID] = [site].[kioskSiteUUID]
      AND [historical].[coshhApproverTypeIsActive] = 1
      AND [historical].[coshhApproverID] = [coshhApprover].[coshhApproverID]
      AND [historical].[coshhReferenceApproverTypeID] = [coshhReferenceApproverType].[coshhReferenceApproverTypeID]
    WHERE [site].[KIOSKID] = @KIOSKID
      AND [historical].[kioskSiteUUID] IS NULL
      GROUP BY [site].[kioskID]
               ,[site].[kioskSiteUUID]
               ,[coshhReferenceApproverType].[coshhReferenceApproverTypeID]
               ,[coshhApprover].[coshhApproverID];

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative adding of system admin tester account to coshh approver group EHS: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END


PRINT 'Configure COSHH approver field to use EHS group...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[coshhFormFieldApprover](
      [kioskID]
      ,[kioskSiteUUID]
      ,[formTypeID]
      ,[formFieldID]
      ,[coshhReferenceApproverTypeID]
      ,[coshhFormFieldApproverIsActive])
    SELECT TOP(@batchSize) 
      [site].[kioskID]
      ,[site].[kioskSiteUUID]
      ,[formType].[formTypeID]
      ,[formField].[formFieldID]
      ,MAX([coshhReferenceApproverType].[coshhReferenceApproverTypeID])
      ,1
    FROM [dbo].[kioskSite] AS [site]
    INNER JOIN [dbo].[formType] AS [formType]
      ON [formType].[formModuleID] = 8
      AND [formType].[formIsActive] = 1
      AND [formType].[formNarrative] = 'COSHH Request Product - Auto generated'
      AND [formType].[kioskID] = [site].[kioskID]
      AND [formType].[kioskSiteUUID] = [site].[kioskSiteUUID]
    LEFT JOIN [dbo].[formType] AS [formTypeHistory]
      ON [formTypeHistory].[formModuleID] = [formType].[formModuleID]
      AND [formTypeHistory].[formIsActive] = [formType].[formIsActive]
      AND [formTypeHistory].[formNarrative] = [formType].[formNarrative]
      AND [formTypeHistory].[kioskID] = [formType].[kioskID]
      AND [formTypeHistory].[kioskSiteUUID] = [formType].[kioskSiteUUID]
      AND [formTypeHistory].[formCreateUTC] > [formType].[formCreateUTC]
    INNER JOIN [dbo].[formField] AS [formField]
      ON [formField].[formFieldType] = 'coshhApprover'
      AND [formField].[kioskID] = [site].[kioskID]
      AND [formField].[kioskSiteUUID] = [site].[kioskSiteUUID]
      AND [formField].[formFieldToolTip] != ''
    LEFT JOIN [dbo].[formField] AS [formFieldHistory]
      ON [formFieldHistory].[formFieldType] = [formField].[formFieldType]
      AND [formFieldHistory].[kioskID] = [formField].[kioskID]
      AND [formFieldHistory].[kioskSiteUUID] = [formField].[kioskSiteUUID]
      AND [formFieldHistory].[formFieldToolTip] != [formField].[formFieldToolTip]
      AND [formFieldHistory].[formFieldCreateUTC] > [formField].[formFieldCreateUTC]
    INNER JOIN [dbo].[coshhReferenceApproverType] AS [coshhReferenceApproverType]
      ON [coshhReferenceApproverType].[kioskID] = [site].[kioskID]
      AND [coshhReferenceApproverType].[kioskSiteUUID] = [site].[kioskSiteUUID]
    LEFT JOIN [dbo].[coshhFormFieldApprover] AS [historical]
      ON [historical].[kioskID] = [site].[kioskID]
      AND [historical].[kioskSiteUUID] = [site].[kioskSiteUUID]
      AND [historical].[coshhFormFieldApproverIsActive] = 1
      AND [historical].[coshhReferenceApproverTypeID] = [coshhReferenceApproverType].[coshhReferenceApproverTypeID]
    WHERE [site].[KIOSKID] = @KIOSKID
      AND [historical].[kioskSiteUUID] IS NULL
      AND [formFieldHistory].[formFieldID] IS NULL
      AND [formTypeHistory].[formTypeID] IS NULL
      GROUP BY [site].[kioskID]
               ,[site].[kioskSiteUUID]
               ,[formType].[formTypeID]
               ,[formField].[formFieldID]
               ,[coshhReferenceApproverType].[coshhReferenceApproverTypeID];

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative configuring of COSHH approver field to use EHS group: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END


PRINT 'Ensure that coshh Product Search is turned on for site...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  UPDATE TOP(@batchSize) [settings]
  SET [settings].[coshhSettingUseProductSearch] = 1
  FROM [dbo].[coshhSetting] AS [settings]
  INNER JOIN [dbo].[kioskSite] AS [site]
    ON [site].[KIOSKID] = [settings].[kioskID]
    AND [site].[kioskSiteUUID] = [settings].[kioskSiteUUID]
  WHERE ([settings].[coshhSettingUseProductSearch] IS NULL 
    OR [settings].[coshhSettingUseProductSearch] = 0);
	

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative check that coshh Product Search is turned on for site: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;