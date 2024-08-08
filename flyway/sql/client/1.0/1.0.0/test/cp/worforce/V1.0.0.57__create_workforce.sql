-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 11/05/2020
-- Description: Create workforce, workforce activation log and workforce site entries
-- 10/09/2020 - BOL - Added 3 new users to company "Death Star"
-- 11/09/2020 - BOL - Added workforce for every site to cater for permit submission iDo test
-- 12/08/2020 - JC - Addition of dummy contractors to test fix for #2484
-- 27/11/2020 - JC - Addition of workforce for general permit workflow #3030
-- 27/11/2020 - JC - Addition of dummy contractos for signature inc for use in the signature permit #3030
-- 30/11/2020 - AT - Include SHORT contractor for testing
-- ==========================================================
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

SET NOCOUNT ON;

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

PRINT 'Create a temp table for workforce...';

DECLARE @workforce TABLE (
  [firstName] VARCHAR(1000) NOT NULL,
  [lastName] VARCHAR(1000) NOT NULL,
  [emailAddress] VARCHAR(1000) NOT NULL,
  [company] VARCHAR(1000) NOT NULL,
  [companySite] VARCHAR(1000) NOT NULL,
  [active] BIT NOT NULL DEFAULT 1,
  [createDate] DATETIME NOT NULL,
  [createdBy] INT NOT NULL,
  [subContractor] BIT NOT NULL DEFAULT 0,
  [hasAccount] BIT NOT NULL DEFAULT 0
);

PRINT 'Insert values into the workforce temp table...';

INSERT INTO @workforce 
VALUES
('Extension', 'Permit', 'extensionworkforce@onelooksystems.com','Onelook Systems', 'Ireland', 1, GETUTCDATE(), 0, 0, 0)
,('Obi', 'Wan', 'obi.wan@onelooksystems.com','Messy Ltd', 'Israel', 1, GETUTCDATE(), 0, 0, 0)
,('Archive', 'Contractor', 'archivecontractor1@onelooksystems.com','Onelook Systems', 'Ireland', 1, GETUTCDATE(), 0, 0, 0)
,('Irish', 'Contractor', 'irish.contractor@onelooksystems.com','Death Star', 'Ireland', 1, GETUTCDATE(), 0, 0, 0)
,('Israel', 'Worker', 'israel.contractor@onelooksystems.com','Death Star', 'Israel', 1, GETUTCDATE(), 0, 0, 0)
,('Irish', 'Contractor', 'irish.contractor@onelooksystems.com','Death Star', 'Ireland', 1, GETUTCDATE(), 0, 0, 0)
,('Israel', 'Worker', 'israel.contractor@onelooksystems.com','Death Star', 'Israel', 1, GETUTCDATE(), 0, 0, 0)
,('US', 'Contractor', 'us.contractor@onelooksystems.com','Death Star', 'US Central', 1, GETUTCDATE(), 0, 0, 0)
,('Brazil', 'Contractor', 'brazilian.contractor@onelooksystems.com','Death Star', 'Brazil', 1, GETUTCDATE(), 0, 0, 0)
,('France', 'Contractor', 'french.contractor@onelooksystems.com','Death Star', 'France', 1, GETUTCDATE(), 0, 0, 0)
,('Germany', 'Contractor', 'german.contractor@onelooksystems.com','Death Star', 'Germany', 1, GETUTCDATE(), 0, 0, 0)
,('Icelandic', 'Contractor', 'Icelandic.contractor@onelooksystems.com','Death Star', 'Icelandic', 1, GETUTCDATE(), 0, 0, 0)
,('Italy', 'Contractor', 'italian.contractor@onelooksystems.com','Death Star', 'Italy', 1, GETUTCDATE(), 0, 0, 0)
,('Short', 'Contractor', 'short.contractor@onelooksystems.com','SHORT Company', 'SHORT', 1, GETUTCDATE(), 0, 0, 0)
,('Spain', 'Contractor', 'spanish.contractor@onelooksystems.com','Death Star', 'Spain', 1, GETUTCDATE(), 0, 0, 0)
,('Switzerland', 'Contractor', 'swiss.contractor@onelooksystems.com','Death Star', 'Switzerland', 1, GETUTCDATE(), 0, 0, 0)
,('Tatooine', 'Contractor', 'tatooine.contractor@onelooksystems.com','Death Star', 'Tatooine', 1, GETUTCDATE(), 0, 0, 0)
,('Translations', 'Contractor', 'translations.contractor@onelooksystems.com','Death Star', 'Translations', 1, GETUTCDATE(), 0, 0, 0)
,('General', 'Contractor', 'general.contractor@onelooksystems.com','General Inc', 'Ireland', 1, GETUTCDATE(), 0, 0, 0)
,('Team', 'Leader', 'team.leader@onelooksystems.com','Signature Inc', 'Ireland', 1, GETUTCDATE(), 0, 0, 0)
,('Private', 'Blue', 'private.blue@onelooksystems.com','Signature Inc', 'Ireland', 1, GETUTCDATE(), 0, 0, 0)
;

