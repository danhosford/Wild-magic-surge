BEGIN
    BEGIN TRANSACTION;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[fr_FR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Numéro','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 41;

    COMMIT TRANSACTION;
END