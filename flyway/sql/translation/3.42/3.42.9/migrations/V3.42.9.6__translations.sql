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
VALUES (2376, 1, 'a676eb12-870d-4c30-9240-b1981f7c4d46', '', '', N'Setup your SafePermit Account'),
       (2363, 1, '9b9653c2-802f-4d44-b7ea-1c9705ccd63a', '', '', N'Your SafePermit account has been created for'),
       (2364, 1, '07884238-73a4-4d9e-95a9-8b5462654a11', '', '', N'This is your temporary password, which does not expire.'),
       (2365, 1, '2039faf1-b572-45ab-8795-7e1e2957fd83', '', '', N'Temporary password'),
       (2366, 1, '16437495-65a9-4692-8694-3c43c98cf32b', '', '', N'When logging in for the first time, you will be required to create a new password.'),
       (2367, 1, '00e79590-1e95-4052-a93b-264b56a791b0', '', '', N'For more information and support, visit the'),
       (2368, 1, '9bd25a23-2b61-4b2d-b0dd-75d6bc98af44', '', '', N'Control of Work support page.'),
       (2369, 1, '78d0d69d-2e8d-4f66-9cae-395b2384ec4d', '', '', N'or copy the url into your browser:')
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