PRINT 'Insert values into the cpWorkforce table...';

INSERT INTO [dbo].[cpWorkforce] 
        ([kioskID],
        [kioskSiteUUID],
        [cpCompanyID],
        [cpWorkforcePublicKey],
        [cpWorkforceFirstName],
        [cpWorkforceLastName],
        [cpWorkforceContactEmailAddress],
        [company],
        [cpWorkforceCreateUTC],
        [cpWorkforceCreateBy],
        [cpWorkforceIsActive],
        [uuid],
        [cpWorkforceIsSubcontractor],
        [cpWorkforceHasAccount])
SELECT  @KIOSKID,
        [site].[kioskSiteUUID],
        [company].[cpCompanyID],
        NEWID(),
        ENCRYPTBYPASSPHRASE(@PASS,[workforce].[firstName]),
        ENCRYPTBYPASSPHRASE(@PASS,[workforce].[lastName]),
        ENCRYPTBYPASSPHRASE(@PASS,[workforce].[emailAddress]),
        ENCRYPTBYPASSPHRASE(@PASS,[workforce].[company]),
        [workforce].[createDate],
        [workforce].[createdBy],
        [workforce].[active],
        NEWID(),
        [workforce].[subContractor],
        [workforce].[hasAccount]
FROM    @workforce AS [workforce]
INNER JOIN [dbo].[kioskSite] AS [site]
  ON  [site].[kioskSiteName] = [workforce].[companySite]
  AND [site].[kioskID] = @KIOSKID
INNER JOIN [dbo].[cpCompany] AS [company]
  ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,cpCompanyName)) = [workforce].[company]
  AND [company].[kioskID] = @KIOSKID
LEFT JOIN [dbo].[cpWorkforce] AS [cpWorkforce]
  ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[cpWorkforce].[cpWorkforceContactEmailAddress])) = [workforce].[emailAddress]
WHERE CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[cpWorkforce].[cpWorkforceContactEmailAddress])) IS NULL

PRINT 'Insert values into the cpWorkforceActivationLog table...'


INSERT INTO [dbo].[cpWorkforceActivationLog] 
        ([kioskID],
        [kioskSiteUUID],
        [cpWorkforceID],
        [cpWorkforceActivationLogCreateBy],
        [cpWorkforceActivationLogCreateUTC],
        [cpWorkforceActivationLogIsActive])
SELECT  @KIOSKID,
        [site].[kioskSiteUUID],
        [cpWorkforce].[cpWorkforceID],
        [workforce].[createdBy],
        [workforce].[createDate],
        [workforce].[active]
FROM    @Workforce as [workforce]
INNER JOIN [dbo].[kioskSite] AS [site]
  ON  [site].[kioskSiteName] = [workforce].[companySite]
  AND [site].[kioskID] = @KIOSKID
INNER JOIN [cpWorkforce] AS [cpWorkforce]
  ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[cpWorkforce].[cpWorkforceContactEmailAddress])) = [workforce].[emailAddress]
LEFT JOIN [cpWorkforceActivationLog] AS [cpWorkforceActivationLog]
  ON [cpWorkforceActivationLog].[cpWorkforceID] = [cpWorkforce].[cpWorkforceID]
WHERE [cpWorkforceActivationLog].[cpWorkforceID] IS NULL

PRINT 'Insert values into the cpWorkforceSites table...'

INSERT INTO [dbo].[cpWorkforceSites]
        ([cpWorkforceID],
        [kioskSiteID],
        [cpWorkforceSiteAddedBy],
        [cpWorkforceSiteAddedUTC],
        [kioskID],
        [kioskSiteUUID],
        [cpWorkforceSiteActive]) 
SELECT  [cpWorkforce].[cpWorkforceID],
        [site].[kioskSiteID],
        [workforce].[createdBy],
        [workforce].[createDate],
        @KIOSKID,
        [site].[kioskSiteUUID],
        [workforce].[active]
FROM    @Workforce as [workforce]
INNER JOIN [dbo].[kioskSite] AS [site]
  ON  [site].[kioskSiteName] = [workforce].[companySite]
  AND [site].[kioskID] = @KIOSKID
INNER JOIN [cpWorkforce] AS [cpWorkforce]
  ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[cpWorkforce].[cpWorkforceContactEmailAddress])) = [workforce].[emailAddress]
LEFT JOIN [cpWorkforceSites] AS [cpWorkforceSites]
  ON [cpWorkforceSites].[cpWorkforceID] = [cpWorkforce].[cpWorkforceID]
WHERE [cpWorkforceSites].[cpWorkforceID] IS NULL
