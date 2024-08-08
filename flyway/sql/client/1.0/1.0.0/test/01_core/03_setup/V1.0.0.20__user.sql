-- ===========================================================
-- Author:      Alexandre Tran
-- Create date: 26/03/2019
-- Description: Add user to kiosk
-- CHANGELOG:
-- 15/09/2020 - AT - Insert first & last name in new column
-- ===========================================================

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';
DECLARE @counter INT = 0;
DECLARE @salt VARCHAR(255) = CONVERT(VARCHAR(40),HASHBYTES('SHA1',convert(varchar(50), NEWID())),2)

DECLARE @Users TABLE (
  kioskid INT,
  firstname VARCHAR(255),
  lastname VARCHAR(255),
  email VARCHAR(255),
  telephone VARCHAR(255),
  jobtitle VARCHAR(255),
  isSuperuser BIT,
  isEmployee BIT,
  isActive BIT,
  isLocked BIT
);

INSERT INTO @Users 
(
  kioskid,
  firstname,
  lastname,
  email,
  telephone,
  jobtitle,
  isSuperuser,
  isEmployee,
  isActive,
  isLocked 
)
VALUES 
(@KIOSKID,'nosite','tester','nosite.tester@onelooksystems.com','5555-5555','tester',0,1,1,0)
,(@KIOSKID,'deactivate','tester','deactivate.tester@onelooksystems.com','5555-5555','tester',0,1,0,0)
,(@KIOSKID,'EHS','manager','ehs.manager@onelooksystems.com','5555-5555','tester',0,1,1,0);


PRINT 'Creating a password and salt ...';

DECLARE @passwordhash VARCHAR(255) = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT('@1LookSystems',@salt)),2);
WHILE @counter < 999
BEGIN
  SET @passwordhash = CONVERT(VARCHAR(128),HASHBYTES('SHA2_512',CONCAT(@passwordhash,@salt)),2);
  SET @counter = @counter +1;
END

PRINT 'Password and Salt created!';

-- Create dummy account for oauth testing - Gitlab bug #599
-- This account doesn't require any site access

PRINT 'Attempt create dummy user...';
INSERT INTO [dbo].[kioskUser](
  [kioskID]
  ,[kuFirstNameN],[kuLastNameN]
  ,[firstname],[lastname]
  ,[kuEmailN]
  ,[kuTelephoneN],[kuJobTitleN]
  ,[kuPublicKey],[kuPrivateKey]
  ,[kuPasswordHash],[kuPasswordSalt]
  ,[kuIsSuperuser],[kuIsEmployeeOrExternalContractor],[kuIsActive]
  ,[kuCreateBy],[kuCreateUTC]
  ,[kuIsAccountLocked],[cpCompanyID]
)
SELECT 
[user].[kioskid]
,ENCRYPTBYPASSPHRASE(@PASS,[user].[firstname]),ENCRYPTBYPASSPHRASE(@PASS,[user].[lastname])
,ENCRYPTBYPASSPHRASE(@PASS,CAST([user].[firstname] AS NVARCHAR(255))),ENCRYPTBYPASSPHRASE(@PASS,CAST([user].[lastname] AS NVARCHAR(255)))
,ENCRYPTBYPASSPHRASE(@PASS,[user].[email])
,ENCRYPTBYPASSPHRASE(@PASS,[user].[telephone]),ENCRYPTBYPASSPHRASE(@PASS,[user].[jobtitle])
,NEWID(),NEWID()
,@passwordhash,@salt
,[user].[isSuperuser],IIF([user].[isEmployee] = 1,'Employee','Contractor'),[user].[isActive]
,0,GETUTCDATE()
,[user].[isLocked],0
FROM @Users AS [user]
LEFT JOIN [dbo].[kioskUser] AS [existing]
  ON [existing].[kioskid] = [user].[kioskid]
  AND CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[existing].[kuEmailN])) = [user].[email]
WHERE [existing].[kuid] IS NULL;

PRINT 'Dummy user created successfully!';