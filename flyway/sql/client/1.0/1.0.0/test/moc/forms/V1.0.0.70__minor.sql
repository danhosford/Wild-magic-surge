/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 01/12/2018 10:31
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 1;
--DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

DECLARE @FORM_NAME VARCHAR(255) = 'Minor';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'MOC Minor Change to dominate the world - Auto Generated';
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
DECLARE @FIELD_TYPE_APPROVER VARCHAR(255) = 'pApprover';
DECLARE @FIELD_TYPE_MOC_APPROVER VARCHAR(255) = 'mocApprover';
DECLARE @FIELD_TYPE_ATTACHMENT VARCHAR(255) = 'attachment';

INSERT INTO @FORM_FIELDS(
	name,type,pagename,isActive,isMandatory
)
VALUES ('Description',@FIELD_TYPE_DESCRIPTION,@PAGE_NAME,1,1)
,('Date World Domination',@FIELD_TYPE_DATEOFWORKSTART,@PAGE_NAME,1,1)
,('War Room',@FIELD_TYPE_LOCATION,@PAGE_NAME,1,1)
,('Approver',@FIELD_TYPE_MOC_APPROVER,@PAGE_NAME,1,1)
,('Detailed Map',@FIELD_TYPE_ATTACHMENT,@PAGE_NAME,1,0);


EXEC [test].[create_MOC_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@isApproverByLocation = @IS_APPROVER_BY_LOCATION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@moctype = @FORM_TYPE_MINOR
,@FormFields = @FORM_FIELDS;
