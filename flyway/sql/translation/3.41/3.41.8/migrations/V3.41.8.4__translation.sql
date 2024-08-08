BEGIN
  BEGIN TRANSACTION;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Todos selecionados','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 1473;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Número de permiso','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 781;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Saludos','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 790;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_es] = REPLACE(REPLACE(REPLACE(REPLACE(N'Saludos','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 790;

  COMMIT TRANSACTION;
END