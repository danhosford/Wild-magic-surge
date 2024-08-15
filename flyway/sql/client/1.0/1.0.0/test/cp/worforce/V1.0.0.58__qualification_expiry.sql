-- =======================================================
-- Author:      Katy Birkett
-- Create date: 25/11/2021
-- Description: Update Qualification Expiry
-- =======================================================

SET NOCOUNT ON;

GO
BEGIN

DECLARE @NOEXPIRY INT = 0;
DECLARE @EXPIRY INT = 1;
DECLARE @EXPIRYDAYS INT = 365;

PRINT 'Attempt to set qualification expiry...';

UPDATE [dbo].[contractorQualificationType]
SET [cqtValidity] = @NOEXPIRY
WHERE [cqtName] like '%Ireland%';

UPDATE [dbo].[contractorQualificationType]
SET [cqtValidity] = @EXPIRY
,[cqtValidityDays] = @EXPIRYDAYS
WHERE [cqtName] like '%Tatooine%';

PRINT 'Job ran successfully!';

END