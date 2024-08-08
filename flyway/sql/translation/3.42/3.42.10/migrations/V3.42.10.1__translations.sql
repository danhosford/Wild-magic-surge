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
VALUES (2377, 1, '267c93ba-890c-40d3-99b7-4f5fd1407dc2', '', '', N'Course Submissions &#x28;Pending approval&#x29;'),
(2378, 1, '7d1f3729-a212-4250-bd30-8a60a570b78b', '', '', N'submitted on'),
(2379, 1, 'caeb4d4b-1c5c-4408-9941-66b185f8de6b', '', '', N'My Courses &#x28;To Do&#x29;')
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