/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

Create an account based on each group
and add it to first site

You are recommended to back up your database before running this script
Script created by Alex from OLS at 07/11/2018 13:21
*/

SET NOCOUNT ON;
DECLARE @DEBUG BIT = 1;

DECLARE @KIOSKID INT = CONVERT(INT,SUBSTRING(db_name(),5,4));
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

DECLARE @EXCLUDE_PAGES VARCHAR(MAX) = 'isCompanyAdmin';

PRINT 'Attempt enable all features ...';

INSERT INTO [dbo].[kioskAccessControlFeature] (
[kioskID],[kioskSiteUUID]
,[kbcID],[kacfIsActive]
,[kacfCreateBy],[kacfCreateUTC]
)
SELECT @kioskID,ks.kioskSiteUUID
,kbc.kbcID,1
,0,GETUTCDATE()
FROM v3_sp.dbo.kioskBreadcrumb AS kbc
FULL OUTER JOIN kioskSite AS ks ON ks.kioskID = @KIOSKID
	AND ks.kioskSiteUUID IS NOT NULL
LEFT JOIN kioskAccessControlFeature AS kacf ON kacf.kbcID = kbc.kbcID
	AND kacf.kioskSiteUUID = ks.kioskSiteUUID
	AND kacf.kacfIsActive = kbc.kbcIsActive
WHERE kbc.kbcIsActive = 1
	AND kacf.kacfID IS  NULL
	AND kbc.kbcPage NOT IN (SELECT * FROM STRING_SPLIT(@EXCLUDE_PAGES,','))

PRINT 'Enable features successfully!';