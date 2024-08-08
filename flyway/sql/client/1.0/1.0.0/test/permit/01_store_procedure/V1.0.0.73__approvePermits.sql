-- =============================================
-- Author:      Alexandre Tran
-- Create date: 03/02/2019
-- Description: Approve automatically permits
-- Parameters:
-- 10/06/2020 - SG - Changing GETUTCDATE so it only approves older permits
-- =============================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER PROCEDURE test.approvePermits (
@KIOSKID INT
,@COMMENT VARCHAR(255)
,@DEBUG BIT = 0
)
AS
BEGIN

	-- Approve permit
	UPDATE pca
	SET pca.paIsReviewed = 1
	, pca.paIsApproved = 1
	, pca.paApproverComment = @COMMENT
	, pca.paApproverIDActual = pca.paApproverIDSelected
	, pca.paApproverUTC = DATEADD(DAY, RAND(CHECKSUM(NEWID())) * (1 + DATEDIFF(DAY,pca.paCreateUTC,pc.permitDateOfWorkStart)),pca.paCreateUTC)
	FROM permitCreateApprover AS pca
	LEFT JOIN permitCreate AS pc ON pc.kioskID = pca.kioskID
		AND pc.kioskSiteUUID = pca.kioskSiteUUID
		AND pc.permitPublicKey = pca.permitPublicKey
	WHERE pca.paCreateUTC < DATEADD(DAY , -2 , GETUTCDATE())
		AND pca.kioskID = @KIOSKID;

	-- Update history
	INSERT INTO [permitCreateStatusChange](
		[kioskID],[kioskSiteUUID]
		,[pcID],[permitPublicKey]
		,[pcscStatusPrev],[pcscStatusCurrent]
	    ,[pcscComment]
		,[pcscCreateBy],[pcscCreateUTC]
	)
	SELECT pca.kioskID,pca.kioskSiteUUID
		,pca.pcID,pca.permitPublicKey
		,ISNULL(latestStatus.pcscStatusCurrent,0),ps.permitStatusID
		,pca.paApproverComment
		,pca.paApproverIDActual,pca.paApproverUTC
	FROM permitCreateApprover AS pca
	LEFT JOIN v3_sp.dbo.permitStatus AS ps ON ps.permitStatus = 'Approved'
	LEFT JOIN permitCreateStatusChange AS alreadyChanged  ON alreadyChanged.kioskID = pca.kioskID
		AND alreadyChanged.kioskSiteUUID = pca.kioskSiteUUID
		AND alreadyChanged.permitPublicKey = pca.permitPublicKey
		AND (alreadyChanged.pcscStatusCurrent = ps.permitStatusID OR alreadyChanged.pcscStatusPrev = ps.permitStatusID)
	LEFT JOIN permitCreateStatusChange AS latestStatus ON latestStatus.kioskID = pca.kioskID
		AND latestStatus.kioskSiteUUID = pca.kioskSiteUUID
		AND latestStatus.permitPublicKey = pca.permitPublicKey
	LEFT OUTER JOIN permitCreateStatusChange AS history ON history.kioskID = pca.kioskID
		AND history.kioskSiteUUID = pca.kioskSiteUUID
		AND history.permitPublicKey = pca.permitPublicKey
		AND (history.pcscCreateUTC > latestStatus.pcscCreateUTC 
			OR history.pcscCreateUTC = latestStatus.pcscCreateUTC
			AND history.pcscID > latestStatus.pcscID)
	WHERE history.pcscID IS NULL
		AND alreadyChanged.pcID IS NULL
		AND pca.kioskID = @KIOSKID
		AND pca.paIsReviewed = 1
		AND pca.paIsApproved = 1
		AND pca.paApproverUTC IS NOT NULL;

	-- Update permit with latest status
	UPDATE pc
	SET pc.permitStatus = ISNULL(latestStatus.pcscStatusCurrent,0)
	--SELECT ISNULL(latestStatus.pcscStatusCurrent,0),pca.permitPublicKey,pca.kioskSiteUUID
	FROM permitCreateApprover AS pca
	LEFT JOIN permitCreate AS pc ON pc.kioskID = pca.kioskID
		AND pc.kioskSiteUUID = pca.kioskSiteUUID
		AND pc.permitPublicKey = pca.permitPublicKey
	LEFT JOIN permitCreateStatusChange AS latestStatus ON latestStatus.kioskID = pca.kioskID
		AND latestStatus.kioskSiteUUID = pca.kioskSiteUUID
		AND latestStatus.permitPublicKey = pca.permitPublicKey
	LEFT OUTER JOIN permitCreateStatusChange AS history ON history.kioskID = pca.kioskID
		AND history.kioskSiteUUID = pca.kioskSiteUUID
		AND history.permitPublicKey = pca.permitPublicKey
		AND (history.pcscCreateUTC > latestStatus.pcscCreateUTC 
			OR history.pcscCreateUTC = latestStatus.pcscCreateUTC
			AND history.pcscID > latestStatus.pcscID)
	WHERE history.pcscID IS NULL
		AND pca.kioskID = @KIOSKID
		AND pca.paIsReviewed = 1
		AND pca.paIsApproved = 1
		AND pca.paApproverUTC IS NOT NULL
		AND pca.paApproverComment = @COMMENT;

END

GO
