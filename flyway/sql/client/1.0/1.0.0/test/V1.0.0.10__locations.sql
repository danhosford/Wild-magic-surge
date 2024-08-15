/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 02/12/2018 12:42
Create location
*/

DECLARE @DEBUG BIT = 0;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#LOCATIONS') IS NOT NULL DROP TABLE #LOCATIONS

CREATE TABLE #LOCATIONS(
	name VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
	,parentName VARCHAR(255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
	,level INT NOT NULL
	,isActive BIT DEFAULT 1
	,orderIndex INT DEFAULT 0
);

INSERT INTO #LOCATIONS (name,parentName,level)
VALUES ('Eiffel Tower',NULL,0)
,('The Esplanade','Eiffel Tower',1)
,('1st Floor','Eiffel Tower',1)
,('The transparent floor','1st Floor',2)
,('CinEffeil','1st Floor',2)
,('Cultural Path','1st Floor',2)
,('Ferri&eacute; Pavilion','1st Floor',2)
,('Spiral StairCase','1st Floor',2)
,('2nd Floor','Eiffel Tower',1)
,('The Jules Verne Restaurant','2nd Floor',2)
,('The Buffet','2nd Floor',2)
,('Chaillot Gift Shop','2nd Floor',2)
,('Seine Gift Shop','2nd Floor',2)
,('Vertigo','Eiffel Tower',1)
,('Gustave Eiffel&rsquo;s office','Vertigo',2)
,('The panoramic maps','Vertigo',2)
,('The 1889 summit','Vertigo',2)
,('The 1899 lift machinery','The Esplanade',2)
,('Gustave Eiffel sculpted','The Esplanade',2)
,('The Information desk','The Esplanade',2)
,('White House',NULL,0)
,('Ground Floor','White House',1)
,('Library','Ground Floor',2)
,('Vermeil Room','Ground Floor',2)
,('China Room','Ground Floor',2)
,('Diplomatic Reception Room','Ground Floor',2)
,('Map Room','Ground Floor',2)
,('Center Hall','Ground Floor',2)
,('State Floor','White House',1)
,('Family Dining Room','State Floor',2)
,('Chief Usher','State Floor',2)
,('Entrance Hall','State Floor',2)
,('Cross Hall','State Floor',2)
,('East Room','State Floor',2)
,('Green Room','State Floor',2)
,('Blue Room','State Floor',2)
,('Red Room','State Floor',2)
,('State Dining Room','State Floor',2)
,('South Portico','State Floor',2)
,('Residence Floor','White House',1)
,('Kitchen','Residence Floor',2)
,('President&#x27;s Dining Room','Residence Floor',2)
,('West Sitting Hall','Residence Floor',2)
,('Dressing Room','Residence Floor',2)
,('President&#x27;s Bedroom','Residence Floor',2)
,('Private Sitting Room','Residence Floor',2)
,('Center Hall','Residence Floor',2)
,('Cometology Room','Residence Floor',2)
,('West Room','Residence Floor',2)
,('North Hall','Residence Floor',2)
,('East Room','Residence Floor',2)
,('Yellow Oval Room','Residence Floor',2)
,('Treaty Room','Residence Floor',2)
,('Truman Balcony','Residence Floor',2)
,('Grand Stair','Residence Floor',2)
,('Stair Landing','Residence Floor',2)
,('Queen&#x27;s Bedroom','Residence Floor',2)
,('Queen&#x27;s sitting','Residence Floor',2)
,('East Sitting Hall','Residence Floor',2)
,('Lincoln Bedroom','Residence Floor',2)
,('Lincoln Sitting','Residence Floor',2)
,('West Wing','White House',1)
,('National Security Adviser Office','West Wing',2)
,('Deputy N. SA Office','West Wing',2)
,('Deputy Comm. Director Office','West Wing',2)
,('Communications Director Office','West Wing',2)
,('Deputy Chief Staff Office','West Wing',2)
,('Deputy Chief Staff Office 2','West Wing',2)
,('President Secretary Office','West Wing',2)
,('Reception Area','West Wing',2)
,('Senior Advisor I Office','West Wing',2)
,('Senior Advisor II Office','West Wing',2)
,('Press Staff I office','West Wing',2)
,('Press Staff II office','West Wing',2)
,('Press Staff III office','West Wing',2)
,('Press Sec&#x27;Y Office','West Wing',2)
,('Lobby','West Wing',2)
,('Vice President Office','West Wing',2)
,('Chief Of State Office','West Wing',2)
,('Dining Room','West Wing',2)
,('Study Room','West Wing',2)
,('Roosevelt Room','West Wing',2)
,('Oval Office','West Wing',2)
,('Cabinet Room','West Wing',2)
,('Press Briefing Room','West Wing',2)
,('Press Corps Offices','West Wing',2)
,('Palm Room','West Wing',2)
,('West Colonnade','West Wing',2)
,('Vault13',NULL,0)
,('Entrance','Vault13',1)
,('Living Quarters','Vault13',1)
,('Command Center','Vault13',1);

PRINT 'Attempt add all location if not exist ...';
INSERT INTO dbo.kioskLocation (
[klLocationName],[klIsActive],[klOrder]
,[kioskID],[kioskSiteUUID]
,[klParentID],[klLevel]
,[klCreateBy],[klCreateUTC]
)
SELECT l.name,l.isActive,l.orderIndex
,@KIOSKID,ks.kioskSiteUUID
,IIF(l.parentName IS NULL, 0, NULL),l.level
,0,GETUTCDATE()
FROM #LOCATIONS AS l
LEFT JOIN #LOCATIONS AS parent ON parent.name = l.parentName
FULL OUTER JOIN kioskSite AS ks ON ks.kioskSiteUUID IS NOT NULL
LEFT JOIN dbo.kioskLocation AS kl ON kl.[klLocationName] = l.name COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kl.[kioskSiteUUID] = ks.kioskSiteUUID COLLATE SQL_Latin1_General_CP1_CI_AS
	AND kl.[kioskID] = ks.kioskID
WHERE kl.klID IS NULL;
PRINT 'Location added successfully!';

PRINT 'Attempt update parent child location relationship...';
-- Update parent child relationship
UPDATE kl
SET kl.[klParentID] = parent.[klID]
FROM kioskLocation AS kl
LEFT JOIN #LOCATIONS AS l ON l.name = kl.klLocationName COLLATE SQL_Latin1_General_CP1_CI_AS
LEFT JOIN kioskLocation AS parent ON parent.klLocationName = l.parentName COLLATE SQL_Latin1_General_CP1_CI_AS
	AND parent.kioskSiteUUID = kl.kioskSiteUUID
WHERE kl.klParentID IS NULL;

PRINT 'Parent/child location linked';

IF OBJECT_ID('tempdb..#LOCATIONS') IS NOT NULL DROP TABLE #LOCATIONS

SET NOCOUNT OFF;