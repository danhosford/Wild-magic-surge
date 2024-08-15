-- =============================================
-- Author:      Jamie Conroy
-- Create date: 10/09/2020
-- Description: Script to add an approver to the maintain approver list
-- Parameters:
-- CHANGELOG:
-- =============================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

DECLARE @count INT = 0;
DECLARE @batchSize INT = 50;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

SET NOCOUNT ON;

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

PRINT 'Create approver_list variable table...';

DECLARE @approver_list TABLE (
  [kioskID] INT NOT NULL,
  [group] VARCHAR(50) NOT NULL,
  [email] VARCHAR(50) NOT NULL,
  [isActive] BIT NOT NULL,
  [createBy] INT NOT NULL,
  [createUTC] DATETIME NOT NULL,
  [site] VARCHAR(50) NOT NULL);

PRINT 'Insert Into approver_list table...';

INSERT INTO @approver_list 
VALUES
(@kioskID,'Approve Permit','permit.super.admin@onelooksystems.com',1,0,GETUTCDATE(), 'Ireland');

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[kioskUserAccessControlGroupMembership]
      ([kioskID]
      ,[kuID]
      ,[kacgID]
      ,[kuacgmCreateBy]
      ,[kuacgmCreateUTC]
      ,[kuacgmIsActive]
      ,[kioskSiteUUID])
    SELECT [list].[kioskID]
          ,[user].[kuID]
          ,[group].[kacgID]
          ,[list].[createBy]
          ,[list].[createUTC]
          ,[list].[isActive]
          ,[site].[kioskSiteUUID]
    FROM @approver_list AS [list]
    LEFT JOIN [dbo].[kioskSite] AS [site]
      ON [site].[kioskID] = [list].[kioskID]
      AND [site].[kioskSiteName] = [list].[site]
    LEFT JOIN [dbo].[kioskAccessControlGroup] AS [group]
      ON [group].[kacgName] = [list].[group]
      AND [group].[kioskID] = [list].[kioskID]
      AND [group].[kioskSiteUUID] = [site].[kioskSiteUUID]
    LEFT JOIN [dbo].[kioskUser] AS [user]
      ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[kuEmailN])) = [list].[email]
      AND [user].[kioskID] = [list].[kioskID]
    LEFT JOIN [dbo].[kioskUserAccessControlGroupMembership] AS [historical]
      ON [historical].[kuID] = [user].[kuID]
    AND [historical].[kacgID] = [group].[kacgID]
    WHERE [historical].[kuacgmID] IS NULL
    
    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative approver list insertion: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;

END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;