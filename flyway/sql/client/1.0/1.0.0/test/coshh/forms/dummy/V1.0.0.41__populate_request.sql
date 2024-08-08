/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 26/01/2018 10:31
- Populate COSHH Product
*/

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @FORM_TYPE_NAME VARCHAR(255) = 'Request Product';
DECLARE @TOTAL_COSHH_TO_CREATE INT = 10;
DECLARE @REQUESTER_EMAIL VARCHAR(255) = 'coshh.requester@onelooksystems.com';
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#FIELDVALUES') IS NOT NULL DROP TABLE #FIELDVALUES;

CREATE TABLE #FIELDVALUES (
	fieldtype VARCHAR(255) NOT NULL,
	fieldValue VARCHAR(255) NOT NULL
);

INSERT INTO #FIELDVALUES
VALUES('textline','(8<NY,W-=N+@ ');


DECLARE @cnt INT = 0;
DECLARE @CURRENTCOUNT INT;


IF(@CURRENTCOUNT = 0)
BEGIN
SET @CURRENTCOUNT = 1;
END

IF (@CURRENTCOUNT < @TOTAL_COSHH_TO_CREATE)
BEGIN

	PRINT 'Attempt to complete COSHH Request ...';

	WHILE @cnt <= @TOTAL_COSHH_TO_CREATE
	BEGIN

        
        INSERT INTO [dbo].[formCreate](
            [kioskID],[kioskSiteUUID],[version]
            ,[formNumber],[formStatus]
            ,[formCreatePublicKey]
            ,[formCreateBy],[formCreateUTC]
            ,[formTypeID]
            ,[unfinished]
            ,[formDescription]
        )
        SELECT 
            @KIOSKID,ks.kioskSiteUUID,1
            ,'COSHH-Test-' + @cnt, 1
            ,NEWID()
            ,ku.kuID,GETUTCDATE()
            ,ft.formTypeID
            ,0
            ,'Auto Generated'
		FROM kioskSite AS ks
		LEFT JOIN [kioskUser] AS ku ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = @REQUESTER_EMAIL
		LEFT JOIN formType AS ft ON ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
			AND ft.kioskSiteUUID = ks.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
			AND ft.kioskID = @KIOSKID
		SET @cnt +=1;
	END

	PRINT 'Total COSHH request created: ' + CAST(@cnt AS VARCHAR(255));

END
SET NOCOUNT OFF;


PRINT 'Attempt populate page for form created ...';

INSERT INTO [formCreateFieldPage] (
	[kioskID],[kioskSiteUUID]
	,[fcfpCreateBy],[fcfpCreateUTC]
    ,[formCreatePublicKey],[formTypePublicKey]
    ,[formPageID],[formPageName]
    ,[formPageOrder],[formPageIsActive],[version]
    ,[formPageCreateBy],[formPageCreateUTC]
)
SELECT fc.kioskID,fc.kioskSiteUUID
,fc.[formCreateBy],fc.[formCreateUTC]
,fc.[formCreatePublicKey],ft.formTypePublicKey
,fp.formPageID,fp.formPageName
,fp.formPageOrder,fp.formPageIsActive,1
,fc.[formCreateBy],fc.[formCreateUTC]
FROM [formCreate] AS fc
LEFT JOIN formType AS ft ON ft.formTypeID = fc.formTypeID
	AND ft.kioskSiteUUID = fc.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
	AND ft.kioskID = @KIOSKID
LEFT JOIN formPage AS fp ON fp.formTypeID = ft.formTypeID
LEFT JOIN formCreateFieldPage AS fcfp ON fcfp.kioskID = fc.kioskID
	AND fcfp.kioskSiteUUID = fc.kioskSiteUUID
	AND fcfp.fcfpCreateBy = fc.[formCreateBy]
	AND fcfp.fcfpCreateUTC = fc.[formCreateUTC]
	AND fcfp.formCreatePublicKey = fc.[formCreatePublicKey]
	AND fcfp.formTypePublicKey = ft.formTypePublicKey
	AND fcfp.formPageID =fp.formPageID
	AND fcfp.[formPageName] = fp.formPageName
	AND fcfp.[formPageOrder] = fp.formPageOrder
	AND fcfp.version = 1
	AND fcfp.[formPageCreateBy] = fc.[formCreateBy]
	AND fcfp.[formPageCreateUTC] = fc.[formCreateUTC]
