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
VALUES (2345, 1, '665956bc-d8a5-41bf-80dc-d20fea23ed00', '', '', N'Worker Name'),
       (2346, 1, 'ee5cfdc4-33ee-4a50-98ab-229ec2314b28', '', '', N'Access Type'),
       (2347, 1, '31df3525-3f83-46ce-a599-1d1dc2509578', '', '', N'Entry/Exit Time'),
       (2348, 1, 'f5788a3e-8f02-4483-96d0-651a874f6ea2', '', '', N'Recorded By'),
       (2349, 1, '9bdae065-8733-40d4-91d3-2b4787b4930b', '', '', N'Entered (In)'),
       (2350, 1, 'bda3d973-de3b-4eb1-b188-311b22f5ed0b', '', '', N'Exited (Out)'),
       (2351, 1, '370d4216-f615-44be-a525-a9a571ffbc21', '', '', N'Add Entry'),
       (2352, 1, '813cc5f8-a704-42e8-8859-302bac1409ac', '', '', N'Please select a Worker.'),
       (2353, 1, '91555f01-50fa-4cec-9a10-464782f81ed0', '', '', N'Please select an Access Type.'),
       (2354, 1, '58a655df-71a0-4401-8410-0250fbf1ffc2', '', '', N'Please select an Entry/Exit Time.'),
       (2355, 1, 'd2feae44-459b-4b70-86c7-fb03e4be01cd', '', '', N'Confined Space Entry saved successfully.'),
       (2356, 1, '86eb0358-9731-45f4-b710-59bd1d55f476', '', '', N'You are editing an existing entry.'),
       (2357, 1, '9432acb1-586e-45a7-b258-495e92d6770e', '', '', N'Confined Space Entry Log')
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