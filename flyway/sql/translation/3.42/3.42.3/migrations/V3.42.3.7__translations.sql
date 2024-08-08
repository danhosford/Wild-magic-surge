
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
VALUES (2309,1,'d959b947-7748-4147-baec-92a62bc79b64','','',N'Change Tracking')
,(2310,1,'faedaf08-a64a-4783-9beb-4eb2cbee1629','','',N'was linked by %s on %s at %s.')
,(2311,1,'6c24551a-5177-4318-acab-99cd4b9cf276','','',N'was unlinked by %s on %s at %s.')
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