WHERE ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
 AND fcfp.[fcfpID] IS NULL;

PRINT 'Page added successfully!';

PRINT 'Attempt populate field question for forms  created ...';

INSERT INTO [formCreateFieldQuestion] (
      [fcID],[kioskID],[kioskSiteUUID]
	  ,[fcfqCreateBy],[fcfqCreateUTC]
      ,[formFieldClass],[formFieldType],[formFieldID]
      ,[formPageID],[formFieldIsMandatory],[formFieldNarrative]
      ,[formTypeID]
      ,[formFieldOrder],[formFieldParam],[formFieldSelectValue],[formFieldSelectValueMandatory]
      ,[version])
SELECT fc.fcID,fc.kioskID,fc.kioskSiteUUID
,fc.[formCreateBy],fc.[formCreateUTC]
,ff.[formFieldClass],ff.[formFieldType],ff.[formFieldID]
,ff.[formFieldPageID],ff.[formFieldIsMandatory],ff.[formFieldName]
,fc.[formTypeID]
,ff.[formFieldOrder],ff.[formFieldParam1],ff.[formFieldSelectValue],ff.[formFieldSelectValueMandatory]
,fc.version
FROM [formCreate] AS fc
LEFT JOIN formType AS ft ON ft.formTypeID = fc.formTypeID
	AND ft.kioskSiteUUID = fc.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
	AND ft.kioskID = @KIOSKID
LEFT JOIN formField AS ff ON ff.formTypeID = ft.formTypeID
LEFT JOIN formCreateFieldQuestion AS ffq ON ffq.fcID = fc.fcID
	AND ffq.kioskID = fc.kioskID
	AND ffq.kioskSiteUUID = fc.kioskSiteUUID
	AND ffq.fcfqCreateBy = fc.[formCreateBy]
	AND ffq.fcfqCreateUTC = fc.[formCreateUTC]
	AND ffq.[formFieldType] = ff.[formFieldType]
	AND ffq.[formFieldID] = ff.[formFieldID]
	AND ffq.formPageID = ff.[formFieldPageID]
	AND ffq.formFieldNarrative = ff.[formFieldName]
	AND ffq.[formTypeID] = fc.[formTypeID]
	AND ffq.version = fc.version
WHERE ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
	AND ffq.[fcfqID] IS NULL

PRINT 'Field questions added successfully!';

INSERT INTO [formCreateFieldValue] (
[kioskID],[kioskSiteUUID]
,[formFieldID],[fvValue]
,[fcfvCreateBy],[fcfvCreateUTC]
,[formCreatePublicKey],[version])
SELECT fc.kioskID,fc.kioskSiteUUID
,ffq.[formFieldID],fv.fieldValue
,fc.[formCreateBy],fc.[formCreateUTC]
,fc.[formCreatePublicKey],fc.version
FROM [formCreate] AS fc
LEFT JOIN formType AS ft ON ft.formTypeID = fc.formTypeID
	AND ft.kioskSiteUUID = fc.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
	AND ft.kioskID = @KIOSKID
LEFT JOIN formCreateFieldQuestion AS ffq ON ffq.fcID = fc.fcID
	AND ffq.kioskID = fc.kioskID
	AND ffq.kioskSiteUUID = fc.kioskSiteUUID
	AND ffq.fcfqCreateBy = fc.[formCreateBy]
	AND ffq.fcfqCreateUTC = fc.[formCreateUTC]
	AND ffq.[formTypeID] = fc.[formTypeID]
LEFT JOIN #FIELDVALUES AS fv ON fv.fieldType = ffq.[formFieldType] COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN formCreateFieldValue AS fcfv ON fcfv.kioskID = fc.kioskID
	AND fcfv.kioskSiteUUID = fc.kioskSiteUUID
	AND fcfv.[formFieldID] = ffq.[formFieldID]
	AND fcfv.fcfvCreateBy = fc.[formCreateBy]
	AND fcfv.fcfvCreateUTC = fc.[formCreateUTC]
	AND fcfv.[formCreatePublicKey] = fc.[formCreatePublicKey]
	AND fcfv.version = fc.version
WHERE ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
	AND fcfv.fcfvID IS NULL;

IF OBJECT_ID('tempdb..#FIELDVALUES') IS NOT NULL DROP TABLE #FIELDVALUES;

PRINT 'Value added successfully!';


