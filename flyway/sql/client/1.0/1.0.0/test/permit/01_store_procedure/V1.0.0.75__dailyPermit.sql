-- =============================================
-- Author:      Alexandre Tran
-- Create date: 01/02/2019
-- Description: Create daily permit with random settings
-- Parameters:
--   @KIOSKID - ID of the kiosk to apply to
--   @FORM_TYPE_NAME - The form type name
--   @TOTAL_PERMIT - The number of permit to create
--   @NUMB_DAY_START - The maximum number of day after creation date to set the start time. Default: 3
--   @NUMB_DAY_END - The maximum number of day after start date to set the end time. Default: 2
-- CHANGELOG:
-- 22/08/2020 - AT - Use name instead of ptName
-- 26/08/2020 - AT - Include description column
-- 20/10/2020 - AT - Include pass decryption
-- =============================================
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.dailyPermit (
@KIOSKID INT
,@PASS VARCHAR(255)
,@FORM_TYPE_NAME VARCHAR(255)
,@TOTAL_PERMIT INT
,@NUMB_DAY_START INT = 3
,@NUMB_DAY_END INT = 2
,@DEBUG BIT = 0
)
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @cnt INT = 0;
	DECLARE @CURRENTCOUNT INT;
	SELECT @CURRENTCOUNT = COUNT(mcnID) FROM mocCreateNumber;

	IF(@CURRENTCOUNT = 0)
	BEGIN
	SET @CURRENTCOUNT = 1;
	END

	IF (@CURRENTCOUNT < @TOTAL_PERMIT)
	BEGIN

		IF(@DEBUG = 1)
		BEGIN
			PRINT 'Attempt to create permits ...';
		END

		WHILE @cnt <= @TOTAL_PERMIT
		BEGIN

			-- Permit dates
			DECLARE @CREATION_DATE DATETIME = GETUTCDATE();
			DECLARE @START_TIME DATETIME = DATEADD(DAY,ROUND((3 * RAND()),0),@CREATION_DATE);
			SET @START_TIME = test.RoundTime(DATEADD(HOUR,ROUND((23 * RAND() + 1),0),@START_TIME),0.25);
			DECLARE @END_TIME DATETIME = DATEADD(DAY,ROUND((2 * RAND() + 1), 0),@START_TIME);
			SET @END_TIME = test.RoundTime(DATEADD(HOUR,ROUND((23 * RAND() + 1),0),@END_TIME),0.25);

			-- Permit refs
			DECLARE @Upper INT = 1000;
			DECLARE @Lower INT = 1;
			DECLARE @RANDOM INT = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0);
			DECLARE @REFNUMBER VARCHAR(3) = RIGHT('000'+CAST(@RANDOM AS VARCHAR(3)),3);
			DECLARE @FORMCREATEID INT = (SELECT TOP (1) [pcID] FROM [dbo].[permitCreate] ORDER BY pcID DESC);

			-- Get random site
			DECLARE @SITEUUID VARCHAR(255) = (
				SELECT TOP (1) ks.kioskSiteUUID
				FROM kioskSite AS ks
				WHERE ks.kioskSiteIsActive = 1
					AND ks.kioskID = @KIOSKID
				ORDER BY NEWID()
			);

			-- Get permit info
			DECLARE @PERMIT_PREFIX VARCHAR(3) = (
				SELECT TOP (1) pt.[ptInitial]
  			FROM [dbo].[permitType] AS pt
  			WHERE pt.name = @FORM_TYPE_NAME
					AND pt.kioskSiteUUID = @SITEUUID
					AND pt.kioskID = @KIOSKID);

			DECLARE @PERMIT_NUMBER VARCHAR(255) = CONCAT(UPPER(FORMAT(@START_TIME, 'MMMyy')),'-',@PERMIT_PREFIX,RIGHT('000'+CAST( ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0) AS VARCHAR(3)),3));

			-- Get random permit creator
			DECLARE @CREATOR INT = (
				SELECT TOP (1) ptACL.[ptACLGrantAccessToKUID]
				FROM [permitTypeACL] AS ptACL
				WHERE ptACL.ptACLIsActive = 1
					AND ptACL.kioskID = @KIOSKID
					AND ptACL.kioskSiteUUID = @SITEUUID
				ORDER BY NEWID()
			);
			
			-- Get random location
			DECLARE @LOCATION INT = (
				SELECT TOP(1) kl.[klID]
				  FROM [kioskLocation] AS kl
				  WHERE kl.klIsActive = 1
					AND kl.klParentID = 0
					AND kl.kioskID = @KIOSKID
					AND kl.kioskSiteUUID = @SITEUUID
				  ORDER BY NEWID()
			);

			IF(@FORMCREATEID IS NULL)
			BEGIN
				SET @FORMCREATEID = 0;
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
			SELECT pt.kioskID,pt.kioskSiteUUID
			,@PERMIT_NUMBER,pt.ptID
			,'Auto Generated - Daily job','Auto Generated - Daily job'
			,NEWID(),NEWID()
			,1,0
			,@START_TIME,CAST(@START_TIME AS TIME)
			,@END_TIME,CAST(@END_TIME AS TIME)
			,@LOCATION
			,@CREATOR,@CREATION_DATE
			,1
			FROM permitType AS pt
			WHERE UPPER(pt.name) = UPPER(@FORM_TYPE_NAME)
				AND pt.kioskID = @KIOSKID
				AND pt.kioskSiteUUID = @SITEUUID;
			
			IF (@DEBUG = 1)
			BEGIN
				PRINT CONCAT('Created permit <', @PERMIT_NUMBER,'> starting at <',CAST(@START_TIME AS VARCHAR(255)),'> and end at <',CAST(@END_TIME AS VARCHAR(255)));
				PRINT CONCAT('    on site <',@SITEUUID,'> and creator <',@CREATOR,'>');
			END

			SET @cnt +=1;
		END

		IF(@DEBUG = 1)
		BEGIN
			PRINT 'Attempt add counter ...';
		END
		
		EXEC test.syncPermitNumber @KIOSKID=@KIOSKID
		,@FORM_TYPE_NAME = @FORM_TYPE_NAME;

		IF(@DEBUG = 1)
		BEGIN
			PRINT 'Attempt add Permit approver...';
		END
		
		EXEC test.syncPermitApprover @KIOSKID=@KIOSKID
		,@FORM_TYPE_NAME = @FORM_TYPE_NAME;

		IF(@DEBUG = 1)
		BEGIN
			PRINT 'Approver added to permit successfully!';
			PRINT 'Attempt sync permit form history...';
		END
		
		EXEC test.syncPermitFormHistory @KIOSKID=@KIOSKID
		,@PASS=@PASS
		,@FORM_TYPE_NAME = @FORM_TYPE_NAME;

		IF(@DEBUG = 1)
		BEGIN
			PRINT 'Permit form history sync successfully!';
		END
		
	END
END
