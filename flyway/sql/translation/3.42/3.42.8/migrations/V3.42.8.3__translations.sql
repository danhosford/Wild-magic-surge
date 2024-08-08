BEGIN
    BEGIN TRANSACTION;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[en] = REPLACE(REPLACE(REPLACE(REPLACE(N'This location name already exists under the parent location. Change the location name and try again.','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2337;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[en_IE] = REPLACE(REPLACE(REPLACE(REPLACE(N'This location name already exists under the parent location. Change the location name and try again.','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2337;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[klangEnglish] = REPLACE(REPLACE(REPLACE(REPLACE(N'This location name already exists under the parent location. Change the location name and try again.','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2337;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[en_GB] = REPLACE(REPLACE(REPLACE(REPLACE(N'This location name already exists under the parent location. Change the location name and try again.','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2337;

    COMMIT TRANSACTION;
END