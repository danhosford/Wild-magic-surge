BEGIN
    BEGIN TRANSACTION;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[en] = REPLACE(REPLACE(REPLACE(REPLACE(N'If you are not receiving the password reset link email, be sure to check your &#x22junk&#x22 folder and that you are using the same email address provided to the site point of contact. For further assistance, view our %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2335;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[en_IE] = REPLACE(REPLACE(REPLACE(REPLACE(N'If you are not receiving the password reset link email, be sure to check your &#x22junk&#x22 folder and that you are using the same email address provided to the site point of contact. For further assistance, view our %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2335;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[klangEnglish] = REPLACE(REPLACE(REPLACE(REPLACE(N'If you are not receiving the password reset link email, be sure to check your &#x22junk&#x22 folder and that you are using the same email address provided to the site point of contact. For further assistance, view our %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2335;

        UPDATE [kioskLanguage]
        SET [kioskLanguage].[en_GB] = REPLACE(REPLACE(REPLACE(REPLACE(N'If you are not receiving the password reset link email, be sure to check your &#x22junk&#x22 folder and that you are using the same email address provided to the site point of contact. For further assistance, view our %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        WHERE [kioskLanguage].[klangID] = 2335;

    COMMIT TRANSACTION;
END