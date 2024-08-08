
BEGIN
    BEGIN TRANSACTION;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'一時承認する','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 1839;

    COMMIT TRANSACTION;
END