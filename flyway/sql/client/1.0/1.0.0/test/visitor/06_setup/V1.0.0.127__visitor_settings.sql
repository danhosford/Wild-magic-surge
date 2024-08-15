-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 26/11/2020
-- Description: Create Visitor Settings
-- * 26/11/2020 - JC - Created
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

PRINT 'Create visitorSettings variable table...';

DECLARE @visitorSettings TABLE (
    [adminID] VARCHAR(255) NOT NULL
    ,[bookerID] VARCHAR(255) NOT NULL
    ,[securityID] VARCHAR(255) NOT NULL
    ,[vsIsActive] BIT NOT NULL
    ,[vsAddedBy] INT NOT NULL
    ,[vsAddedUTC] DATETIME NOT NULL
    ,[kioskID] INT NOT NULL
    ,[isBadgeDynamic] BIT NOT NULL
    ,[defaultBadgeFile] BIT NOT NULL
    ,[defaultDynamicBadge] VARCHAR(MAX) NOT NULL
    ,[defaultDynamicBadgeUnits] VARCHAR(10) NOT NULL
    ,[defaultDynamicBadgeWidth] FLOAT NOT NULL
    ,[defaultDynamicBadgeHeight] FLOAT NOT NULL
    ,[defaultEmailFile] BIT NOT NULL
    ,[additionalEmailFile] BIT NOT NULL
);

PRINT 'Insert Into visitorSettings table...';

INSERT INTO @visitorSettings 
VALUES
('Visitor Administrator'
,'Visitor Booker'
,'Visitor Security'
,1
,0
,GETUTCDATE()
,@KIOSKID
,1
,1
,'<p>&nbsp;</p>
<div style="margin-top: 23px;" align="right">
<div class="profileImage" style="text-align: center;" align="center">[profilePhoto]</div>
<div class="profileImage" style="text-align: center;" align="center"><strong>[name] - [company]</strong></div>
<div class="profileImage" style="text-align: center;" align="center">Visiting - [host]&nbsp;</div>
<div class="profileImage" style="text-align: center;" align="center">[dateArrival]&nbsp;Badge [securityNumber]</div>
<div class="profileImage" style="text-align: center; background-color: [visitortypecolour];" align="center">[visitorType]</div>
<div class="profileImage" style="text-align: center;" align="center">&nbsp;</div>
</div>'
,'cm'
,5.5
,8.5
,0
,0);

UPDATE [dbo].[visitorSetting]
SET [vsIsActive] = 0,
    [vsDeactivateUTC] = GETUTCDATE(),
    [vsDeactivateBy] = 0
WHERE [vsIsActive] = 1
AND [vsAddedUTC] <= GETUTCDATE() 

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[visitorSetting] 
    ([vsIsActive]
      ,[kioskID]
      ,[vsIsBadgeDynamic]
      ,[kioskSiteUUID]
      ,[vsAddedUTC]
      ,[vsAddedBy]
      ,[vsAdministratorID]
      ,[vsBookerID]
      ,[vsSecurityID]
      ,[vsDefaultBadgeFile]
      ,[vsDefaultDynamicBadge]
      ,[vsDefaultDynamicBadgeUnits]
      ,[vsDefaultDynamicBadgeWidth]
      ,[vsDefaultDynamicBadgeHeight]
      ,[vsDefaultEmailFile]
      ,[vsAdditionalEmailFile])
    SELECT TOP(@batchSize)
        [settings].[vsIsActive]
        ,[settings].[kioskID]
        ,[settings].[isBadgeDynamic]
        ,[site].[kioskSiteUUID]
        ,[settings].[vsAddedUTC]
        ,[settings].[vsAddedBy]
        ,[admin].[kacgID]
        ,[booker].[kacgID]
        ,[security].[kacgID]
        ,[settings].[defaultBadgeFile]
        ,[settings].[defaultDynamicBadge]
        ,[settings].[defaultDynamicBadgeUnits]
        ,[settings].[defaultDynamicBadgeWidth]
        ,[settings].[defaultDynamicBadgeHeight]
        ,[settings].[defaultEmailFile]
        ,[settings].[additionalEmailFile]
    FROM @visitorSettings AS [settings] 
    INNER JOIN [dbo].[kioskSite] AS [site]
        ON [site].[KIOSKID] = @KIOSKID
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [admin]
        ON [admin].[kacgName] = [settings].[adminID]
        AND [admin].[kioskSiteUUID] = [site].[kioskSiteUUID]
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [booker]
        ON [booker].[kacgName] = [settings].[bookerID]
        AND [booker].[kioskSiteUUID] = [site].[kioskSiteUUID]
    INNER JOIN [dbo].[kioskAccessControlGroup] AS [security]
        ON [security].[kacgName] = [settings].[securityID]
        AND [security].[kioskSiteUUID] = [site].[kioskSiteUUID]
    LEFT JOIN [dbo].[visitorSetting] AS [historical]
        ON [historical].[vsAdministratorID] = [admin].[kacgID]
        AND [historical].[vsBookerID] = [booker].[kacgID]
        AND [historical].[vsSecurityID] = [security].[kacgID]
        AND [historical].[vsIsActive] = [Settings].[vsIsActive]
        AND [historical].[kioskSiteUUID] = [site].[kioskSiteUUID]
        AND [historical].[vsDefaultBadgeFile] = [settings].[defaultBadgeFile]
        AND [historical].[vsDefaultDynamicBadge] = [settings].[defaultDynamicBadge]
        AND [historical].[vsDefaultDynamicBadgeUnits] = [settings].[defaultDynamicBadgeUnits]
        AND [historical].[vsDefaultEmailFile] = [settings].[defaultEmailFile]
        AND [historical].[vsAdditionalEmailFile] = [settings].[additionalEmailFile]
    WHERE [historical].[vsID] IS NULL;

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative Visitor Settings insertion:: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;