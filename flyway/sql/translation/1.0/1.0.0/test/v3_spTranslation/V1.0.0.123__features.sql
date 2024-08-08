/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 13/12/2018 23:50

- Update test instance with translation
*/
DECLARE @DEBUG BIT = 1;

SET NOCOUNT ON;

PRINT 'Attempt update translation ...';
SET IDENTITY_INSERT dbo.kioskLanguage ON;
INSERT INTO kioskLanguage (
	klangID,klangUUID,klangIsActive
	,kbcSection,kbcPage,en_IE
)
SELECT MIN(kbc.klangID),NEWID(),1
,kbc.kbcSection,MAX(kbc.kbcPage),MAX(kbc.kbcTitle)
FROM (SELECT DISTINCT kbc.klangID
FROM v3_sp.dbo.kioskBreadcrumb AS kbc
LEFT JOIN dbo.kioskLanguage AS kl ON kl.klangID = kbc.klangID
WHERE kl.klangID IS NULL
	AND kbc.klangID IS NOT NULL
	AND kbc.klangID <> 0
	AND kbc.kbcTitle IS NOT NULL
	AND TRIM(kbc.kbcTitle) <> '') AS ids
LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kbc ON kbc.klangID = ids.klangID
GROUP BY kbc.kbcSection

SET IDENTITY_INSERT dbo.kioskLanguage OFF;
PRINT 'Translation updated successfully!';
SET NOCOUNT OFF;