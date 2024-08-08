IF OBJECT_ID('tempdb..#translations') IS NOT NULL DROP TABLE #translations;
GO

CREATE TABLE #translations
(
    [id]      INT,
    [active]  BIT,
    [uuid]    VARCHAR(50) NOT NULL,
    [section] VARCHAR(255),
    [page]    VARCHAR(255),
    [target]  VARCHAR(525)
);

INSERT INTO #translations ([id], [active], [uuid], [section], [page], [target])
VALUES (2383, 1, 'b40a0a76-f133-47f6-93e4-915704e4a1bc', '', '', N'Confined Space Entry deleted successfully.'),
(2384, 1, 'b46f52a6-97b6-4b70-bf9e-39d845662530', '', '', N'Confirm Deletion'),
(2385, 1, '0a963d04-56d2-4ad6-91ca-f57052387176', '', '', N'Are you sure you want to delete this entry?')
;

SET IDENTITY_INSERT [kioskLanguage] ON;

BEGIN

    BEGIN TRANSACTION;

    INSERT INTO [kioskLanguage] ( [klangID], [klangIsActive]
                                , [klangUUID], [kbcSection], [kbcPage]
                                , [en], [en_ie]
                                , [klangEnglish], [en_GB])
    SELECT [translation].[id]
         , [translation].[active]
         , [translation].[uuid]
         , [translation].[section]
         , [translation].[page]
         , REPLACE([translation].[target], '''', '&#x27;')
         , REPLACE([translation].[target], '''', '&#x27;')
         , REPLACE([translation].[target], '''', '&#x27;')
         , REPLACE([translation].[target], '''', '&#x27;')
    FROM #translations AS [translation]
             LEFT JOIN [kioskLanguage] AS [kiosk] ON [kiosk].[klangID] = [translation].[id]
    WHERE [kiosk].[klangID] IS NULL;

    COMMIT TRANSACTION;
END

SET IDENTITY_INSERT [kioskLanguage] OFF;

BEGIN

    BEGIN TRANSACTION;

    UPDATE [kiosk]
    SET [kiosk].[en]           = REPLACE(
            REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'), '&#x3a;',
            ':')
      , [kiosk].[en_IE]        = REPLACE(
            REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'), '&#x3a;',
            ':')
      , [kiosk].[klangEnglish] = REPLACE(
            REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'), '&#x3a;',
            ':')
      , [kiosk].[en_GB]        = REPLACE(
            REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'), '&#x3a;',
            ':')
    FROM [kioskLanguage] AS [kiosk]
             INNER JOIN #translations AS [translation] ON [translation].[id] = [kiosk].[klangID]
    WHERE REPLACE(REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'),
                  '&#x3a;', ':') != ISNULL([kiosk].[en], '') COLLATE Latin1_General_CI_AS
       OR REPLACE(REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'),
                  '&#x3a;', ':') != ISNULL([kiosk].[en_IE], '') COLLATE Latin1_General_CI_AS
       OR REPLACE(REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'),
                  '&#x3a;', ':') != ISNULL([kiosk].[klangEnglish], '') COLLATE Latin1_General_CI_AS
       OR REPLACE(REPLACE(REPLACE(REPLACE([translation].[target], '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'),
                  '&#x3a;', ':') != ISNULL([kiosk].[en_GB], '') COLLATE Latin1_General_CI_AS;

    COMMIT TRANSACTION;
END