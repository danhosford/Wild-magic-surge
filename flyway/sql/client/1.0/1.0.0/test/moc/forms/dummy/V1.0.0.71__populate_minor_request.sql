-- ========================================================
-- Author:      Alex Tran
-- Create date: 26/01/2018
-- Description: 
-- * 26/01/2018 - AT - Generate MOC
-- * 04/06/2020 - AT - Insert MSSQL encrypted value
-- ========================================================

USE v3_o5066;
DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @FORM_TYPE_NAME VARCHAR(255) = 'Locations';
DECLARE @TOTAL_MOC_TO_CREATE INT = 5;
DECLARE @TOTAL_TASK_TO_CREATE INT = 10;
DECLARE @TOTAL_YEARS INT = 3;
DECLARE @REQUESTER_EMAIL VARCHAR(255) = 'moc.requester@onelooksystems.com';
DECLARE @TASK_OWNER_EMAIL VARCHAR(255) = 'moc.action.task.owner@onelooksystems.com';
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#FIELDVALUES') IS NOT NULL DROP TABLE #FIELDVALUES;

CREATE TABLE #FIELDVALUES (
	fieldtype VARCHAR(255) NOT NULL,
	fieldValue VARCHAR(255) NOT NULL,
	value VARCHAR(255) NOT NULL
);

INSERT INTO #FIELDVALUES
VALUES('fDescription','(8<NY,W-=N+@ ','test')
,('dateOfWorkStart','8,(7,<NZN7]E8PX-X&1.D)C''%*:YIT\Q<','26&#x2f;01&#x2f;2019')
,('location','(W\+^--5M87T','7')
,('locationLevel2CFC','(=T0$G2EJ77\','10')
,('locationLevel3CFC','(__8T,6N$45L','58')
,('mocApprover','(J08RRX!N4.< ','2')
,('attachment','','');

DECLARE @START_YEAR INT = YEAR(DateAdd(yy, -@TOTAL_YEARS, GetUTCDate()));
DECLARE @cnt INT = 0;
DECLARE @CURRENTCOUNT INT;
SELECT @CURRENTCOUNT = COUNT(mcnID) FROM mocCreateNumber;

IF(@CURRENTCOUNT = 0)
BEGIN
SET @CURRENTCOUNT = 1;
END

IF (@CURRENTCOUNT < @TOTAL_MOC_TO_CREATE)
BEGIN

	PRINT 'Attempt to complete MOC Request ...';

	WHILE @cnt <= @TOTAL_MOC_TO_CREATE
	BEGIN

		DECLARE @CREATION_DATE DATETIME = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % (365 * @TOTAL_YEARS)), CONCAT(@START_YEAR,'-01-01'));
		SET @CREATION_DATE =  DATEADD(HOUR, ABS(CHECKSUM(NEWID()) % 24), @CREATION_DATE);
		DECLARE @Upper INT = 1000;
		DECLARE @Lower INT = 1
		DECLARE @RANDOM INT = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0);
		DECLARE @REFNUMBER VARCHAR(3) = RIGHT('000'+CAST(@RANDOM AS VARCHAR(3)),3);
		DECLARE @MOC_NUMBER VARCHAR(255) = CONCAT(UPPER(FORMAT(@CREATION_DATE, 'MMMyy')),'-MOC',RIGHT('000'+CAST( ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0) AS VARCHAR(3)),3));
		
		IF (@DEBUG = 1)
		BEGIN
			PRINT @CREATION_DATE;
			PRINT @MOC_NUMBER
		END
		
		DECLARE @END_TIME DATETIME = DATEADD(HOUR,ROUND(((23 -2) * RAND() + 1), 0),@CREATION_DATE);
		DECLARE @FORMCREATEID INT = (SELECT TOP (1) [fcID] FROM [dbo].[formCreate] ORDER BY fcID DESC);
		
		IF(@FORMCREATEID IS NULL)
		BEGIN
			SET @FORMCREATEID = 0;
		END

		IF (@DEBUG = 1)
		BEGIN
			PRINT @FORMCREATEID;
		END

		INSERT INTO [formCreate] (
			[kioskID],[kioskSiteUUID]
			,[fcid],[version],[formNumber]
			,[formCreatePublicKey]
			,[formStatus],[unfinished]
			,[formCreateBy],[formCreateUTC]
			,[formTypeID]
			,[cpCompanyComplianceRequirementID]
			,[formDescription]
			,[formDateOfWorkStart],[formTimeOfWorkStart]
			,[formDateOfWorkEnd],[formTimeOfWorkEnd])
		SELECT
		@KIOSKID,ks.kioskSiteUUID
		,(ROW_NUMBER() OVER ( ORDER BY ks.kioskSiteUUID ) + @FORMCREATEID),1,@MOC_NUMBER
		,NEWID()
		,1,0
		,ku.kuid,GETUTCDATE()
		,ft.formTypeID
		,0
		,'Auto Generated'
		,@CREATION_DATE,CAST(@CREATION_DATE AS TIME)
		,@END_TIME,CAST(@END_TIME AS TIME)
		FROM kioskSite AS ks
		LEFT JOIN [kioskUser] AS ku ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = @REQUESTER_EMAIL
		LEFT JOIN formType AS ft ON ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
			AND ft.kioskSiteUUID = ks.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
			AND ft.kioskID = @KIOSKID
		

		SET @cnt +=1;
	END

	PRINT 'Total MOC request created: ' + CAST(@cnt AS VARCHAR(255));

