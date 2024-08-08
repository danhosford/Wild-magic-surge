-- =============================================================================
-- CHANGELOG:
-- 01/07/2020 - AT - Add validation breadcrumb exist before adding them
-- =============================================================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

IF OBJECT_ID('test.setFeatureACL') IS NULL
    EXEC ('CREATE PROCEDURE test.setFeatureACL AS SELECT 1');
GO

IF TYPE_ID('test.GroupFeatures') IS NULL
BEGIN
/* Create a table type. */  
	CREATE TYPE test.GroupFeatures AS TABLE ( 
		section VARCHAR(255) NOT NULL,
		page VARCHAR(255) NOT NULL,
		appPrefix VARCHAR(255) NOT NULL,
		enable BIT NOT NULL DEFAULT 1
	); 
END

IF TYPE_ID('test.GroupNames') IS NULL
BEGIN
/* Create a table type. */  
	CREATE TYPE test.GroupNames AS TABLE ( 
		name VARCHAR(255) NOT NULL
	); 
END
GO

CREATE OR ALTER PROCEDURE test.setFeatureACL
(
@KIOSKID INT
,@groupname test.GroupNames READONLY
,@featureslist test.GroupFeatures READONLY
)
AS
BEGIN

	DECLARE @notexisting INT = (SELECT COUNT(*)
	FROM @featureslist AS [feature]
	LEFT JOIN [v3_sp].[dbo].[kioskBreadcrumb] AS [breadcrumb]
		ON [breadcrumb].[kbcSection] = [feature].[section] COLLATE SQL_Latin1_General_CP1_CI_AS
		AND [breadcrumb].[kbcPage] = [feature].[page] COLLATE SQL_Latin1_General_CP1_CI_AS
	WHERE [breadcrumb].[kbcid] IS NULL);

	IF (@notexisting > 0)
	BEGIN
		RAISERROR (N'Some of the breadcrumb provided are invalid or does not exist.',18,-1);
		RETURN
	END

	PRINT 'Attempt enable required features on all sites...';
	INSERT INTO [kioskAccessControlFeature] (
	[kioskID],[kioskSiteUUID]
	,[kbcID],[kacfIsActive]
	,[kacfCreateBy],[kacfCreateUTC]
	)
	SELECT @KIOSKID,ks.kioskSiteUUID
	,kbc.kbcID,paf.enable
	,0,GETUTCDATE()
	FROM @featureslist AS paf
	LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kbc ON kbc.kbcSection = paf.section COLLATE SQL_Latin1_General_CP1_CI_AS
		AND kbc.kbcPage = paf.page COLLATE SQL_Latin1_General_CP1_CI_AS
	FULL OUTER JOIN kioskSite AS ks ON ks.kioskID = @KIOSKID
		AND ks.kioskSiteUUID IS NOT NULL
	LEFT JOIN kioskAccessControlFeature AS kacf ON kacf.kioskID = @KIOSKID
		AND kacf.kioskSiteUUID = ks.kioskSiteUUID
		AND kacf.kbcID = kbc.kbcID
		AND kacf.kacfIsActive = paf.enable
	WHERE paf.enable = 1
		AND kacf.kacfID IS NULL;
	PRINT 'Features required enable on all sites successfully!';

	PRINT 'Attempt to set up ACL for group...';
	INSERT INTO [kioskAccessControlPage] (
	[kioskID],[kioskSiteUUID]
	,[kbcID],[kacgPublicKey],[kacpIsActive]
	,[kacpCreateBy],[kacpCreateUTC]
	)
	SELECT @KIOSKID,kacg.kioskSiteUUID
	,kbc.kbcID,kacg.kacgPublicKey,paf.enable
	,0,GETUTCDATE()
	FROM @featureslist AS paf
	LEFT JOIN v3_sp.dbo.kioskBreadcrumb AS kbc ON kbc.kbcSection = paf.section COLLATE SQL_Latin1_General_CP1_CI_AS
		AND kbc.kbcPage = paf.page COLLATE SQL_Latin1_General_CP1_CI_AS
	FULL OUTER JOIN @groupname AS g ON g.name IS NOT NULL
	LEFT JOIN kioskAccessControlGroup AS kacg ON UPPER(kacg.kacgName) = UPPER(g.name) COLLATE SQL_Latin1_General_CP1_CI_AS
	LEFT JOIN kioskAccessControlPage AS kacp ON kacp.kioskID = @KIOSKID
		AND kacp.kioskSiteUUID = kacg.kioskSiteUUID
		AND kacp.kbcID = kbc.kbcID
		AND kacp.kacgPublicKey = kacg.kacgPublicKey
		AND kacp.kacpIsActive = paf.enable
	WHERE kacp.kacpID IS NULL
		and paf.enable = 1;

	PRINT 'ACL for group setup successfully!';
END
GO