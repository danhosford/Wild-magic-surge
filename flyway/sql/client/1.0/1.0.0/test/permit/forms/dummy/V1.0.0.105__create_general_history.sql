-- =============================================
-- Author:      Alexandre Tran
-- Create date: 30/01/2019
-- Description: Generate permit history
-- CHANGELOG:
-- * 22/08/2020 - AT - Use name instead of ptname
-- * 26/08/2020 - AT - Include description column
-- * 20/10/2020 - AT - Include pass encryption
-- * 03/11/2020 - AT - Reduce number permit
-- =============================================

USE v3_o5066;
DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());
DECLARE @FORM_TYPE_NAME VARCHAR(255) = 'General';
DECLARE @TOTAL_PERMIT INT = 50;
DECLARE @TOTAL_YEARS INT = 3;
DECLARE @CREATOR_EMAIL VARCHAR(255) = 'create.permit@onelooksystems.com';
DECLARE @APPROVER_EMAIL VARCHAR(255) = 'approve.permit@onelooksystems.com';
DECLARE @EXCLUDE_TEMPLATE BIT = 1;
DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

SET NOCOUNT ON;

DECLARE @START_YEAR INT = YEAR(DateAdd(yy, -@TOTAL_YEARS, GetUTCDate()));
DECLARE @cnt INT = 0;
DECLARE @CURRENTCOUNT INT;
SELECT @CURRENTCOUNT = COUNT(mcnID) FROM mocCreateNumber;

IF(@CURRENTCOUNT = 0)
BEGIN
SET @CURRENTCOUNT = 1;
END

IF (@CURRENTCOUNT < @TOTAL_PERMIT)
BEGIN

	PRINT 'Attempt to create permits ...';

	WHILE @cnt <= @TOTAL_PERMIT
	BEGIN

		DECLARE @CREATION_DATE DATETIME = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % (365 * @TOTAL_YEARS)), CONCAT(@START_YEAR,'-01-01'));
		SET @CREATION_DATE =  DATEADD(HOUR, ABS(CHECKSUM(NEWID()) % 24), @CREATION_DATE);
		DECLARE @Upper INT = 1000;
		DECLARE @Lower INT = 1
		DECLARE @RANDOM INT = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0);
		DECLARE @REFNUMBER VARCHAR(3) = RIGHT('000'+CAST(@RANDOM AS VARCHAR(3)),3);
		DECLARE @START_TIME DATETIME = DATEADD(DAY,ROUND((31 * RAND() + 1),0),@CREATION_DATE);
		SET @START_TIME = test.RoundTime(DATEADD(HOUR,ROUND((23 * RAND() + 1),0),@START_TIME),0.25);
		DECLARE @END_TIME DATETIME = test.RoundTime(DATEADD(HOUR,ROUND(((23 -2) * RAND() + 1), 0),@START_TIME),0.25);
		DECLARE @FORMCREATEID INT = (SELECT TOP (1) [pcID] FROM [dbo].[permitCreate] ORDER BY pcID DESC);
		DECLARE @PERMIT_NUMBER VARCHAR(255) = CONCAT(UPPER(FORMAT(@START_TIME, 'MMMyy')),'-AUTO',RIGHT('000'+CAST( ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0) AS VARCHAR(3)),3));
			
		IF (@DEBUG = 1)
		BEGIN
			PRINT @CREATION_DATE;
			PRINT @PERMIT_NUMBER
		END

		IF(@FORMCREATEID IS NULL)
		BEGIN
			SET @FORMCREATEID = 0;
		END

		IF (@DEBUG = 1)
		BEGIN
			PRINT @FORMCREATEID;
		END

		INSERT INTO [permitCreate] (
			[kioskID],[kioskSiteUUID]
			,[permitNumber],[ptID]
			,[permitDescription],[description]
			,[permitPublicKey],[permitPrivateKey]
			,[permitStatus],[isTemplate]
			,[permitDateOfWorkStart],[permitTimeStart]
			,[permitDateOfWorkEnd],[permitTimeEnd]
			,[permitLocation]
			,[permitCreateBy],[permitCreateUTC]
			,[permitContractorModuleInUse]
		)
		SELECT
		@KIOSKID,ks.kioskSiteUUID
		,@PERMIT_NUMBER,pt.ptID
		,'Auto generated - history purpose','Auto generated - history purpose'
		,NEWID(),NEWID()
		,1,0
		,@START_TIME,CAST(@START_TIME AS TIME)
		,@END_TIME,CAST(@END_TIME AS TIME)
		,(
			SELECT TOP(1) kl.[klID]
			FROM [kioskLocation] AS kl
			WHERE kl.klIsActive = 1
				AND kl.klParentID = 0
				AND kl.kioskSiteUUID = ks.kioskSiteUUID
			ORDER BY NEWID()
		)
		,(
			SELECT TOP (1) ptACL.[ptACLGrantAccessToKUID]
			FROM [permitTypeACL] AS ptACL
			WHERE ptACL.ptACLIsActive = 1
				AND ptACL.kioskSiteUUID = ks.kioskSiteUUID
			ORDER BY NEWID()
		),@CREATION_DATE
		,1
		FROM kioskSite AS ks
		LEFT JOIN permitType AS pt ON pt.name = @FORM_TYPE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
			AND pt.kioskSiteUUID = ks.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
			AND pt.kioskID = @KIOSKID
		WHERE pt.ptID IS NOT NULL;
		

		SET @cnt +=1;
	END

	PRINT 'Total Permit created: ' + CAST(@cnt AS VARCHAR(255));

END

PRINT 'Attempt add counter ...';

EXEC test.syncPermitNumber @KIOSKID=@KIOSKID
,@FORM_TYPE_NAME = @FORM_TYPE_NAME;

PRINT 'Attempt add Permit approver...';

EXEC test.syncPermitApprover @KIOSKID=@KIOSKID
,@FORM_TYPE_NAME = @FORM_TYPE_NAME;

PRINT 'Approver added to permit successfully!';

PRINT 'Attempt sync permit form history...';
EXEC test.syncPermitFormHistory @KIOSKID=@KIOSKID
,@PASS=@PASS
,@FORM_TYPE_NAME = @FORM_TYPE_NAME;

PRINT 'Permit form history sync successfully!'

PRINT 'Attempt to approve permit before today...';
EXEC test.approvePermits @KIOSKID=@KIOSKID,@COMMENT='Tester auto approved from Mars';
PRINT 'Permit approved successfully!'

SET NOCOUNT OFF;