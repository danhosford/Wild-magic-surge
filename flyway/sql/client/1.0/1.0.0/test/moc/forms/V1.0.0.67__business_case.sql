/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 01/12/2018 10:31
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Business Case';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'MOC Business Case - Auto generated';
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_APPROVER_LEVEL INT = 1;
DECLARE @FORM_TYPE_MAJOR INT = 3;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'General';

DECLARE @FORM_FIELDS AS test.formFields;

SET NOCOUNT ON;

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
	name,type,pagename,isActive,isMandatory
)
VALUES ('Project Name','mocBusinessCaseName',@FIRST_PAGE_NAME,1,1)
,('Project Sponsor','mocBusinessCaseSponsor',@FIRST_PAGE_NAME,1,1)
,('Description','fDescription',@FIRST_PAGE_NAME,1,1)
,('Start Date','dateOfWorkStart',@FIRST_PAGE_NAME,1,1)
,('End Date','dateOfWorkEnd',@FIRST_PAGE_NAME,1,1)
,('Location','location',@FIRST_PAGE_NAME,1,1)
,('Approver','mocApprover',@FIRST_PAGE_NAME,1,0);


EXEC [test].[create_MOC_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@isApproverByLocation = @IS_APPROVER_BY_LOCATION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@moctype = @FORM_TYPE_MAJOR
,@FormFields = @FORM_FIELDS;
