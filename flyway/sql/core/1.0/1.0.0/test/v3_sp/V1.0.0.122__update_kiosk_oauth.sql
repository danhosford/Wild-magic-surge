-- =============================================
-- Author:      Alexandre Tran
-- Create date: 26/03/2019
-- Description: Set default oauth URI
-- =============================================

SET NOCOUNT ON;

UPDATE k
SET [k].[kioskOAuthClientID] = 'oauth_test'
,[k].[kioskOAuthClientSecret] = 'oauth_test'
,[k].[kioskOAuthRedirectURI] = CONCAT([kioskSiteURL],'index.cfm?section=spLogin&page=login')
FROM [dbo].[kiosk] AS k
WHERE [k].[kioskOAuthRedirectURI] IS NULL;
