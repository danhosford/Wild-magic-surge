
IF OBJECT_ID('tempdb..#translations') IS NOT NULL DROP TABLE #translations;
GO

CREATE TABLE #translations
(
[id] INT,
[active] BIT,
[uuid] VARCHAR(50) NOT NULL,
[section] VARCHAR(255),
[page] VARCHAR(255),
[target] VARCHAR(525)
);

INSERT INTO #translations ([id],[active],[uuid],[section],[page],[target])
VALUES (2301,1,'d959b947-7748-4147-baec-92a62bc79b64','','',N'Link an Isolation Certificate')
,(2302,1,'d3efc46d-5576-426a-b15f-3bf10cbb1ac2','','',N'Isolation Certificates')
,(2303,1,'94a048c3-44a5-431a-9163-41576b19634d','','',N'There are no existing Isolation Certificates for this site location')
,(2304,1,'8b2eff7f-ebe6-40e7-b1b0-661494cbfbc3','','',N'ID')
,(2305,1,'3f760970-faf5-4358-817b-39b465614ced','','',N'Creator')
,(2306,1,'5fbd1b83-862e-4ece-a09b-f36008cbd87e','','',N'Asset')
;

SET IDENTITY_INSERT [kioskLanguage] ON;

BEGIN

  BEGIN TRANSACTION;

  INSERT INTO [kioskLanguage] ([klangID],[klangIsActive]
  ,[klangUUID],[kbcSection],[kbcPage]
  ,[en],[en_ie]
  ,[klangEnglish],[en_GB])
  SELECT [translation].[id],[translation].[active]
    ,[translation].[uuid],[translation].[section],[translation].[page]
    ,REPLACE([translation].[target],'''','&#x27;'),REPLACE([translation].[target],'''','&#x27;')
    ,REPLACE([translation].[target],'''','&#x27;'),REPLACE([translation].[target],'''','&#x27;')
  FROM #translations AS  [translation]
  LEFT JOIN [kioskLanguage] AS [kiosk]
    ON [kiosk].[klangID] = [translation].[id]
  WHERE  [kiosk].[klangID] IS NULL;

COMMIT TRANSACTION;
END

SET IDENTITY_INSERT [kioskLanguage] OFF;

BEGIN

  BEGIN TRANSACTION;

  UPDATE [kiosk]
  SET [kiosk].[en] = REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    ,[kiosk].[en_IE] = REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    ,[kiosk].[klangEnglish] = REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    ,[kiosk].[en_GB] = REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  FROM [kioskLanguage] AS [kiosk]
  INNER JOIN #translations AS  [translation]
    ON [translation].[id] = [kiosk].[klangID]
  WHERE REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':') != ISNULL([kiosk].[en],'') COLLATE Latin1_General_CI_AS
    OR REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':') != ISNULL([kiosk].[en_IE],'') COLLATE Latin1_General_CI_AS
    OR REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':') != ISNULL([kiosk].[klangEnglish],'') COLLATE Latin1_General_CI_AS
    OR REPLACE(REPLACE(REPLACE(REPLACE([translation].[target],'''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':') != ISNULL([kiosk].[en_GB],'') COLLATE Latin1_General_CI_AS;

  COMMIT TRANSACTION;
END