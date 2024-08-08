BEGIN
    BEGIN TRANSACTION;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_cr] = REPLACE(REPLACE(REPLACE(REPLACE(N'Buscar compañía','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 222;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_cr] = REPLACE(REPLACE(REPLACE(REPLACE(N'Ver la lista completa de las compañía','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 224;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_cr] = REPLACE(REPLACE(REPLACE(REPLACE(N'Añadir una compañía','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 225;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_cr] = REPLACE(REPLACE(REPLACE(REPLACE(N'Detalles de la compañía en espera de aprobación','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 229;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_cr] = REPLACE(REPLACE(REPLACE(REPLACE(N'Usuarios de la compañía','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 312;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_cr] = REPLACE(REPLACE(REPLACE(REPLACE(N'Página de la compañía','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 336;

    COMMIT TRANSACTION;
END