-- ==================================================================
-- Author:      Shane Gibbons
-- Create date: 07/04/2021
-- Description: Update contractor user with a company 
-- ==================================================================

SET NOCOUNT ON;

PRINT 'Update test.contractor account'

UPDATE kioskUser
SET cpCompanyID = 1
WHERE kuID = 20;

PRINT 'test.contractor account updated!'

SET NOCOUNT OFF;