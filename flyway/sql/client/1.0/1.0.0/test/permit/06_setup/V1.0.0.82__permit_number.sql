-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 27/08/2020
-- Description: Turn on permit number on site US Central
-- ==========================================================
SET NOCOUNT ON;

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @count INT = 0;
DECLARE @batchSize INT = 50;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

PRINT 'Create a temp table for site...';

DECLARE @siteName TABLE (
  [site] VARCHAR(100) NOT NULL
);

PRINT 'Insert values into the site temp table...';

INSERT INTO @siteName 
VALUES
('US Central');
    
SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN
    
  SET @starttime = GETUTCDATE();
  
  UPDATE [setting]
  SET [setting].[ksAssignNumberOnPermitCreation] = 1
  FROM [dbo].[kioskSetting] AS [setting]
  FULL OUTER JOIN @siteName AS [name]
    ON [name].[site] IS NOT NULL
  INNER JOIN [dbo].[kioskSite] AS [site]
    ON [site].[kioskID] = [setting].[kioskid]
    AND [site].[kioskSiteName] = [name].[site]
  WHERE [setting].[kioskID] = @KIOSKID
    AND [setting].[ksAssignNumberOnPermitCreation] = 0;
  
  --Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative permit number setting update: %d', 0, 1, @count) WITH NOWAIT;
  
  CHECKPOINT;

END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;

SET NOCOUNT OFF;
