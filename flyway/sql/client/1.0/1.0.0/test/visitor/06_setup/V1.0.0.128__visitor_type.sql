-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 25/11/2020
-- Description: Create Visitor Type
-- * 25/11/2020 - JC - Created
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

PRINT 'Create visitorType variable table...';

DECLARE @visitorType TABLE (
  [visitorType] VARCHAR(255) NOT NULL
  ,[visitorTypeColour] VARCHAR(255) NOT NULL
  ,[visitorTypeBadgeType] INT NOT NULL
  ,[visitorTypeActive] BIT NOT NULL
  ,[visitorTypeCreateBy] INT NOT NULL
  ,[visitorTypeCreateUTC] DATETIME NOT NULL
  ,[kioskID] INT NOT NULL
  ,[isContractor] BIT NOT NULL
);

PRINT 'Insert Into visitorType table...';

INSERT INTO @visitorType 
VALUES
('Visitor','&#x23;5cb85c',1,1,0,GETUTCDATE(), @KIOSKID,0)
,('Contractor','&#x23;FF0000',1,1,0,GETUTCDATE(), @KIOSKID,1);

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

    INSERT INTO [dbo].[visitorType]
      ([visitorType]
      ,[visitorTypeColour]
      ,[visitorTypeBadgeType]
      ,[visitorTypeActive]
      ,[visitorTypeCreateBy]
      ,[visitorTypeCreateUTC]
      ,[kioskID]
      ,[kioskSiteUUID]
      ,[isContractor])
    SELECT  TOP(@batchSize)
      [type].[visitorType]
      ,[type].[visitorTypeColour]
      ,[type].[visitorTypeBadgeType]
      ,[type].[visitorTypeActive]
      ,[type].[visitorTypeCreateBy]
      ,[type].[visitorTypeCreateUTC]
      ,[type].[kioskID]
      ,[site].[kioskSiteUUID]
      ,[type].[isContractor]
    FROM @visitorType AS [type]
    INNER JOIN [dbo].[kioskSite] AS [site]
      ON [site].[KIOSKID] = @KIOSKID
    LEFT JOIN [dbo].[visitorType] AS [historical]
      ON [historical].[visitorType] = [type].[visitorType]
      AND [historical].[kioskSiteUUID] = [site].[kioskSiteUUID]
    WHERE [historical].[visitorType] IS NULL;

    --Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative Visitor Type insertion:: %d', 0, 1, @count) WITH NOWAIT;

    CHECKPOINT;
END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;