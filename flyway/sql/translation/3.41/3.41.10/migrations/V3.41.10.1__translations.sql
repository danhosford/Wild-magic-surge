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
VALUES (2299,1,'084aa3ed-65e7-4f7a-b592-273ef759aad3','','',N'Account Status Updated: User was deactivated from the CP User screen'),
(2300,1,'2b5ae827-1bdd-40b1-b363-2edc406e5da8','','',N'Account Status Updated: User was activated from the CP User screen')
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