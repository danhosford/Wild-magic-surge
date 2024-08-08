BEGIN
    BEGIN TRANSACTION;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_PR] = REPLACE(
            REPLACE(REPLACE(REPLACE(N'Compañía', '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'), '&#x3a;',
            ':')
    WHERE [kioskLanguage].[klangID] = 75;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_CR] = REPLACE(
            REPLACE(REPLACE(REPLACE(N'Compañía', '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'), '&#x3a;',
            ':')
    WHERE [kioskLanguage].[klangID] = 75;

    COMMIT TRANSACTION;
END