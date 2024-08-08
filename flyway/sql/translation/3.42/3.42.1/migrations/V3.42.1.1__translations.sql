
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
VALUES (2283,1,'c2388577-bc8e-4dde-a0ca-1bbd6d103c34','','',N'Show QR code on HTML Permit')
    ,(2284,1,'b922d75a-ddd5-4bed-aceb-8057f509a046','','',N'Show QR code on PDF Permit')
    ,(2285,1,'ad2502d9-6434-4012-bf8d-94969a09ad09','','',N'QR X Value:')
    ,(2286,1,'3b0bad68-9217-4d03-bde4-963659aa0b53','','',N'QR Y Value:')
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