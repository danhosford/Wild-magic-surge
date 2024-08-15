-- ===================================================================================
-- Author:      Jamie Conroy
-- Create date: 01/04/2020
-- Changelog: 
-- 01/04/2020 - JC - Set the user group for approve permit and workflow controller
-- 07/05/2020 - AT - Setup permit administration group for all sites
-- 20/12/2020 - AT - Prevent duplicate to setting to be registered
-- 22/12/2020 - AT - Remove unused code
-- 22/12/2020 - AT - Change update to update also those defined to inexisting group
-- ===================================================================================
SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

DECLARE @count INT = 0;
DECLARE @batchSize INT = 500;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

DECLARE @userGroupDetails TABLE (
  [kioskSiteName] VARCHAR(50) NOT NULL,
  [permitApproverGroup] VARCHAR(50) NOT NULL,
  [workflowControllerGroup] VARCHAR(50) NOT NULL,
  [permitSysAdminGroup] VARCHAR(50) NOT NULL,
  [paclgID] INT NOT NULL,
  [LOTOReinstatementGroup] VARCHAR(50) NOT NULL,
  [LOTOAdminGroup] VARCHAR(50) NOT NULL,
  [isActive] BIT NOT NULL,
  [addedBy] INT NOT NULL,
  [addedUTC] DATETIME NOT NULL
);

INSERT INTO @userGroupDetails
SELECT [site].[kioskSiteName],'Approve Permit','Workflow Controller','PERMIT Super Admin',0,0,0,1,0,GETUTCDATE()
FROM [kioskSite] AS [site];

PRINT 'Insert Into permitAclGroupSetting table...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  -- Only need to insert based on site as only 1 active at the time
  INSERT INTO [permitAclGroupSetting](
    [kioskID], 
    [paclgID], 
    [psagID],
    [paclApproverGroup], 
    [paclLOTOReinstatementGroup], 
    [paclLOTOAdminGroup],
    [paclWorkflowControllerGroup], 
    [paclgsIsActive], 
    [paclgsAddedBy], 
    [paclgsAddedUTC], 
    [kioskSiteUUID]
  )
  SELECT TOP(@batchSize) [site].[kioskid],
    [userGroupDetails].[paclgID],
    [permitSysAdmin].[kacgid],
    [approve].[kacgid],
    [userGroupDetails].[LOTOReinstatementGroup],
    [userGroupDetails].[LOTOAdminGroup],
    [workflow].[kacgid],
    [userGroupDetails].[isActive],
    [userGroupDetails].[addedBy],
    [userGroupDetails].[addedUTC],
    [site].[kioskSiteUUID]
  FROM @userGroupDetails AS [userGroupDetails]
  INNER JOIN [dbo].[kioskSite] AS [site]
    ON [site].[kioskSiteName] = [userGroupDetails].[kioskSiteName]
  INNER JOIN [kioskAccessControlGroup] AS [permitSysAdmin]
    ON [permitSysAdmin].[kioskSiteUUID] = [site].[kioskSiteUUID]
    AND [permitSysAdmin].[kacgName] = [userGroupDetails].[permitSysAdminGroup]
  INNER JOIN [kioskAccessControlGroup] AS [approve]
    ON [approve].[kioskSiteUUID] = [site].[kioskSiteUUID]
    AND [approve].[kacgName] = [userGroupDetails].[permitApproverGroup]
  INNER JOIN [kioskAccessControlGroup] AS [workflow]
    ON [workflow].[kioskSiteUUID] = [approve].[kioskSiteUUID]
    AND [workflow].[kacgName] = [userGroupDetails].[workflowControllerGroup]
  LEFT JOIN [permitAclGroupSetting] AS [pags]
    ON [pags].[kioskSiteUUID] = [site].[kioskSiteUUID]
    AND [pags].[paclgsDeactivateUTC] IS NULL
  WHERE [pags].[paclgsID] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative insert permit ACL group: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Uptade existing permit group settings...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  UPDATE TOP(@batchSize) [setting]
  SET [setting].[psagID] = [updateSysAdmin].[kacgid]
    ,[setting].[paclApproverGroup] = [updateApprover].[kacgid]
    ,[setting].[paclWorkflowControllerGroup] = [updateworkflow].[kacgid]
    ,[setting].[paclgsIsActive] = 1
  FROM [permitAclGroupSetting] AS [setting]
  INNER JOIN [dbo].[kioskSite] AS [site]
    ON [site].[kioskSiteUUID] = [setting].[kioskSiteUUID]
  LEFT JOIN [kioskAccessControlGroup] AS [permitSysAdmin]
    ON [permitSysAdmin].[kioskSiteUUID] = [setting].[kioskSiteUUID]
    AND [permitSysAdmin].[kacgid] = [setting].[psagID]
  LEFT JOIN [kioskAccessControlGroup] AS [approver]
    ON [approver].[kioskSiteUUID] = [setting].[kioskSiteUUID]
    AND [approver].[kacgid] = [setting].[paclApproverGroup]
  LEFT JOIN [kioskAccessControlGroup] AS [workflow]
    ON [workflow].[kioskSiteUUID] = [setting].[kioskSiteUUID]
    AND [workflow].[kacgid] = [setting].[paclWorkflowControllerGroup]
  INNER JOIN @userGroupDetails AS [newsetting]
    ON [newSetting].[kioskSiteName] = [site].[kioskSiteName]
    AND ([newSetting].[permitSysAdminGroup] != [permitSysAdmin].[kacgName]
      OR [newSetting].[permitApproverGroup] != [approver].[kacgName]
      OR [newSetting].[workflowControllerGroup] != [workflow].[kacgName]
      OR [setting].[paclgsIsActive] = 0
    )
  INNER JOIN [kioskAccessControlGroup] AS [updateSysAdmin]
    ON [updateSysAdmin].[kioskSiteUUID] = [setting].[kioskSiteUUID]
    AND [updateSysAdmin].[kacgName] = [newsetting].[permitSysAdminGroup]
  INNER JOIN [kioskAccessControlGroup] AS [updateApprover]
    ON [updateApprover].[kioskSiteUUID] = [setting].[kioskSiteUUID]
    AND [updateApprover].[kacgName] = [newsetting].[permitApproverGroup]
  INNER JOIN [kioskAccessControlGroup] AS [updateworkflow]
    ON [updateworkflow].[kioskSiteUUID] = [setting].[kioskSiteUUID]
    AND [updateworkflow].[kacgName] = [newsetting].[workflowControllerGroup]
  ;
  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative update permit ACL group: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;