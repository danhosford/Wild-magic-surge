BEGIN
  BEGIN TRANSACTION;

  -- * 27/09/2023 - JK - Updating Portuguese.

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Todos','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 401;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Todos selecionado','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 1473;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Localização do Site','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2167;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Apenas trabalhadores activos','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2194;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Apenas trabalhadores inactivos','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2195;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Tempo dispensado no site','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2295;

    UPDATE [kioskLanguage]
    SET [kioskLanguage].[pt_PT] = REPLACE(REPLACE(REPLACE(REPLACE(N'Ficheiro de qualificação','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    WHERE [kioskLanguage].[klangID] = 2296;

  COMMIT TRANSACTION;
END