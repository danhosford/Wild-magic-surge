-- ==========================================================================================
-- Author:      Alexandre Tran
-- Create date: 23/09/2019
-- Description: 
-- 23/09/2019 - AT - Created
-- 12/12/2019 - JC - Added in the following 
-- 1) Declare and configuration of variables
-- 2) Insert into Form_fields table
-- 3) Insert into Form Drop down table
-- 4) Link the department dropdown to the business unit dropdown
-- 19/12/2019 - SG - Adding new call to new workflow actions stored procedure
-- ==========================================================================================
SET NOCOUNT ON;

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Risk Assessment';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Risk Assessment - Auto generated';
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_AFTER_SUBMIT_CUSTOM_FILE VARCHAR(255) = '/SafePermitApp/risk/riskCreate/riskCustomCreateSubmit_after.cfm'
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'Details';
DECLARE @DISPLAY_TEXT VARCHAR(255) = 'Approve';
DECLARE @OPEN_VIA VARCHAR(255) = 'dialog';
DECLARE @MAIN_PARENT_NAME VARCHAR(255) = 'Risk Assessment';
DECLARE @CREATE_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @EDIT_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @MODULE_PREFIX VARCHAR(255) = 'risk';

DECLARE @FORM_FIELDS AS test.formFields;
DECLARE @FORM_DROP_DOWN AS test.formDropDowns;
DECLARE @LINK_FIELD AS test.linkFields;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
  [name],[type],[pagename],[isActive],[isMandatory],[formFieldWhenToShow]
)
VALUES ('Activity','fDescription',@FIRST_PAGE_NAME,1,1,0)
,('Business Unit','dropdown',@FIRST_PAGE_NAME,1,1,0)
,('Department East','dropdown',@FIRST_PAGE_NAME,1,0,0)
,('Department West','dropdown',@FIRST_PAGE_NAME,1,0,0)
,('Area Level 1','location',@FIRST_PAGE_NAME,1,1,0)
,('Area Level 2','locationLevel2CFC',@FIRST_PAGE_NAME,1,0,0)
,('Area Level 3','locationLevel3CFC',@FIRST_PAGE_NAME,1,0,0)
,('Approver','approverDropDown',@FIRST_PAGE_NAME,1,1,0)
,('Approval Status','statuschanger',@FIRST_PAGE_NAME,1,1,1)
,('Approval Comment','textarea',@FIRST_PAGE_NAME,1,1,1);

INSERT INTO @FORM_DROP_DOWN(
  [formName],[fieldName],[value]
)
VALUES(@FORM_NAME,'Business Unit','East Office'),
(@FORM_NAME,'Business Unit','West Office'),
(@FORM_NAME,'Business Unit','South Office'),
(@FORM_NAME,'Business Unit','North Office'),
(@FORM_NAME,'Department East','Management'),
(@FORM_NAME,'Department East','Security'),
(@FORM_NAME,'Department East','Quality Assurance'),
(@FORM_NAME,'Department East','Development'),
(@FORM_NAME,'Department East','Customer Success'),
(@FORM_NAME,'Department West','Finance'),
(@FORM_NAME,'Department West','Human Resources'),
(@FORM_NAME,'Department West','Sales'),
(@FORM_NAME,'Department West','Marketing');

INSERT INTO @LINK_FIELD(
[formName],[parent],[name],[when])
VALUES
(@FORM_NAME,'Business Unit','Department East','East Office'),
(@FORM_NAME,'Business Unit','Department West','West Office');

EXEC [test].[create_RISK_Form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@formAfterSubmitCustomFile = @FORM_AFTER_SUBMIT_CUSTOM_FILE
,@FormFields = @FORM_FIELDS;


PRINT 'Add the workflow action';

EXEC [test].[create_workflow_actions] 
@name = @FORM_NAME
,@MainParentName = @MAIN_PARENT_NAME
,@DisplayText = @DISPLAY_TEXT
,@OpenVia = @OPEN_VIA
,@kioskid = @KIOSKID;


PRINT 'Populate the risk form groups' 
EXEC [test].[populate_form_groups] 
@formname = @FORM_NAME
,@creategroupname = @CREATE_GROUP
,@editgroupname = @EDIT_GROUP
,@moduleprefix = @MODULE_PREFIX
,@kioskid = @KIOSKID;


PRINT 'Insert Into form fields table...';

EXEC [test].[populate_formDropDowns] 
@FormDropDown = @FORM_DROP_DOWN,
@kioskid = @KIOSKID;

PRINT 'Link the dropdown tables containing the departments to the business unit dropdown';

EXEC [test].[link_dropdwons] 
@linkFields = @LINK_FIELD,
@kioskid = @KIOSKID;