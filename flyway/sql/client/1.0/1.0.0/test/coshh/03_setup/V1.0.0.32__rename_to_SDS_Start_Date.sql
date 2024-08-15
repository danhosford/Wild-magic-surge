-- =================================================================
-- Author:      Chaitanya Kulkarni
-- Create date: 03/02/2022
-- Description:
-- * This script will ensure that SDS Expiry date is renamed to SDS Start Date.
-- 15/02/2022 - JC - Tidy up the script and removing uneccessary code
-- =================================================================
SET NOCOUNT ON;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

UPDATE [dbo].[formField]
SET [formFieldType] = 'coshhSDSStart'
WHERE [formFieldName] = 'SDS Expiry date'
AND [kioskID] = @KIOSKID

UPDATE [dbo].[formField]
SET [formFieldName] = 'SDS Start Date'
WHERE [formFieldName] = 'SDS Expiry date'
AND [kioskID] = @KIOSKID

UPDATE [language].[translations]
SET [text] = 'SDS Start Date'
where [text] = 'SDS Expiry date'
