BEGIN
    BEGIN TRANSACTION;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'IMPRIMIR EL PERMISO','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 675;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'IMPRIMIR EL PERMISO','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 675;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_PR] = REPLACE(REPLACE(REPLACE(REPLACE(N'IMPRIMIR EL PERMISO','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 675;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[es_ES] = REPLACE(REPLACE(REPLACE(REPLACE(N'IMPRIMIR EL PERMISO','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 675;

    COMMIT TRANSACTION;
END