END

PRINT 'Attempt add counter ...';
INSERT INTO [mocCreateNumber] (
[kioskID],[kioskSiteUUID]
,[mcID],[mocPublicKey],[mocNumber]
,[mcnMonth],[mcnYear],[mcnCountForMonth])
SELECT fc.kioskID,fc.kioskSiteUUID
,fc.fcid,fc.[formCreatePublicKey],fc.[formNumber]
,MONTH(fc.[formDateOfWorkStart]),YEAR(fc.[formDateOfWorkStart]),1
FROM [formCreate] AS fc
LEFT JOIN formType AS ft ON fc.formTypeID = ft.formTypeID
		AND ft.kioskSiteUUID = fc.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
		AND ft.kioskID = @KIOSKID
LEFT JOIN mocCreateNumber AS mcn ON mcn.mocPublicKey = fc.[formCreatePublicKey]
	AND mcn.kioskSiteUUID = fc.kioskSiteUUID
	AND mcn.kioskID = fc.kioskID
	AND mcn.mocNumber = fc.[formNumber]
WHERE ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
	AND mcn.mcnID IS NULL;

PRINT 'Attempt add MOC approver...';

INSERT INTO [mocCreateApprover](
[kioskID],[kioskSiteUUID]
,[mcID],[mocPublicKey],[maPublicKey]
,[maApproverIDSelected],[maOrder]
,[maCreateBy],[maCreateUTC]
,[maApproverStatus],[mcaIsActive]
,[mocVersion]
)
SELECT fc.kioskID,fc.kioskSiteUUID
,fc.fcID,fc.formCreatePublicKey,NEWID()
,2,1
,fc.formCreateBy,fc.formCreateUTC
,12,1
,fc.version
FROM [formCreate] AS fc
LEFT JOIN formType AS ft ON ft.formTypeID = fc.formTypeID
	AND ft.kioskSiteUUID = fc.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
	AND ft.kioskID = @KIOSKID
WHERE ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS;

PRINT 'MOC Approver added successfully!';

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
,[formCreatePublicKey],[version]
,[fvValueS])
SELECT fc.kioskID,fc.kioskSiteUUID
,ffq.[formFieldID],fv.fieldValue
,fc.[formCreateBy],fc.[formCreateUTC]
,fc.[formCreatePublicKey],fc.version
,ENCRYPTBYPASSPHRASE(@PASS,fv.[value])
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

