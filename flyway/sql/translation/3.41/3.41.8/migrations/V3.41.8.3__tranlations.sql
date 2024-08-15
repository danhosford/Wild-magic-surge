
BEGIN
  BEGIN TRANSACTION;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'REQUISITOS DE EPP','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 866;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Solicitado por','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 47;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Detalle de permiso','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 782;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'requiere su aprobación fue enviado','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 837;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Un permiso que usted solicitó fue aprobado.','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 890;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Un permiso que usted solicitó fue rechazado por','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 1463;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Entrega de permiso','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2198;

  COMMIT TRANSACTION;
END