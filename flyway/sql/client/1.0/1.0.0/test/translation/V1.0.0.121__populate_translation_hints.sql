-- ==========================================================
-- Author:      Alexandre Tran
-- Create date: 19/09/2019
-- Description: Rerun translation update after dummy data populated
-- 11/12/2020 - SG - New batch update to update test kiosks with new mapping translations
-- ==========================================================

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#translations') IS NOT NULL DROP TABLE #translations;
GO

--Variable for site
DECLARE @SYSTEM_USER_ID UNIQUEIDENTIFIER = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER);

DECLARE @count INT = 0;
DECLARE @batchSize INT = 500;
DECLARE @results INT = 1;

PRINT 'Populate hint with all existing translation...';

-- Insert into temporary table to generate uuid
CREATE TABLE #translations (
  [uuid] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
  ,[text] VARCHAR(MAX) NOT NULL
  ,[kioskuuid] UNIQUEIDENTIFIER NOT NULL
  ,[createdon] DATETIME NOT NULL
  ,[updatedon] DATETIME NOT NULL
);

Set @results = 1;
WHILE (@results > 0)
BEGIN

  BEGIN TRANSACTION;

  INSERT INTO #translations(
    [text],[kioskuuid]
    ,[createdon],[updatedon]
  )
  SELECT TOP(@batchSize) 
    [question].[narrative],[kiosk].[kioskUUID]
    ,MIN([question].[createdon]) AS [createdon]
    ,MIN([question].[createdon]) AS [updatedon]
  FROM (
    SELECT [question].[formFieldNarrative] AS [narrative]
      ,[question].[kioskid]
      ,ISNULL(MIN([question].[fcfqCreateUTC]),GETUTCDATE()) AS [createdon]
    FROM [dbo].[formCreateFieldQuestion] AS [question]
    GROUP BY [question].[kioskid],[question].[formFieldNarrative]
    UNION
    SELECT [question].[formFieldName] AS [narrative]
      ,[question].[kioskid]
      ,ISNULL(MIN([question].[formFieldCreateUTC]),GETUTCDATE()) AS [createdon]
    FROM [dbo].[formField] AS [question]
    GROUP BY [question].[kioskid],[question].[formFieldName]
  ) AS [question]
  LEFT JOIN #translations AS [en]
    ON [en].[text] = [question].[narrative] COLLATE Latin1_General_CI_AS
  LEFT JOIN [v3_sp].[dbo].[kiosk] AS [kiosk]
    ON [kiosk].[kioskid] = [question].[kioskid]
  WHERE [en].[uuid] IS NULL
  GROUP BY [kiosk].[kioskuuid]
    ,[question].[narrative];

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    RAISERROR('Cumulative temporary insert from form field creation: %d', 0, 1, @count) WITH NOWAIT;

  COMMIT TRANSACTION;
END

Set @results = 1;
WHILE (@results > 0)
BEGIN

  BEGIN TRANSACTION;

  INSERT INTO [language].[translations](
    [uuid],[parent],[text]
    ,[kioskuuid],[language]
    ,[createdby],[createdon]
    ,[updatedby],[updatedon]
  )
  SELECT TOP(@batchSize) 
    [translation].[uuid],[translation].[uuid], [translation].[text]
    ,[translation].[kioskuuid],'en_IE'
    ,@SYSTEM_USER_ID,[translation].[createdon] AS [createdon]
    ,@SYSTEM_USER_ID,[translation].[updatedon] AS [updatedon]
  FROM #translations AS [translation]
  LEFT JOIN [language].[translations] AS [en]
    ON [en].[text] = [translation].[text] COLLATE Latin1_General_CI_AS
  WHERE [en].[uuid] IS NULL;

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    RAISERROR('Cumulative insert existing from form field creation: %d', 0, 1, @count) WITH NOWAIT;

  COMMIT TRANSACTION;
END

PRINT 'Apply mapping translations across all sites...';

SET @results = 1;
WHILE (@results > 0)
BEGIN

  BEGIN TRANSACTION;

  INSERT INTO [language].[translations](
    [kioskuuid],[kioskSiteUUID]
    ,[uuid],[parent],[language]
    ,[text],[mappingKey],[description]
    ,[createdby],[createdon]
    ,[updatedby],[updatedon]
  )
  SELECT TOP(@batchSize)
    [kiosk].[kioskuuid],IIF([translation].[mappingKey] IS NULL, NULL,[site].[kioskSiteUUID])
    ,[generator].[uuid],[generator].[uuid],[translation].[language]
    ,[translation].[text],[translation].[mappingKey],[translation].[description]
    ,[translation].[createdby],[translation].[createdon]
    ,[translation].[createdby],[translation].[updatedon]
  FROM [language].[translations] AS [translation]
  FULL OUTER JOIN [kioskSite] AS [site]
    ON [site].[kioskid] IS NOT NULL
  INNER JOIN [v3_sp].[dbo].[kiosk] AS [kiosk]
    ON [site].[kioskID] = [kiosk].[kioskID]
  LEFT JOIN (SELECT NEWID() AS [uuid]) AS [generator] 
    ON 1 = 1
  LEFT JOIN [language].[translations] AS [existing]
    ON ([translation].[mappingKey] IS NULL
        AND [existing].[text] = [translation].[text] COLLATE Latin1_General_CI_AS)
      OR ([translation].[mappingKey] IS NOT NULL
        AND [existing].[mappingKey] = [translation].[mappingKey]
        AND [existing].[kiosksiteuuid] = [site].[kiosksiteuuid])
  WHERE [existing].[uuid] IS NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  RAISERROR('Cumulative apply mapping translations across all sites: %d', 0, 1, @count) WITH NOWAIT;

  COMMIT TRANSACTION;
END

PRINT 'Update uuid for historical form fields...';

Set @results = 1;
WHILE (@results > 0)
BEGIN

  BEGIN TRANSACTION;

  UPDATE TOP(@batchSize) [question]
  SET [question].[hintuuid] = [hint].[uuid]
  FROM [dbo].[formCreateFieldQuestion] AS [question]
  INNER JOIN [language].[hints] AS [hint]
    ON [hint].[text] = [question].[formFieldNarrative]
  WHERE [question].[hintUUID] IS NULL;

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    RAISERROR('Cumulative insert existing from form field creation: %d', 0, 1, @count) WITH NOWAIT;

  COMMIT TRANSACTION;
END

PRINT 'Update uuid of form fields...';

Set @results = 1;
WHILE (@results > 0)
BEGIN

  BEGIN TRANSACTION;

  UPDATE TOP(@batchSize) [question]
  SET [question].[hintuuid] = [hint].[uuid]
  FROM [dbo].[formField] AS [question]
  INNER JOIN [language].[hints] AS [hint]
    ON [hint].[text] = [question].[formFieldName]
  WHERE [question].[hintUUID] IS NULL;

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    RAISERROR('Cumulative insert existing from form field creation: %d', 0, 1, @count) WITH NOWAIT;

  COMMIT TRANSACTION;
END