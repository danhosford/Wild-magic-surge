-- ==========================================================================================
-- Author:      Luis Almeida
-- Create date: 09/12/2019
-- Description: 
-- 09/12/2019 - LA - Created
-- 11/12/2019 - SG - Adding dropdown configuration
-- 19/12/2019 - SG - Adding new call to new workflow actions stored procedure
-- ==========================================================================================
SET NOCOUNT ON;

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Control';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Control';
DECLARE @AFTER_SUBMIT VARCHAR(255) = '';
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_TYPE_REQUEST INT = 1;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'Information';
DECLARE @DISPLAY_TEXT_ONE VARCHAR(255) = 'Add Additional Control';
DECLARE @DISPLAY_TEXT_TWO VARCHAR(255) = 'Complete';
DECLARE @OPEN_VIA VARCHAR(255) = 'dialog';
DECLARE @MAIN_PARENT_NAME VARCHAR(255) = 'Hazard';
DECLARE @CREATE_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @EDIT_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @MODULE_PREFIX VARCHAR(255) = 'risk';

DECLARE @FORM_FIELDS AS test.formFields;
DECLARE @FORM_DROP_DOWN AS test.formDropDowns;
DECLARE @LINK_FIELD AS test.linkFields;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
  [name],[type],[pagename]
  ,[isActive],[isMandatory],[formFieldWhenToShow]
)
VALUES ('Ensure this is an action and not a statement, this must be agreed with the action owner prior to assigning responsibility','sectionDetail',@FIRST_PAGE_NAME,1,0,0)
,('Owner','approverDropDown',@FIRST_PAGE_NAME,1,1,0)
,('Target Completion','dateOfWorkEnd',@FIRST_PAGE_NAME,1,1,0)
,('Control','dropdown',@FIRST_PAGE_NAME,1,1,0)
,('Other','textLine',@FIRST_PAGE_NAME,1,0,0)
,('Status','statuschanger',@FIRST_PAGE_NAME,1,1,1)
,('Note','textarea',@FIRST_PAGE_NAME,1,1,1);

INSERT INTO @FORM_DROP_DOWN(
  [formName],[fieldName],[value]
)
VALUES(@FORM_NAME, 'Control', 'All personnel trained to correct manual handling techniques'),
(@FORM_NAME, 'Control', 'DWB programme in place'),
(@FORM_NAME, 'Control', 'Good housekeeping standards must be maintained'),
(@FORM_NAME, 'Control', 'OTHER'),
(@FORM_NAME, 'Control', 'Personnel must report discomfort to supervisor immediately'),
(@FORM_NAME, 'Control', 'Personnel must report unsafe conditions to supervisor immediately');

INSERT INTO @LINK_FIELD(
[formName],[parent],[name],[when])
VALUES
(@FORM_NAME,'Control','OTHER','Other');

PRINT 'Insert Into form fields table';

EXEC [test].[create_RISK_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@formAfterSubmitCustomFile = @AFTER_SUBMIT
,@FormFields = @FORM_FIELDS;


PRINT 'Add the first workflow action';

EXEC [test].[create_workflow_actions] 
@name = @FORM_NAME
,@MainParentName = @MAIN_PARENT_NAME
,@DisplayText = @DISPLAY_TEXT_ONE
,@OpenVia = @OPEN_VIA
,@kioskid = @KIOSKID;


PRINT 'Add the second workflow action';

EXEC [test].[create_workflow_actions] 
@name = @FORM_NAME
,@MainParentName = @FORM_NAME
,@DisplayText = @DISPLAY_TEXT_TWO
,@OpenVia = @OPEN_VIA
,@kioskid = @KIOSKID;


PRINT 'Populate the risk form groups' 
EXEC [test].[populate_form_groups] 
@formname = @FORM_NAME
,@creategroupname = @CREATE_GROUP
,@editgroupname = @EDIT_GROUP
,@moduleprefix = @MODULE_PREFIX
,@kioskid = @KIOSKID;

PRINT 'Insert Into form drop down table...';

EXEC [test].[populate_formDropDowns] 
@FormDropDown = @FORM_DROP_DOWN,
@kioskid = @KIOSKID;

PRINT 'Link the dropdown tables containing the Controls to the OTHER dropdown';

EXEC [test].[link_dropdwons] 
@linkFields = @LINK_FIELD,
@kioskid = @KIOSKID;