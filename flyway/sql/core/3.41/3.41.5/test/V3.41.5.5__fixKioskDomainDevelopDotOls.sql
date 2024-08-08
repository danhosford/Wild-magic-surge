UPDATE kiosk
SET kioskSiteURL = 'https://ols.develop/',
kioskSubDomain = 'ols',
kioskOAuthRedirectURI = 'https://ols.develop/index.cfm?section=spLogin&page=login'
WHERE kioskID = 5066;

DROP TABLE IF EXISTS DEMO_TABLE;
GO

DROP TABLE IF EXISTS DEMO_TABLE_2;
GO
