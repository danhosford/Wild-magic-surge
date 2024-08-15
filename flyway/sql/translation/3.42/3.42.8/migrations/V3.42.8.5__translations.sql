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
VALUES (2339, 1, 'd4d0f789-7747-49bf-8fb7-83990efdc726', '', '', N'You are editing an existing reading.'),
       (2340, 1, '898a574c-3c17-4621-b608-46ae7a10c745', '', '', N'Gas reading saved successfully.'),
       (2341, 1, '05c3e74b-3462-41ec-9a71-a7a9e8e7d481', '', '', N'Please select a user for Measured By.'),
       (2342, 1, 'c2f1208d-0a01-402b-b905-47d0ff12e886', '', '', N'Please select a Date/Time.'),
       (2343, 1, '3d4e4d91-fb13-4f89-a00d-db76189c6fc3', '', '', N'At least one reading must be entered.'),
       (2344, 1, '05d9e685-490a-4605-972a-6cf2b43b54f9', '', '', N'Please enter a numeric value for the reading.')

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