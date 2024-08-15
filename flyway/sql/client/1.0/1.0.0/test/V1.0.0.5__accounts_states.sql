SET NOCOUNT ON;
PRINT 'Clearing ban history...';

DELETE FROM [v3_spLoginAudit].[dbo].kioskSecurityEvent
WHERE kseUTC >= CAST(CURRENT_TIMESTAMP AS DATE)
AND kseUTC < DATEADD(DD, 1, CAST(CURRENT_TIMESTAMP AS DATE))

DELETE FROM [v3_spLoginAudit].[dbo].kioskLoginFailure
WHERE klfLoginUTC >= CAST(CURRENT_TIMESTAMP AS DATE)
AND klfLoginUTC < DATEADD(DD, 1, CAST(CURRENT_TIMESTAMP AS DATE))

DELETE FROM [v3_spLoginAudit].[dbo].kioskBannedIP
WHERE kbCreateUTC >= CAST(CURRENT_TIMESTAMP AS DATE)
AND kbCreateUTC < DATEADD(DD, 1, CAST(CURRENT_TIMESTAMP AS DATE))

PRINT 'Ban history cleared!';

PRINT 'Unlock account locked...';
UPDATE kioskUser
SET kuIsAccountLocked = 0
WHERE kuIsAccountLocked = 1;
PRINT 'Account unlocked!';

PRINT 'Updating each user create date to today';
UPDATE kioskUser
SET kuCreateUTC = CAST(CURRENT_TIMESTAMP AS DATE)
PRINT 'User creates dates updated';
SET NOCOUNT OFF;