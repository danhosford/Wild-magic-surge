/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 01/12/2018 10:31
*/

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Request Product';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'COSHH Request Product - Auto generated';
DECLARE @FORM_APPROVER_LEVEL INT = 1;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_TYPE_REQUEST INT = 1;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'General';

DECLARE @FORM_FIELDS AS test.formFields;

SET NOCOUNT ON;

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
	name,type,pagename,isActive,isMandatory
)
VALUES ('Product Name','coshhProductName',@FIRST_PAGE_NAME,1,1)
,('Supplier Name','coshhProductSupplier',@FIRST_PAGE_NAME,1,1)
,('EHS Manager','coshhApprover',@FIRST_PAGE_NAME,1,1);


EXEC [test].[create_COSHH_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@coshhtype = @FORM_TYPE_REQUEST
,@FormFields = @FORM_FIELDS;
