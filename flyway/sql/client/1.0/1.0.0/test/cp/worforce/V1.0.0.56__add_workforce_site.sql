-- ================================================================================
-- Author:      Jamie Conroy
-- Create date: 15/09/202021
-- Description: Put c1.protakecareofitagainltd@onelooksystems.com onto the Irish site
-- ================================================================================

DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

INSERT INTO [cpWorkforceSites] (
    [cpWorkforceID]
    ,[kioskSiteID]
    ,[cpWorkforceSiteAddedBy]
    ,[cpWorkforceSiteAddedUTC]
    ,[kioskID]
    ,[kioskSiteUUID]
    ,[cpWorkforceSiteActive])
VALUES(
    4,
    1,
    0,
    GETUTCDATE(),
    @KIOSKID,
    '6BDE601C-3317-4643-A386-2954638AFC37',
    1)

INSERT INTO kioskUserAccessControlGroupMembership 
    (kioskID,
     kacgID, 
     kuacgmCreateBy, 
     kuacgmCreateUTC, 
     kuacgmIsActive, 
     kuID, 
     kioskSiteUUID )
 VALUES (dbo.udf_GetKioskID(db_name()),
        4,
        0,
        getutcdate(),
        1,
        91,
        '6BDE601C-3317-4643-A386-2954638AFC37')

SET NOCOUNT OFF;