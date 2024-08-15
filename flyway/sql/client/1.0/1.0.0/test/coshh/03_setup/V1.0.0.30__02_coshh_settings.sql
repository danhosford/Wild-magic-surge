-- ==========================================================
-- Author:      Shane Gibbons
-- Create date: 26/11/2020
-- Description: Create COSHH User Settings
-- * 26/11/2020 - SG - Created
-- * 01/11/2021 - JC - Ensure inner joins are using active settings and correct kioskid
-- ==========================================================

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

PRINT 'Create coshhSettings variable table...';

DECLARE @coshhSettings TABLE (
    [kioskID] INT NOT NULL
    ,[coshhSettingCreateBy] INT NOT NULL
    ,[coshhSettingCreateUTC] DATETIME NOT NULL
    ,[coshhSettingIsActive] BIT NOT NULL
    ,[coshhSettingRequestorID] VARCHAR(255) NOT NULL
    ,[coshhSettingRiskAssessorID] VARCHAR(255) NOT NULL
    ,[coshhSettingApproverID] VARCHAR(255) NOT NULL
    ,[coshhSettingAdministratorID] VARCHAR(255) NOT NULL
    ,[coshhSettingViewOnlyID] VARCHAR(255) NOT NULL
    ,[coshhSettingHazardousColour] VARCHAR(255) NOT NULL
    ,[coshhSettingNonHazardousColour] VARCHAR(255) NOT NULL
    ,[coshhSettingUseProductSearch] INT NOT NULL
    ,[coshhSettingSDSExpiry] INT NOT NULL
);

PRINT 'Insert Into coshhSettings table...';

INSERT INTO @coshhSettings 
VALUES(
  @KIOSKID
  ,0
  ,GETUTCDATE()
  ,1
  ,'COSHH Requestor'
  ,'COSHH Assessor'
  ,'COSHH Approver'
  ,'COSHH Administrator'
  ,'COSHH View Only'
  ,'#000000'
  ,'#000000'
  ,1
  ,0
);

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[coshhSetting] 
    ([kioskID]
    ,[kioskSiteUUID]
    ,[coshhSettingCreateBy]
    ,[coshhSettingCreateUTC]
    ,[coshhSettingIsActive]
    ,[coshhSettingRequestorID]
    ,[coshhSettingRiskAssessorID]
    ,[coshhSettingApproverID]
    ,[coshhSettingAdministratorID]
    ,[coshhSettingViewOnlyID]
    ,[coshhSettingHazardousColour]
    ,[coshhSettingNonHazardousColour]
    ,[coshhSettingUseProductSearch]
    ,[coshhSettingSDSExpiry])
    SELECT TOP(@batchSize)
        [settings].[kioskID]
        ,[site].[kioskSiteUUID]
        ,[settings].[coshhSettingCreateBy]
        ,[settings].[coshhSettingCreateUTC]
        ,[settings].[coshhSettingIsActive]
        ,[requestor].[kacgID]
        ,[assessor].[kacgID]
        ,[approver].[kacgID]
        ,[admin].[kacgID]
        ,[viewonly].[kacgID]
        ,[settings].[coshhSettingHazardousColour]
        ,[settings].[coshhSettingNonHazardousColour]
        ,[settings].[coshhSettingUseProductSearch]
        ,[settings].[coshhSettingSDSExpiry]
    FROM @coshhSettings AS [settings] 
    INNER JOIN [dbo].[kioskSite] AS [site]
        ON [site].[KIOSKID] = @KIOSKID
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [requestor]
        ON [requestor].[kacgName] = [settings].[coshhSettingRequestorID]
        AND [requestor].[kioskID] = [settings].[kioskID]
        AND [requestor].[kioskSiteUUID] = [site].[kioskSiteUUID]
        AND [requestor].[kacgIsActive] = 1
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [assessor]
        ON [assessor].[kacgName] = [settings].[coshhSettingRiskAssessorID]
        AND [assessor].[kioskID] = [settings].[kioskID]
        AND [assessor].[kioskSiteUUID] = [site].[kioskSiteUUID]
        AND [assessor].[kacgIsActive] = 1
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [approver]
        ON [approver].[kacgName] = [settings].[coshhSettingApproverID]
        AND [approver].[kioskID] = [settings].[kioskID]
        AND [approver].[kioskSiteUUID] = [site].[kioskSiteUUID]
        AND [approver].[kacgIsActive] = 1
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [admin]
        ON [admin].[kacgName] = [settings].[coshhSettingAdministratorID]
        AND [admin].[kioskID] = [settings].[kioskID]
        AND [admin].[kioskSiteUUID] = [site].[kioskSiteUUID]
        AND [admin].[kacgIsActive] = 1
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [viewonly]
        ON [viewonly].[kacgName] = [settings].[coshhSettingViewOnlyID]
        AND [viewonly].[kioskID] = [settings].[kioskID]
        AND [viewonly].[kioskSiteUUID] = [site].[kioskSiteUUID]
        AND [viewonly].[kacgIsActive] = 1
    LEFT JOIN [dbo].[coshhSetting] AS [historical]
        ON [historical].[coshhSettingRequestorID] = [requestor].[kacgID]
        AND [historical].[coshhSettingRiskAssessorID] = [assessor].[kacgID]
        AND [historical].[coshhSettingApproverID] = [approver].[kacgID]
        AND [historical].[coshhSettingAdministratorID] = [admin].[kacgID]
        AND [historical].[coshhSettingViewOnlyID] = [viewonly].[kacgID]
        AND [historical].[coshhSettingIsActive] = [settings].[coshhSettingIsActive]
        AND [historical].[kioskSiteUUID] = [site].[kioskSiteUUID]
    WHERE [historical].[coshhSettingID] IS NULL
        AND [historical].[kioskSiteUUID] IS NULL;

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative COSHH Settings insertion: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;
