-- ================================================================================
-- Author:      Shane Gibbons
-- Create date: 16/04/2021
-- Description: This script grants users access to different types of permits for testing purposes
-- CHANGELOG:
-- ================================================================================

SET NOCOUNT ON;

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

DECLARE @count INT = 0;
DECLARE @batchSize INT = 50;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

PRINT 'Create acls variable table...';

DECLARE @acls TABLE (
    [ptName] VARCHAR(255) NOT NULL
    ,[kioskID] INT NOT NULL
    ,[ptaclIsActive] BIT NOT NULL DEFAULT 1
    ,[userEmail] VARCHAR(255) NOT NULL
    ,[ptaclCreateBy] INT NOT NULL
    ,[ptaclCreateUTC] datetime NOT NULL DEFAULT GETUTCDATE()
);

PRINT 'Insert Into acls table...';

INSERT INTO @acls([ptName],[kioskID],[ptaclIsActive],[userEmail],[ptaclCreateBy])
VALUES
('Extendable', @KIOSKID, 1, 'test.contractor@onelooksystems.com', 1)
;

PRINT 'Attempt to Update users permit access';

Set @results = 1;
WHILE (@results > 0)
BEGIN

    SET @starttime = GETUTCDATE();

	INSERT INTO [dbo].[permitTypeACL](
		[ptID]
		,[kioskID]
		,[ptaclIsActive]
		,[ptaclGrantAccessToKUID]
		,[ptaclCreateUTC]
		,[ptaclCreateBy]
		,[kioskSiteUUID]
	) SELECT TOP(@batchSize) 
		[type].[ptID]
		,[acl].[kioskID]
		,[acl].[ptaclIsActive]
		,[user].[kuID]
		,[acl].[ptaclCreateUTC]
		,[acl].[ptaclCreateBy]
		,[site].[kioskSiteUUID]
	FROM @acls AS [acl]
    INNER JOIN [dbo].[kioskSite] AS [site]
		ON [site].[kioskID] = [acl].[kioskID]
	INNER JOIN [dbo].[permitType] AS [type]
		ON [type].[ptName] = [acl].[ptName]
		AND [type].[kioskID] = [acl].[kioskID]
		AND [type].[kioskSiteUUID] = [site].[kioskSiteUUID]
		AND [type].[ptIsActive] = 1
	INNER JOIN [dbo].[kioskUser] AS [user]
		ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,[user].[kuEmailN])) = [acl].[userEmail]
		AND [user].[kioskID] = [acl].[kioskID]
		AND [user].[kuIsActive] = 1
	LEFT JOIN [dbo].[permitTypeACL] AS [history]
        ON [history].[ptID] = [type].[ptID]
	    AND [history].[kioskID] = [acl].[kioskID]
	    AND [history].[kioskSiteUUID] = [site].[kioskSiteUUID]
        AND [history].[ptaclIsActive] = [acl].[ptaclIsActive]
		AND [history].[ptACLGrantAccessToKUID] = [user].[kuID]
	WHERE [history].[ptACLID] IS NULL;


	--Get rowcount to avoid infinite loop
    SET @results = @@ROWCOUNT
    SET @count = @count + @results;
    SET @endtime = GETUTCDATE();
    SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
    RAISERROR('Updating users permit access: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

END

PRINT 'Users permit access updated successfully!';

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @startScriptTime, @endScriptTime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;
