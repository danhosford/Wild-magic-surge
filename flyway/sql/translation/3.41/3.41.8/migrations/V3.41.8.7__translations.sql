BEGIN
  BEGIN TRANSACTION;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[de_DE] = REPLACE(REPLACE(REPLACE(REPLACE(N'Nicht verpflichtend','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2288;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[de_DE] = REPLACE(REPLACE(REPLACE(REPLACE(N'Arbeiter Qualification','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2289;

  COMMIT TRANSACTION;
END