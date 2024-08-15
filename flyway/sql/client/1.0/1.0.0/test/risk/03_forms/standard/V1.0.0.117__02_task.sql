-- ==========================================================================================
-- Author:      Brendan O'Loughlin
-- Create date: 10/12/2019
-- Description: Creates Task Risk Assessment From
-- 10/12/2019 - BOL - Created
-- 19/12/2019 - SG - Adding new call to new workflow actions stored procedure
-- ==========================================================================================
SET NOCOUNT ON;

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Task';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Add a Task';
DECLARE @AFTER_SUBMIT VARCHAR(255) = '';
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_TYPE_REQUEST INT = 1;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'Details';
DECLARE @MAIN_PARENT_NAME VARCHAR(255) = 'Risk Assessment';
DECLARE @DISPLAY_TEXT VARCHAR(255) = 'Add Additional Task'
DECLARE @OPEN_VIA VARCHAR(255) = 'Dialog'
DECLARE @CREATE_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @EDIT_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @MODULE_PREFIX VARCHAR(255) = 'risk';

DECLARE @FORM_FIELDS AS test.formFields;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
  [name],[type],[pagename]
  ,[isActive],[isMandatory],[formFieldWhenToShow]
)
VALUES ('Description of Task','textarea',@FIRST_PAGE_NAME,1,1,0);


EXEC [test].[create_RISK_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@formAfterSubmitCustomFile = @AFTER_SUBMIT
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
