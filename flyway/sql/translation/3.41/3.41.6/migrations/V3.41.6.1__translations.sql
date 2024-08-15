BEGIN
  BEGIN TRANSACTION;

  -- * 17/07/2023 - LK - Updating Spanish (Costa Rica) translations.

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Compañia','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 75;

 UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Configure la localización','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 113;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Cualificación','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 170;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Nombre de la compañia','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 195;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Agregar / editar el personal','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 288;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Cualificación de la empresa','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1397;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Informe de la cualificación de la compañía','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1399;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Aprobación automática de cualificación','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1425;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Informe de cualificación del contratista','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1452;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_CR] = REPLACE(REPLACE(REPLACE(REPLACE(N'Compañia en la que el personal puede dar servicios','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1829;


  -- * 17/07/2023 - LK - Updating Japanese translations.

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'作業内容の通知','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 50;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'許可証申請を作業者に通知','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 657;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'作業員の役割','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1355;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'作業員の役割','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1479;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'作業員の資格レポート','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1806;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'時承認する','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1839;

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[ja_JP] = REPLACE(REPLACE(REPLACE(REPLACE(N'拒否する','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
  WHERE [kioskLanguage].[klangID] = 1840;


  -- * 17/07/2023 - LK - Updating Spanish (Mexican) translations.

  UPDATE [kioskLanguage]
  SET [kioskLanguage].[es_MX] = REPLACE(REPLACE(REPLACE(REPLACE(N'Relación &#x28;el texto se enviará por correo electrónico a quien solicitó el permiso&#x29;.', '''', '&#x27;'), '(', '&#x28;'), ')', '&#x29;'), '&#x3a;', ':')
  WHERE [kioskLanguage].[klangID] = 658;

  COMMIT TRANSACTION;
END