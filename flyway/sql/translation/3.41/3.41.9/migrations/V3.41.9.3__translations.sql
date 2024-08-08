BEGIN
  BEGIN TRANSACTION;

    UPDATE [kiosk]
    SET [kiosk].[en] = REPLACE(REPLACE(REPLACE(REPLACE(N'Account Status: User status was changed from %s to %s. Reason&#x3a; %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        ,[kiosk].[en_IE] = REPLACE(REPLACE(REPLACE(REPLACE(N'Account Status: User status was changed from %s to %s. Reason&#x3a; %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        ,[kiosk].[klangEnglish] = REPLACE(REPLACE(REPLACE(REPLACE(N'Account Status: User status was changed from %s to %s. Reason&#x3a; %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
        ,[kiosk].[en_GB] = REPLACE(REPLACE(REPLACE(REPLACE(N'Account Status: User status was changed from %s to %s. Reason&#x3a; %s','''','&#x27;'),'(','&#x28;'),')','&#x29;'),'&#x3a;',':')
    FROM [kioskLanguage] AS [kiosk]
    WHERE [kiosk].[klangID] = 2298

  COMMIT TRANSACTION;
END