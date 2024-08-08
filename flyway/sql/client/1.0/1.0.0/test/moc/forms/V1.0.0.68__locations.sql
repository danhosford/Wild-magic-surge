/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 26/01/2018 10:31
- Create MOC form with multi location
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 1;
--DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

DECLARE @FORM_NAME VARCHAR(255) = 'Locations';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'MOC Multilocation - Auto Generated';
DECLARE @FORM_APPROVER_LEVEL INT = 1;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_TYPE_MINOR INT = 1;
DECLARE @PAGE_NAME VARCHAR(255) = 'General';

DECLARE @FORM_FIELDS AS test.formFields;

SET NOCOUNT ON;

-- Set Field type name variable
--SELECT 
--      [pfdFieldType]
--      ,CONCAT('DECLARE @FIELD_TYPE_',UPPER(RIGHT([pfdFieldType],LEN([pfdFieldType]) - 1)), ' VARCHAR(255) = ''',[pfdFieldType],''';')
--  FROM [v3_sp].[dbo].[permitFieldDefault];

DECLARE @FIELD_TYPE_DESCRIPTION VARCHAR(255) = 'fDescription';
DECLARE @FIELD_TYPE_DATEOFWORKSTART VARCHAR(255) = 'dateOfWorkStart';
DECLARE @FIELD_TYPE_LOCATION VARCHAR(255) = 'location';
DECLARE @FIELD_TYPE_LOCATION2 VARCHAR(255) = 'locationLevel2CFC';
DECLARE @FIELD_TYPE_LOCATION3 VARCHAR(255) = 'locationLevel3CFC';
DECLARE @FIELD_TYPE_APPROVER VARCHAR(255) = 'pApprover';
DECLARE @FIELD_TYPE_MOC_APPROVER VARCHAR(255) = 'mocApprover';
DECLARE @FIELD_TYPE_MOC_ACTIONTASK VARCHAR(255) = 'mocActionTask';

INSERT INTO @FORM_FIELDS(
	name,type,pagename,isActive,isMandatory
)
VALUES ('Description',@FIELD_TYPE_DESCRIPTION,@PAGE_NAME,1,1)
,('Date Start',@FIELD_TYPE_DATEOFWORKSTART,@PAGE_NAME,1,1)
,('Level1',@FIELD_TYPE_LOCATION,@PAGE_NAME,1,1)
,('Level2',@FIELD_TYPE_LOCATION2,@PAGE_NAME,1,1)
,('Level3',@FIELD_TYPE_LOCATION3,@PAGE_NAME,1,1)
,('Approver',@FIELD_TYPE_MOC_APPROVER,@PAGE_NAME,1,1)
,('Action Task 1',@FIELD_TYPE_MOC_ACTIONTASK,@PAGE_NAME,1,0);


EXEC [test].[create_MOC_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@isApproverByLocation = @IS_APPROVER_BY_LOCATION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@moctype = @FORM_TYPE_MINOR
,@FormFields = @FORM_FIELDS;