PRINT 'Value added successfully!';

SET @cnt = 0;

WHILE @cnt < @TOTAL_TASK_TO_CREATE
BEGIN

	PRINT 'Attempt creating MOC task ' + CAST(@cnt AS VARCHAR(255));

	INSERT INTO [mocActionTaskCreate] (
		[kioskID],[kioskSiteUUID]
	    ,[mocPublicKey],[mcID]
	    ,[mfID],[matcIsActive],[matcIsCancelled]
	    ,[matcTitle],[matcDescription]
	    ,[matcDueDate]
	    ,[matcCreateBy],[matcCreateUTC]
	    ,[mocVersion])
	SELECT fc.kioskID,fc.kioskSiteUUID
	,fc.formCreatePublicKey,fc.fcid
	,0,1,0
	,'Auto generated','Auto generated'
	,DATEADD(HOUR, ABS(CHECKSUM(NEWID()) % 24), CAST(fc.[formDateOfWorkStart] AS DATETIME))
	,fc.[formCreateBy],GETUTCDATE()
	,fc.version
	FROM [formCreate] AS fc
	LEFT JOIN formType AS ft ON ft.formTypeID = fc.formTypeID
		AND ft.kioskSiteUUID = fc.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
		AND ft.kioskID = @KIOSKID
	WHERE ft.formName = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
		--AND (SELECT COUNT(*) FROM mocActionTaskCreate WHERE mcID = fc.fcid) < @TOTAL_TASK_TO_CREATE;

	PRINT 'Task created successfully: ' + CAST(@cnt AS VARCHAR(255));

	set @cnt +=1;
END

PRINT 'Attempt add action task owner ...';
 INSERT INTO [mocActionTaskOwner](
 [matcID],[kioskID],[kioskSiteUUID]
,[kuPublicKey],[matoIsActive]
 )
SELECT matc.[matcID],matc.[kioskID],matc.[kioskSiteUUID]
,ku.kuPublicKey,1
FROM [dbo].[mocActionTaskCreate] AS matc
LEFT JOIN [kioskUser] AS ku ON CONVERT(VARCHAR(255),DECRYPTBYPASSPHRASE(@PASS,ku.kuEmailN)) = @TASK_OWNER_EMAIL
LEFT JOIN mocActionTaskOwner AS mato ON mato.kioskID = matc.kioskID
	AND mato.kioskSiteUUID = matc.kioskSiteUUID
	AND mato.kuPublicKey = ku.kuPublicKey
WHERE mato.matoID IS NULL;
PRINT 'Task owner added successfully!';

PRINT 'Attempt add task log...';
INSERT INTO [mocActionTaskStatusLog] (
[matcID],[kioskID],[kioskSiteUUID]
,[matcStatusID],[matcStatusLogComment]
,[matcStatusLogCreateBy],[matcStatusLogUTC]
,[matcStatusLogIsActive]
)
SELECT matc.matcID, matc.kioskID,matc.kioskSiteUUID
,1,'Auto generated'
,ku.kuPublicKey,matc.matcCreateUTC
,1
FROM mocActionTaskCreate AS matc
LEFT JOIN kioskUser AS ku ON ku.kuID = matc.matcCreateBy
LEFT JOIN mocActionTaskStatusLog AS matsl ON matsl.matcID = matc.matcID
	AND matsl.kioskID = matc.kioskID
	AND matsl.kioskSiteUUID = matc.kioskSiteUUID
	AND matsl.matcStatusID = 1
	AND matsl.matcStatusLogCreateBy = ku.kuPublicKey
	AND matsl.matcStatusLogUTC = matc.matcCreateUTC
WHERE matsl.matcStatusLogID IS NULL;
PRINT 'Task log added successfully';

IF OBJECT_ID('tempdb..#FIELDVALUES') IS NOT NULL DROP TABLE #FIELDVALUES;

SET NOCOUNT OFF;