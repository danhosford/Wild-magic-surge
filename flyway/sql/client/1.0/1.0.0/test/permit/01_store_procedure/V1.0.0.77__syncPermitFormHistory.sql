-- ======================================================================
-- Author:      Alexandre Tran
-- Create date: 01/02/2019
-- Description: Sync Permit form history with auto generated permit
-- Parameters:
--   @KIOSKID - ID of the kiosk to apply to
--   @FORM_TYPE_NAME - The form type name
--   @EXCLUDE_TEMPLATE - Flag to indicate if template should be included or excluded. Default 1
-- Changelog:
-- 22/08/2020 - AT - Use name instead of ptname
-- 20/10/2020 - AT - Include pass decryption
-- 20/10/2020 - AT - Populate MSQL encrypted column
-- ======================================================================
USE [v3_o5066];
GO

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.syncPermitFormHistory (
@KIOSKID INT
,@PASS VARCHAR(255)
,@FORM_TYPE_NAME VARCHAR(255)
,@EXCLUDE_TEMPLATE BIT = 1
,@DEBUG BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#FIELDVALUES') IS NOT NULL DROP TABLE #FIELDVALUES;
	
	CREATE TABLE #FIELDVALUES (
		fieldtype VARCHAR(255) NOT NULL,
		fieldValue VARCHAR(255) NOT NULL,
		[value] VARCHAR(255) NOT NULL
	);

	INSERT INTO #FIELDVALUES
	VALUES ('notificationContent','','')
	,('pDateOfWorkStart','0&>)\+^#!MK2*UPQVPQPCN0','31 Jan 2019')
	,('pDescription','@^1[8# 7 VT]# B<O4:@T*GURW-*[4/-:!G!ZX,PDM < ','Auto generated - Minute job')
	,('contractorFreeText','','')
	,('companyFreeText','','')
	,('contractorSearch','(5]<=A=KX TT','0');

	IF(@DEBUG = 1)
	BEGIN
		PRINT 'Attempt populate status log ...';
	END

	 DECLARE @SUBMITTED VARCHAR(255) = 'Submitted';

	 INSERT INTO [permitCreateStatusChange] (
		[kioskID],[kioskSiteUUID],[pcID],[permitPublicKey]
		,[pcscStatusPrev],[pcscStatusCurrent],[pcscComment]
		,[pcscCreateBy],[pcscCreateUTC]
	  )
	  SELECT 
	  pc.kioskID, pc.kioskSiteUUID,pc.pcID,pc.permitPublicKey
	  ,0,ps.permitStatusID,'Submitted from Venus'
	  ,pc.permitCreateBy, pc.permitCreateUTC
	  FROM v3_sp.dbo.permitStatus AS ps
	  FULL OUTER JOIN permitCreate AS pc ON pc.kioskID = @KIOSKID
	  LEFT JOIN permitCreateStatusChange AS pcsc ON pcsc.kioskID = pc.kioskID
		AND pcsc.kioskSiteUUID = pc.kioskSiteUUID
		AND pcsc.permitPublicKey = pc.permitPublicKey
		AND pcsc.pcscCreateBy = pc.permitCreateBy
		AND pcsc.pcscStatusCurrent = ps.permitStatusID
	  WHERE UPPER(ps.permitStatus) = UPPER(@SUBMITTED)
		AND pcsc.pcscID IS NULL;
	
	IF(@DEBUG = 1)
	BEGIN
		PRINT 'Attempt populate status log ...';
		PRINT 'Attempt populate page for form created ...';
	END

	INSERT INTO [permitCreateFieldPage] (
	[kioskID],[kioskSiteUUID],[pcID]
	,[permitPublicKey],[ptID]
	,[ppID],[ppName],[ppOrder],[ppIsActive]
	,[pcfpCreateBy],[pcfpCreateUTC]
	,[ppCreateBy],[ppCreateUTC]
	)
	SELECT pc.kioskID,pc.kioskSiteUUID,pc.pcID
	,pc.permitPublicKey,pc.ptID
	,pp.ppID,pp.ppName,pp.ppOrder,pp.ppIsActive
	,pc.permitCreateBy,pc.permitCreateUTC
	,pp.ppCreateBy,pp.ppCreateUTC
	FROM [permitCreate] AS pc
	LEFT JOIN permitType AS pt ON pt.ptID = pc.ptID
		AND pt.kioskSiteUUID = pc.kioskSiteUUID
		AND pt.kioskID = pt.kioskID
	LEFT JOIN permitPage AS pp ON pp.ptID = pt.ptID
	LEFT JOIN [permitCreateFieldPage] AS pcf ON pcf.kioskID = pc.kioskID
		AND pcf.kioskSiteUUID = pc.kioskSiteUUID
		AND pcf.pcID = pc.pcID
		AND pcf.permitPublicKey = pc.permitPublicKey
		AND pcf.ptID = pc.ptID
	WHERE pc.isTemplate <> @EXCLUDE_TEMPLATE
		AND pt.name = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
		AND pcf.[pcfpID] IS NULL; 

	IF(@DEBUG = 1)
	BEGIN
		PRINT 'Page populate successfully!';
		PRINT 'Attempt populate field question for forms created ...';
	END
	
	INSERT INTO [permitCreateFieldQuestion] (
	[kioskID],[kioskSiteUUID],[pcID],[permitPublicKey],[ptID]
	,[ppID],[pfFieldType],[pfID]
	,[pfIsMandatory],[pfNarrative]
	,[pfOrder],[p_iuID]
	,[pcfqCreateBy],[pcfqCreateUTC]
	,[pfClass],[pfParam],[pfSelectValue],[pfSelectValueMandatory]
	)
	SELECT pc.kioskID,pc.kioskSiteUUID,pc.pcID,pc.permitPublicKey,pc.ptID
	,pf.ppID,pf.pfFieldType,pf.pfID
	,pf.pfIsMandatory,pf.pfNarrative
	,pf.pfOrder,0
	,pc.permitCreateBy,pc.permitCreateUTC
	,0,'',0,pf.pfSelectValueMandatory
	FROM [permitCreate] AS pc
	LEFT JOIN permitType AS pt ON pt.ptID = pc.ptID
		AND pt.kioskSiteUUID = pc.kioskSiteUUID
		AND pt.kioskID = pt.kioskID
	LEFT JOIN permitField AS pf ON pf.ptID = pc.ptID
	LEFT JOIN [permitCreateFieldQuestion] AS pcfq ON pcfq.kioskID = pc.kioskID
		AND pcfq.kioskSiteUUID = pc.kioskSiteUUID
		AND pcfq.permitPublicKey = pc.permitPublicKey
	WHERE pc.isTemplate <> @EXCLUDE_TEMPLATE
		AND pcfq.[pcfqID] IS NULL
		AND pt.name = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
		order by PCID;

	IF(@DEBUG = 1)
	BEGIN
		PRINT 'Field question populated for forms created successfully!';
		PRINT 'Attempt populate value for forms created ...';
	END

	INSERT INTO [permitCreateFieldValue](
	[kioskID],[kioskSiteUUID]
	,[ptID],[pcID],[permitPublicKey]
	,[pfID],[pvValue]
	,[pcfvCreateBy],[pcfvCreateUTC]
	,[value]
	)
	SELECT pc.kioskID,pc.kioskSiteUUID
	,pc.ptID,pc.pcID,pc.permitPublicKey
	,pf.pfID,ISNULL(
		CASE pf.pfFieldType
			WHEN 'pApprover' THEN approver.encrypted
			WHEN 'pLocation' THEN location.encrypted
			WHEN 'pTimeStart' THEN encStartTime.encrypted COLLATE SQL_Latin1_General_CP1_CI_AS
			WHEN 'pTimeEnd' THEN encEndTime.encrypted COLLATE SQL_Latin1_General_CP1_CI_AS
			ELSE fv.fieldValue
		END
	,'')
	,pc.permitCreateBy,pc.permitCreateUTC
	,ISNULL(
		CASE pf.pfFieldType
			WHEN 'pApprover' THEN ENCRYPTBYPASSPHRASE(@PASS,CONVERT(VARCHAR(255),approver.number))
			WHEN 'pLocation' THEN ENCRYPTBYPASSPHRASE(@PASS,CONVERT(VARCHAR(255),location.number))
			WHEN 'pTimeStart' THEN ENCRYPTBYPASSPHRASE(@PASS,CONVERT(VARCHAR(255),encStartTime.time))
			WHEN 'pTimeEnd' THEN ENCRYPTBYPASSPHRASE(@PASS,CONVERT(VARCHAR(255),encEndTime.time))
			ELSE ENCRYPTBYPASSPHRASE(@PASS,CONVERT(VARCHAR(255),fv.[value]))
		END
	,ENCRYPTBYPASSPHRASE(@PASS,''))
	FROM [permitCreate] AS pc
	LEFT JOIN permitType AS pt ON pt.ptID = pc.ptID
		AND pt.kioskSiteUUID = pc.kioskSiteUUID
		AND pt.kioskID = pt.kioskID
	LEFT JOIN permitField AS pf ON pf.ptID = pc.ptID
	LEFT JOIN #FIELDVALUES AS fv ON fv.fieldtype = pf.pfFieldType COLLATE SQL_Latin1_General_CP1_CI_AS
	LEFT JOIN permitCreateApprover AS pca ON pca.kioskID = pc.kioskID
		AND pca.kioskSiteUUID = pc.kioskSiteUUID
		AND pca.pcID = pc.pcID
		AND pca.paCreateBy = pc.permitCreateBy
	LEFT JOIN test.encryptedNumbers AS approver ON approver.number = pca.paApproverIDSelected
	LEFT JOIN test.encryptedNumbers AS location ON location.number = pc.permitLocation
	LEFT JOIN test.encryptedTime AS encStartTime ON encStartTime.time = pc.permitTimeStart
	LEFT JOIN test.encryptedTime AS encEndTime ON encEndTime.time = pc.permitTimeEnd
	LEFT JOIN permitCreateFieldValue AS pcfd ON pcfd.kioskID = pc.kioskID
		AND pcfd.kioskSiteUUID = pc.kioskSiteUUID
		AND pcfd.ptID = pc.ptID
		AND pcfd.permitPublicKey = pc.permitPublicKey
	WHERE pc.isTemplate <> @EXCLUDE_TEMPLATE
		AND pt.name = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
		AND pcfd.pcfvID IS NULL;

	IF(@DEBUG = 1)
	BEGIN
		PRINT 'Value populated for forms created successfully!';
	END
	

	IF OBJECT_ID('tempdb..#FIELDVALUES') IS NOT NULL DROP TABLE #FIELDVALUES;
	IF OBJECT_ID('tempdb..#DUMBNUMBENC') IS NOT NULL DROP TABLE #DUMBNUMBENC;

END