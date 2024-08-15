-- ==========================================================
-- Author:      Nick King
-- Create date: 20/09/2019
-- Description: Migrate field answer translation
-- * 29/09/2019 - AT - Switch to transfer in translations table
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
    [answer].[narrative],[kiosk].[kioskUUID]
    ,MIN([answer].[createdon]) AS [createdon]
    ,MIN([answer].[createdon]) AS [updatedon]
  FROM (
    SELECT [answer].[formFieldAnswerText] AS [narrative]
      ,[answer].[kioskid]
      ,GETDATE() AS [createdon]
    FROM [dbo].[formFieldAnswers] AS [answer]
    GROUP BY [answer].[kioskid],[answer].[formFieldAnswerText]
  ) AS [answer]
  LEFT JOIN #translations AS [en]
    ON [en].[text] = [answer].[narrative] COLLATE Latin1_General_CI_AS
  LEFT JOIN [v3_sp].[dbo].[kiosk] AS [kiosk]
    ON [kiosk].[kioskid] = [answer].[kioskid]
  WHERE [en].[uuid] IS NULL
  GROUP BY [kiosk].[kioskuuid]
    ,[answer].[narrative];

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    RAISERROR('Cumulative temporary insert from form field creation: %d', 0, 1, @count) WITH NOWAIT;

  COMMIT TRANSACTION;
END

PRINT 'Populate hint with course form answers...';

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

PRINT 'Update uuid for historical course answers...';

Set @results = 1;
WHILE (@results > 0)
BEGIN

  BEGIN TRANSACTION;

  UPDATE TOP(@batchSize) [answer]
  SET [answer].[hintUUID] = [hint].[uuid]
  FROM [dbo].[formFieldAnswers] AS [answer]
  INNER JOIN [language].[hints] AS [hint]
    ON [hint].[text] = [answer].[formFieldAnswerText]
  WHERE [answer].[hintUUID] IS NULL;

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    RAISERROR('Cumulative insert existing from course answer creation: %d', 0, 1, @count) WITH NOWAIT;

  COMMIT TRANSACTION;
END

GO

