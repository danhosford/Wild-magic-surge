-- ==================================================================
-- Author:      Katy Birkett
-- Create date: 27/06/2022
-- Description: Update Ireland site to have company insurance 
-- ==================================================================

SET NOCOUNT ON;

PRINT 'Update Ireland Insurance'

UPDATE [cpCompanyAdminGroupSetting]
SET [cacigID] = 2 /* insurance */
WHERE [kioskSiteUUID] = '6BDE601C-3317-4643-A386-2954638AFC37'
AND [cagsIsActive] = 1

PRINT 'Ireland insurance updated!'

SET NOCOUNT OFF;