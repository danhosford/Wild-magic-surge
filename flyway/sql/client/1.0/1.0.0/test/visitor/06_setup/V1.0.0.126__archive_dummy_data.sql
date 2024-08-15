-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 18/02/2019
-- Description: #2484 Archive dummy contractor 
-- 11/08/2020 - JC - Archiving dummy data to create automated test against it
-- ==========================================================
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

SET NOCOUNT ON;

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

DECLARE @kioskID INT = [dbo].udf_GetKioskID(db_name());

DECLARE @visitorInfo TABLE (
  [kioskID] INT NOT NULL,
  [kioskSiteUUID] VARCHAR(1000),
  [visitorType] VARCHAR(1000) NOT NULL,
  [active] BIT NOT NULL DEFAULT 1,
  [createDate] DATETIME NOT NULL,
  [createdBy] INT NOT NULL,
  [type] VARCHAR(1000) NOT NULL,
  [firstName] VARCHAR(1000) NOT NULL,
  [lastName] VARCHAR(1000) NOT NULL
);

INSERT INTO @visitorInfo 
VALUES
(0, NULL, 'CP_Contractor', 1, GETUTCDATE(), 0, 'Contractor', 'Archive', 'Contractor' )
;

INSERT INTO [dbo].[visitor]
    ([visitorCompanyID]
    ,[kioskID]
    ,[kioskSiteUUID]
    ,[visitorCreateBy]
    ,[visitorCreateUTC]
    ,[visitorType]
    ,[visitorReferenceID]
    ,[visitorTypeID]
    ,[isActive])
SELECT [workforce].[cpCompanyID]
      ,[visitorInfo].[kioskID]
      ,[visitorInfo].[kioskSiteUUID]
      ,[visitorInfo].[createdBy]
      ,[visitorInfo].[createDate]
      ,[visitorInfo].[visitorType]
      ,[workforce].[cpWorkforceid]
      ,[type].[visitorTypeID]
      ,[visitorInfo].[active]
FROM @visitorInfo AS [visitorInfo]
LEFT JOIN [dbo].[cpWorkforce] AS [workforce]
  ON CONVERT(varchar(255),DecryptByPassphrase(@PASS, [cpWorkforceFirstName])) = [visitorInfo].[firstName]
  AND CONVERT(varchar(255),DecryptByPassphrase(@PASS, [workforce].[cpWorkforceLastName])) = [visitorInfo].[lastName]
LEFT JOIN [dbo].[visitorType] AS [type]
  ON [type].[visitorType] = [visitorInfo].[type]
LEFT JOIN [dbo].[visitor] AS [visitor]
  ON [visitor].[visitorReferenceID] = [workforce].[cpWorkforceid]
WHERE [visitor].[visitorID] IS NULL

INSERT INTO [dbo].[kioskPersonProfile]
    ([kuid]
      ,[contractorID]
      ,[cpWorkforceID]
      ,[visitorID]
      ,[createdBy]
      ,[createUTC])
SELECT 0
      ,0
      ,[workforce].[cpWorkforceid]
      ,[visitor].[visitorID]
      ,[visitorInfo].[createdBy]
      ,[visitorInfo].[createDate]
FROM @visitorInfo AS [visitorInfo]
LEFT JOIN [dbo].[cpWorkforce] AS [workforce]
  ON [workforce].[cpWorkforceFirstName] = [visitorInfo].[firstName]
    AND [workforce].[cpWorkforceLastName] = [visitorInfo].[lastName]
LEFT JOIN [dbo].[visitor] AS [visitor]
  ON [visitor].[visitorReferenceID] = [workforce].[cpWorkforceid]
LEFT JOIN [dbo].[kioskPersonProfile] AS [profile]
  ON [profile].[cpWorkforceID] = [workforce].[cpWorkforceid]
WHERE [profile].[profileID] IS NULL