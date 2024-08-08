-- =============================================
-- Author:      Alexandre Tran
-- Create date: 04/04/2019
-- Description: Create questionaire form for Course
-- =============================================

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @COURSE_NAME VARCHAR(255) = 'Jedi Training';
DECLARE @FORM_NAME VARCHAR(255) = 'Ready to be Jedi?';
DECLARE @QUALIFICATION_NAME VARCHAR(255) = 'Jedi Knight';

DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Jedi Training - Auto generated';
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'Force Awaken';

DECLARE @FORM_FIELDS AS test.formFields;

SET NOCOUNT ON;

PRINT 'Add Become a Jedi form if not exist';
-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
  name,type,pagename,isActive,isMandatory
)
VALUES ('Is the force with you?','yesNoRadio',@FIRST_PAGE_NAME,1,1)
,('Do have a light saber?','checkbox',@FIRST_PAGE_NAME,1,1)
,('Comment','fDescription',@FIRST_PAGE_NAME,1,1);

EXEC [test].[create_CM_Form]
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@isApproverByLocation = @IS_APPROVER_BY_LOCATION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@FormFields = @FORM_FIELDS;

PRINT 'Become a Jedi form added successfully!';

PRINT CONCAT('Attempt create course: ', @COURSE_NAME,'...');

INSERT INTO [dbo].[cmCourses] (
  [kioskID],[kioskSiteUUID],[courseName]
    ,[courseIsActive],[courseAddedBy],[courseAddedUTC]
    ,[coursePublicKey],[formTypeID]
  ,[coursePrereqIntoText]
  ,[courseDescription]
  ,[coursePostSubmitText]
  ,[courseDuration])
SELECT 
  [questionaire].[kioskID],[questionaire].[kioskSiteUUID],CONCAT(@COURSE_NAME,' - ',[site].[kioskSiteName])
  ,1,0,GETUTCDATE()
  ,NEWID(),[questionaire].[formTypeID]
  ,'Certain Force-sensitive individuals who were strong in the Force and of the proper age would leave their respective families and be taken to the Jedi Temple on Coruscant to begin their Jedi training. Jedi younglings studied in clans of up to twenty individuals, before they underwent the Gathering on Ilum, where they would find the kyber crystals needed to build their lightsabers.'
  ,'Do flying around with lightsaber your true dream life? Follow this course to save the galaxy and fight Stormtroopers.'
  ,'May the force be with you'
  ,'3000 Millions Years'
FROM [dbo].[formType] AS [questionaire]
LEFT JOIN [dbo].[kioskSite] AS [site]
  ON [site].[kioskID] = [questionaire].[kioskID]
  AND [site].[kioskSiteUUID] = [questionaire].[kioskSiteUUID]
LEFT JOIN [dbo].[cmCourses] AS [course]
  ON [course].[kioskID] = [questionaire].[kioskID]
  AND [course].[kioskSiteUUID] = [questionaire].[kioskSiteUUID]
  AND [course].[courseName] = CONCAT(@COURSE_NAME,' - ',[site].[kioskSiteName])
WHERE [questionaire].[formName] = @FORM_NAME
  AND [course].[courseID] IS NULL;

PRINT CONCAT('Course ', @QUALIFICATION_NAME,' create successfully!');

PRINT CONCAT('Attempt create qualification: ', @QUALIFICATION_NAME,'...');

INSERT INTO [dbo].[qualificationReferenceTable](
  [kioskID],[kioskSiteUUID],[qrName]
  ,[isCompany],[isContractor]
)
SELECT [course].[kioskID],[course].[kioskSiteUUID], CONCAT(@QUALIFICATION_NAME,' - ',[site].[kioskSiteName])
,0,1
FROM [dbo].[cmCourses] AS [course]
LEFT JOIN [dbo].[kioskSite] AS [site]
  ON [site].[kioskID] = [course].[kioskID]
  AND [site].[kioskSiteUUID] = [course].[kioskSiteUUID]
LEFT JOIN [dbo].[qualificationReferenceTable] AS [reference]
  ON [reference].[kioskID] = [course].[kioskID]
  AND [reference].[kioskSiteUUID] = [course].[kioskSiteUUID]
  AND [reference].[qrName] = CONCAT(@QUALIFICATION_NAME,' - ',[site].[kioskSiteName])
WHERE [reference].[qrID] IS NULL
  AND [course].[courseName] LIKE CONCAT(@COURSE_NAME,'%');

INSERT INTO [dbo].[contractorQualificationType](
  [kioskID],[kioskSiteUUID]
  ,[cqtName],[qrID]
  ,[cqtIsActive],[cqtIsCompanyQualification]
  ,[cqtAddedBy],[cqtAddedUTC]
  ,[cqtIsMandatory],[cqtValidity]
  ,[cqtAutoAssign],[cqtNotificationDays]
  ,[courseID],[isGlobal],[cqtValidityDays])
SELECT [reference].[kioskID],[reference].[kioskSiteUUID]
,[reference].[qrName],[reference].[qrID]
,1,0
,0,GETUTCDATE()
,1,0
,0,-1
,[course].[courseID],0,0
FROM [dbo].[qualificationReferenceTable] AS [reference]
LEFT JOIN [dbo].[kioskSite] AS [site]
  ON [site].[kioskID] = [reference].[kioskID]
  AND [site].[kioskSiteUUID] = [reference].[kioskSiteUUID]
LEFT JOIN [dbo].[cmCourses] AS [course]
  ON [course].[kioskID] = [reference].[kioskID]
  AND [course].[kioskSiteUUID] = [reference].[kioskSiteUUID]
  AND [course].[courseName] = CONCAT(@COURSE_NAME,' - ',[site].[kioskSiteName])
LEFT JOIN [dbo].[contractorQualificationType] AS [qualification]
  ON [qualification].[kioskID] = [reference].[kioskID]
  AND [qualification].[kioskSiteUUID] = [reference].[kioskSiteUUID]
  AND [qualification].[qrID] = [reference].[qrID]
  AND [qualification].[courseID] = [course].[courseID]
WHERE [qualification].[cqtID] IS NULL
  AND [reference].[qrName] LIKE CONCAT(@QUALIFICATION_NAME,'%');

PRINT CONCAT('Qualification ', @QUALIFICATION_NAME,' create successfully!');