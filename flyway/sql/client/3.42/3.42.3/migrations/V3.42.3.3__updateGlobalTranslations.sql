DECLARE @KIOSKID INT = [dbo].udf_GetKioskID(db_name());

UPDATE [language]
SET [language].[kioskuuid] = [kiosk].[kioskUUID]
FROM [v3_sp].[dbo].[kiosk] AS [kiosk]
INNER JOIN [kioskSite] AS [site]
	ON [kiosk].[kioskID] = [site].[kioskID]
	AND [kiosk].[kioskID] = @KIOSKID
INNER JOIN [language].[translations] AS [language]
	ON [language].[kioskSiteUUID] = [site].[kioskSiteUUID]
WHERE [language].[kioskuuid] != [kiosk].[kioskUUID]