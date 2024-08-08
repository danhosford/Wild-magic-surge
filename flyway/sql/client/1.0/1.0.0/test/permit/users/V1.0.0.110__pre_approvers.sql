-- =============================================
-- Author:     Jamie Conroy
-- Create date: 04/01/2022
-- Description: Script to set up pre approver list
-- Parameters:
-- CHANGELOG:
-- =============================================

DECLARE @DEBUG BIT = 1;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';
SET NOCOUNT ON;

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

IF OBJECT_ID('tempdb..#PREAPPROVERLIST') IS NOT NULL DROP TABLE #PREAPPROVERLIST;

CREATE TABLE #PREAPPROVERLIST (
	email VARCHAR(255)
	,active BIT NOT NULL DEFAULT 1
);

INSERT INTO #PREAPPROVERLIST (email)
VALUES ('test.sysadmin@onelooksystems.com')
        ,('workflow.controller@onelooksystems.com')
;

INSERT INTO [permitDropDownPreApprover] (
[kioskID],[kioskSiteUUID]
,[kuID],[pddpaIsActive],[pfID]
,[pddpaCreateBy],[pddpaCreateUTC]      
)
SELECT @KIOSKID,ks.kioskSiteUUID
,ku.kuid,al.active,pf.pfID
,0,GETUTCDATE()
FROM #PREAPPROVERLIST AS al
LEFT JOIN kioskUser AS ku ON CONVERT(VARCHAR(255), DECRYPTBYPASSPHRASE(@PASS,ku.kuemailN)) = al.email
FULL OUTER JOIN kioskSite AS ks ON ks.kioskID = @KIOSKID
	AND ks.kioskSiteUUID IS NOT NULL
FULL OUTER JOIN permitType AS pt ON pt.kioskID = @KIOSKID
	AND pt.ptID IS NOT NULL
LEFT JOIN permitField AS pf ON pf.ptID = pt.ptID
	AND pf.pfFieldType = 'preApprover'
LEFT JOIN permitDropDownPreApprover AS pddpa ON pddpa.kioskID = @KIOSKID
	AND pddpa.kioskSiteUUID = ks.kioskSiteUUID
	AND pddpa.kuID = ku.kuID
	AND pddpa.pddpaIsActive = al.active
	AND pddpa.pfID = pf.pfID
WHERE pddpa.pddpa IS NULL;

IF OBJECT_ID('tempdb..#PREAPPROVERLIST') IS NOT NULL DROP TABLE #PREAPPROVERLIST;