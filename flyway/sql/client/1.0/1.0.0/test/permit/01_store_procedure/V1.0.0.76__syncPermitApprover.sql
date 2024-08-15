-- =============================================
-- Author:      Alexandre Tran
-- Create date: 01/02/2019
-- Description: Sync Permit Created with Permit Approver for testing
-- Parameters:
--   @KIOSKID - ID of the kiosk to apply to
--   @FORM_TYPE_NAME - The form type name
--   @EXCLUDE_TEMPLATE - Flag to indicate if template should be included or excluded. Default 1
-- Changelog:
-- 22/08/2020 - AT - Use name instead of ptname
-- =============================================
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.syncPermitApprover (
@KIOSKID INT
,@FORM_TYPE_NAME VARCHAR(255)
,@EXCLUDE_TEMPLATE BIT = 1
,@DEBUG BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;
	-- Get approver -- Hard coded for now since encryption is done at application level
	DECLARE @APPROVER_EMAIL VARCHAR(255) = 'approve.permit@onelooksystems.com';
	DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

	IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
	BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
	END
	
	INSERT INTO [permitCreateApprover] (
	[kioskID],[kioskSiteUUID]
	,[pcID],[permitPublicKey]
	,[paPublicKey],[paApproverIDSelected]
	,[paOrder],[paIsReviewed]
	,[paCreateBy],[paCreateUTC]
	)
	SELECT pc.kioskID,pc.kioskSiteUUID
	,pc.pcID,pc.permitPublicKey
	,ku.kuPublicKey,ku.kuID
	,1,0
	,pc.permitCreateBy,pc.permitCreateUTC
	FROM [permitCreate] AS pc
	LEFT JOIN permitType AS pt ON pt.ptID = pc.ptID
		AND pt.kioskSiteUUID = pc.kioskSiteUUID
		AND pt.kioskID = pt.kioskID
	LEFT JOIN [kioskUser] AS ku ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = @APPROVER_EMAIL
	LEFT JOIN [permitCreateApprover] AS pca ON pca.kioskID = pc.kioskID
		AND pca.kioskSiteUUID = pc.kioskSiteUUID
		AND pca.permitPublicKey = pc.permitPublicKey
	WHERE pc.isTemplate <> @EXCLUDE_TEMPLATE
		AND pt.name = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
		AND pca.pcaID IS NULL;

END