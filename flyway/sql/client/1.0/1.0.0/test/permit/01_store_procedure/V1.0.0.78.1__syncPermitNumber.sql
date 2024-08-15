-- =============================================
-- Author:      Alexandre Tran
-- Create date: 01/02/2019
-- Description: Sync Permit Created with Permit Number for testing
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

CREATE OR ALTER PROCEDURE test.syncPermitNumber (
@KIOSKID INT
,@FORM_TYPE_NAME VARCHAR(255)
,@EXCLUDE_TEMPLATE BIT = 1
,@DEBUG BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;
	INSERT INTO [dbo].[permitCreateNumber](
	[kioskID],[kioskSiteUUID],[ptID]
	,[pcID],[permitPublicKey],[permitNumber]
	,[pcnFreeText],[pcnCountForMonth]
	,[pcnDay],[pcnMonth],[pcnYear]
	,[pcnNumberFormat]
	,[numberOfPermitTypeInPermitBlock]
	)
	SELECT pc.kioskID,pc.kioskSiteUUID,pc.ptID
	,pc.pcID,pc.permitPublicKey,pc.permitNumber
	,pt.ptInitial,1
	,DAY(pc.permitDateOfWorkStart),MONTH(pc.permitDateOfWorkStart),YEAR(pc.permitDateOfWorkStart)
	,'MMMYY-P000-I'
	,1
	FROM [permitCreate] AS pc
	LEFT JOIN permitType AS pt ON pt.ptID = pc.ptID
		AND pt.kioskSiteUUID = pc.kioskSiteUUID
		AND pt.kioskID = pt.kioskID
	LEFT JOIN permitCreateNumber AS pcn ON pcn.permitPublicKey = pc.permitPublicKey
		AND pcn.kioskID = pc.kioskID
		AND pcn.kioskSiteUUID = pc.kioskSiteUUID
		AND pcn.permitNumber = pc.permitNumber
		AND pcn.ptID = pc.ptID
		AND pcn.pcID = pc.pcID
	WHERE pc.isTemplate <> @EXCLUDE_TEMPLATE
		AND pt.name = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
		AND pcn.pcnID IS NULL;
END