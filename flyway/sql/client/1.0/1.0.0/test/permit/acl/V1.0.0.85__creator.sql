DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

SET NOCOUNT ON;

-- Permit Approver list name
DECLARE @GROUPNAMES test.GroupNames;
-- Table to hold features required for permit approver
DECLARE @PERMIT_CREATOR_FEATURES test.GroupFeatures;
INSERT INTO @GROUPNAMES (name)
VALUES ('Create Permit')
,('Create Permit - Contractor')
,('Permit Super Admin');

INSERT INTO @PERMIT_CREATOR_FEATURES (section,page,appPrefix)
VALUES ('permitCreate','permitCreate','permit')
,('permitCreate','permitCreateProcess','permit')
,('permitCreate','permitSelect','permit')
,('permitCreateSubmit','permitSubmit','permit')
,('kiosk','kioskHome','permit')
,('permitCreate','savedTemplates','permit')
,('document','archivedDocument','permit')
,('document','documentAdd','permit')
,('document','documentHome','permit')
,('document','documentList','permit')
,('document','documentListApproved','permit')
,('document','documentReview','permit')
,('document','documentView','permit')
,('document','documentViewApproved','permit')
,('configureLocation','saveLocationOrder','permit')
,('configurePermitType','savePermitTypeOrder','permit');

EXEC [test].[setFeatureACL] 
@KIOSKID = @KIOSKID
,@groupname = @GROUPNAMES
,@featureslist = @PERMIT_CREATOR_FEATURES;

PRINT 'Attempt to provide access to permit creation to group...';
INSERT INTO [permitAclMultipleGroupSetting](
[kioskID],[kioskSiteUUID],[kacgID]
,[permitAclMultipleGroupSettingIsActive]
,[permitAclMultipleGroupSettingAddedBy],[permitAclMultipleGroupSettingAddedUTC])
SELECT kacg.kioskID,kacg.kioskSiteUUID,kacg.kacgID
,1
,0,GETUTCDATE()
FROM @GROUPNAMES AS g
LEFT JOIN kioskAccessControlGroup AS kacg ON UPPER(kacg.kacgName) = UPPER(g.name)
LEFT JOIN permitAclMultipleGroupSetting AS pamgs ON pamgs.kioskID = kacg.kioskID
	AND pamgs.kioskSiteUUID = kacg.kioskSiteUUID
	AND pamgs.kacgID = kacg.kacgID
	AND pamgs.permitAclMultipleGroupSettingIsActive = 1
WHERE pamgs.permitAclMultipleGroupSettingID IS NULL
	AND kacg.kioskID = @KIOSKID;

           
           
INSERT INTO [permitTypeACL](
[kioskID],[kioskSiteUUID]
,[ptID],[ptACLGrantAccessToKUID]
,[ptACLIsActive]
,[ptACLCreateBy],[ptACLCreateUTC]
)
SELECT DISTINCT kuacg.kioskID, kuacg.kioskSiteUUID
,pt.ptID,kuacg.kuID
,1
,0,GETUTCDATE()
FROM kioskUserAccessControlGroupMembership AS kuacg
LEFT JOIN kioskAccessControlGroup AS kacg ON kacg.kacgID = kuacg.kacgID
INNER JOIN @GROUPNAMES AS g ON UPPER(g.name) = UPPER(kacg.kacgName)
FULL OUTER JOIN permitType AS pt ON pt.kioskID = kuacg.kioskID
	AND pt.kioskSiteUUID = kuacg.kioskSiteUUID
LEFT JOIN permitTypeACL AS pta ON pta.kioskID = kuacg.kioskID
	AND pta.kioskSiteUUID = kuacg.kioskSiteUUID
	AND pta.ptID = pt.ptID
	AND pta.ptACLGrantAccessToKUID = kuacg.kuID
WHERE kuacg.kioskID = @KIOSKID
	AND pta.ptACLID IS NULL;

PRINT 'Permission to create permit to group added successfully!';