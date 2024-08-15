-- ==========================================================
-- Author:      Alexandre Tran
-- Create date: 07/06/2020
-- Description: Setup approver for COSHH
-- 07/06/2020 - AT - Created
-- ==========================================================

SET NOCOUNT ON;

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

DECLARE @approvers TABLE(
  [email] VARCHAR(255)
);

INSERT INTO @approvers([email])
VALUES('coshh.approver@onelooksystems.com')
,('ehs.manager@onelooksystems.com');

DECLARE @count INT = 0;
DECLARE @batchSize INT = 500;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

PRINT 'Attempt to add approvers to groups membership...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO [dbo].[kioskUserAccessControlGroupMembership](
  [kioskID],[kioskSiteUUID],[kuacgmIsActive]
  ,[kuID],[kacgID]
  ,[kuacgmCreateBy],[kuacgmCreateUTC]
  )
  SELECT TOP(@batchSize) [user].[kioskid],[setting].[kioskSiteUUID],1
  ,[user].[kuid],[setting].[coshhSettingApproverID]
  ,0,GETUTCDATE()
  FROM @approvers AS [account]
  INNER JOIN [dbo].[kioskUser] AS [user]
    ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuemailN])) = [account].[email]
  FULL OUTER JOIN [dbo].[coshhSetting] AS [setting]
    ON [setting].[kioskSiteUUID] IS NOT NULL
  LEFT JOIN [dbo].[kioskUserAccessControlGroupMembership] AS [membership]
    ON [membership].[kioskid] = [user].[kioskid]
    AND [membership].[kioskSiteuuid] = [setting].[kioskSiteuuid]
    AND [membership].[kuacgmIsActive] = 1
    AND [membership].[kuid] = [user].[kuid]
    AND [membership].[kacgid] = [setting].[coshhSettingApproverID]
  WHERE [membership].[kuacgmid] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative add COSHH approver to group: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Group membership added successfully!';

PRINT 'Activate approver...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO [dbo].[coshhApprover](
  [kioskID],[kioskSiteUUID]
  ,[kuID],[coshhApproverIsActive]
  )
  SELECT TOP(@batchSize) [user].[kioskid],[setting].[kioskSiteUUID]
  ,[user].[kuid],1
  FROM @approvers AS [account]
  INNER JOIN [dbo].[kioskUser] AS [user]
    ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuemailN])) = [account].[email]
  FULL OUTER JOIN [dbo].[coshhSetting] AS [setting]
    ON [setting].[kioskSiteUUID] IS NOT NULL
  LEFT JOIN [dbo].[coshhApprover] AS [approver]
    ON [approver].[kioskid] = [user].[kioskid]
    AND [approver].[kioskSiteuuid] = [setting].[kioskSiteuuid]
    AND [approver].[kuid] = [user].[kuid]
    AND [approver].[coshhApproverIsActive] = 1
  WHERE [approver].[kuid] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative activate COSHH approver: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Activate approver successfull';

PRINT 'Activate approver type...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO [dbo].[coshhApproverType](
    [kioskID],[kioskSiteUUID],[coshhApproverTypeIsActive]
    ,[coshhReferenceApproverTypeID],[coshhApproverID]
  )
  SELECT TOP(@batchSize) [user].[kioskid],[approver].[kioskSiteUUID],1
  ,[type].[coshhReferenceApproverTypeID],[approver].[coshhApproverID]
  FROM @approvers AS [account]
  INNER JOIN [dbo].[kioskUser] AS [user]
    ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuemailN])) = [account].[email]
  INNER JOIN [dbo].[coshhApprover] AS [approver]
    ON [approver].[kuid] = [user].[kuid]
  INNER JOIN [dbo].[coshhReferenceApproverType] AS [type]
    ON [type].[kioskid] = [user].[kioskid]
    AND [type].[kiosksiteuuid] = [approver].[kiosksiteuuid]
    AND [type].[coshhReferenceApproverTypeIsActive] = 1
  LEFT JOIN [dbo].[coshhApproverType] AS [registered]
    ON [registered].[kioskid] = [user].[kioskid]
    AND [registered].[kioskSiteUUID] = [approver].[kioskSiteUUID]
    AND [registered].[coshhApproverTypeIsActive] = 1
    AND [registered].[coshhReferenceApproverTypeID] = [type].[coshhReferenceApproverTypeID]
    AND [registered].[coshhApproverID] = [approver].[coshhApproverID]
  WHERE [registered].[coshhApproverTypeID] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative activate COSHH approver type: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Activate approver type successfull!';
