-- ======================================================================================
-- Author:      Alexandre Tran
-- Create date: 22/09/2019
-- Description:
-- * 21/09/2019 - AT - Tied kiosk uuid
-- * 23/10/2019 - AT - Add execution time
-- ======================================================================================

IF OBJECT_ID('tempdb..#translations') IS NOT NULL DROP TABLE #translations;
GO

SET NOCOUNT ON;

DECLARE @SYSTEM_USER_ID UNIQUEIDENTIFIER = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER);
DECLARE @DEFAULT_LANG VARCHAR(5) = 'en_IE';

DECLARE @StartingRecord BIGINT;
DECLARE @count INT = 0;
DECLARE @batchSize INT = 500;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

-- Insert into temporary table to generate uuid
CREATE TABLE #translations (
	[rownumber] INT IDENTITY(1,1) PRIMARY KEY
	,[uuid] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID()
	,[text] VARCHAR(MAX) NOT NULL
	,[kioskuuid] UNIQUEIDENTIFIER NOT NULL
	,[createdon] DATETIME NOT NULL
	,[updatedon] DATETIME NOT NULL
);

PRINT 'Tied kiosk uuid to course...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

	UPDATE TOP(@batchSize) [course]
	SET [course].[kiosk] = [kiosk].[kioskuuid]
	FROM [dbo].[cmCourses] AS [course]
	LEFT JOIN [v3_sp].[dbo].[kiosk] AS [kiosk]
		ON [kiosk].[kioskID] = [course].[kioskID]
	WHERE [course].[kiosk] IS NULL
		AND [course].[kioskID] IS NOT NULL;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative upate kiosk uuid: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Migrate all course information to temporary table...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO #translations ([text],[kioskuuid],[createdon],[updatedon])
	SELECT TOP(@batchSize)
	[hint].[text]
	,[hint].[kiosk]
	,ISNULL(MIN([hint].[createdon]),GETUTCDATE()) AS [createdon]
	,ISNULL(MIN([hint].[createdon]),GETUTCDATE()) AS [updatedon]
	FROM (
		SELECT [course].[kiosk]
			,[course].[courseAddedUTC] AS [createdon]
			,CAST([course].[courseName] AS NVARCHAR(MAX)) AS [name]
			,CAST([course].[courseDescription] AS NVARCHAR(MAX)) AS [description]
			,[course].[coursePrereqIntoText] AS [introduction]
			,[course].[coursePostSubmitText] AS [postsubmission]
			,CAST([course].[courseDuration] AS NVARCHAR(MAX)) AS [duration]
		FROM [dbo].[cmCourses] AS [course]
	) AS [course]
	UNPIVOT(
		[text]
		FOR [key] IN ([course].[name]
			,[course].[description]
			,[course].[introduction]
			,[course].[postsubmission]
			,[course].[duration]
		)
	) AS [hint]
	LEFT JOIN #translations AS [existing]
		ON [existing].[text] = [hint].[text] COLLATE Latin1_General_CI_AS
	WHERE TRIM([hint].[text]) != ''
		AND [existing].[uuid] IS NULL
	GROUP BY [hint].[kiosk]
		,[hint].[text];

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative insert all course information into temporary table: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

PRINT 'Transfer translation from temporary table to live table...';

SET @results = 1;
SET @count = 0;
SET @StartingRecord = 1;

WHILE (@results > 0)
BEGIN

	SET @starttime = GETUTCDATE();

	INSERT INTO [language].[translations](
		[uuid],[parent],[text]
		,[kioskuuid],[language]
		,[createdby],[createdon]
		,[updatedby],[updatedon]
	)
	SELECT TOP(@batchSize) 
		[translation].[uuid],[translation].[uuid], [translation].[text]
		,[translation].[kioskuuid],@DEFAULT_LANG
		,@SYSTEM_USER_ID,[translation].[createdon] AS [createdon]
		,@SYSTEM_USER_ID,[translation].[updatedon] AS [updatedon]
	FROM #translations AS [translation]
	LEFT JOIN [language].[translations] AS [en]
		ON [en].[text] = [translation].[text] COLLATE Latin1_General_CI_AS
	WHERE [en].[uuid] IS NULL
		AND [translation].[rownumber] BETWEEN @StartingRecord AND @StartingRecord + @batchSize - 1;

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
	SET @endtime = GETUTCDATE();
	SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative insert translation from temporary to live table: %d --- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;
	SELECT @StartingRecord += @batchSize
	CHECKPOINT;
END

PRINT 'Update course with translation hint uuid...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

	SET @starttime = GETUTCDATE();

	UPDATE TOP(@batchSize) [course]
	SET [course].[name] = [translation].[uuid]
	FROM [dbo].[cmCourses] AS [course]
	LEFT JOIN [language].[translations] AS [translation]
		ON [translation].[text] = [course].[courseName] COLLATE Latin1_General_CI_AS
	WHERE [course].[name] IS NULL
		AND [translation].[uuid] IS NOT NULL;

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
	SET @endtime = GETUTCDATE();
	SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative upate course name hint uuid : %d --- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;
	
	CHECKPOINT;
END

PRINT 'Migrate course information into course language table...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

	SET @starttime = GETUTCDATE();

	INSERT INTO [course].[languages](
		[kiosk],[course]
		,[lang],[key],[value]
		,[createdby],[createdon]
		,[updatedby],[updatedon]
	)
	SELECT TOP(@batchSize)
		[hint].[kiosk],[hint].[course]
		,@DEFAULT_LANG,[hint].[key],[translation].[uuid]
		, @SYSTEM_USER_ID,[hint].[createdon]
		, @SYSTEM_USER_ID,[hint].[createdon]
	FROM (
		SELECT [course].[kiosk]
			,[course].[uuid] AS [course]
			,CAST([course].[courseName] AS NVARCHAR(MAX)) AS [name]
			,CAST([course].[courseDescription] AS NVARCHAR(MAX)) AS [description]
			,[course].[coursePrereqIntoText] AS [introduction]
			,[course].[coursePostSubmitText] AS [postsubmission]
			,CAST([course].[courseDuration] AS NVARCHAR(MAX)) AS [duration]
			,ISNULL(MIN([course].[courseAddedUTC]),GETUTCDATE()) AS [createdon]
		FROM [dbo].[cmCourses] AS [course]
		GROUP BY [course].[kiosk]
			,[course].[courseAddedUTC]
			,[course].[uuid]
			,[course].[courseName]
			,[course].[courseDescription]
			,[course].[coursePrereqIntoText]
			,[course].[coursePostSubmitText]
			,[course].[courseDuration]
	) AS [course]
	UNPIVOT(
		[text]
		FOR [key] IN ([course].[name]
			,[course].[description]
			,[course].[introduction]
			,[course].[postsubmission]
			,[course].[duration]
		)
	) AS [hint]
	LEFT JOIN [language].[translations] AS [translation]
		ON [translation].[text] = [hint].[text] COLLATE Latin1_General_CI_AS
	LEFT JOIN  [course].[languages] AS [existing]
		ON [existing].[course] = [hint].[course]
		AND [existing].[key] = [hint].[key]
		AND [existing].[lang] = @DEFAULT_LANG
	WHERE TRIM([hint].[text]) != ''
		AND [translation].[uuid] IS NOT NULL
		AND [existing].[course] IS NULL;

    -- Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
	SET @endtime = GETUTCDATE();
	SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Cumulative insert course details into course lang: %d --- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;
	
	CHECKPOINT;
END
SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @startScriptTime, @endScriptTime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;