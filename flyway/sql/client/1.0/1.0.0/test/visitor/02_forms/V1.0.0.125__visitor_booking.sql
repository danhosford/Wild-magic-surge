-- ==========================================================
-- Author:      Jamie Conroy
-- Create date: 25/11/2020
-- Description: TESTING ONLY SCRIPT - Setup Visitor Booking Form
-- * 25/11/2020 - JC - Created
-- ==========================================================

SET NOCOUNT ON;

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';
DECLARE @FORM_PREFIX VARCHAR(255) = 'visitor';
DECLARE @FORM_NAME VARCHAR(255) = 'Visitor Booking Form';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Visitor Booking Form';
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_TYPE_REQUEST INT = 1;
DECLARE @SECOND_PAGE_NAME VARCHAR(255) = 'Visitor Details';
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'Visit Details';
DECLARE @FORM_AFTER_SUBMIT_CUSTOM_FILE VARCHAR(255) = '/SafePermitApp/visitor/visitorCreate/visitorCustomCreateSubmit_after.cfm'

DECLARE @FORM_FIELDS AS test.formFields;

DECLARE @count INT = 0;
DECLARE @batchSize INT = 500;
DECLARE @results INT = 1;
DECLARE @starttime DATETIME;
DECLARE @endtime DATETIME;
DECLARE @difftime BIGINT;
DECLARE @startScriptTime DATETIME = GETUTCDATE();
DECLARE @endScriptTime DATETIME;

IF (@PASS = CONCAT('$','(OLS_KEY_PASS)') OR @PASS = '')
BEGIN
    RAISERROR (N'OLS_KEY_PASS is required! Ensure it is set as environment variable and/or running in sqlcmd Mode.',18,-1);
    RETURN
END

-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
  name,type,pagename,isActive,isMandatory
)
VALUES
('Visitor Type','visitorType',@FIRST_PAGE_NAME,1,1)
,('Delivery Driver Picture','attachment',@FIRST_PAGE_NAME,1,0)
,('Registration Number of Delivery Driver','textLine',@FIRST_PAGE_NAME,1,0)
,('Delivery Item Detail','textarea',@FIRST_PAGE_NAME,1,0)
,('Person Responsible for Receipt of Goods','textLine',@FIRST_PAGE_NAME,1,0)
,('Visitor','visitorDetails',@FIRST_PAGE_NAME,1,1)
,('Company','visitorCompanyDropDown',@FIRST_PAGE_NAME,1,1)
-- Second Page
,('Date Arriving','dateOfWorkStart',@SECOND_PAGE_NAME,1,1)
,('Time Arriving','timeOfWorkStart',@SECOND_PAGE_NAME,1,1)
,('Date Leaving','dateOfWorkEnd',@SECOND_PAGE_NAME,1,1)
,('Time Leaving','timeOfWorkEnd',@SECOND_PAGE_NAME,1,1)
,('Visiting','visitingDropDown',@SECOND_PAGE_NAME,1,0)
,('Location','visitorLocation',@SECOND_PAGE_NAME,1,1)
,('Additional Location Details','visitorAdditionalLocation',@SECOND_PAGE_NAME,1,0);

PRINT 'Setup initial visitor booking default form...';

EXEC [test].[create_VISITOR_form] 
@name = @FORM_NAME
,@prefix = @FORM_PREFIX
,@description = @FORM_DESCRIPTION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@formAfterSubmitCustomFile = @FORM_AFTER_SUBMIT_CUSTOM_FILE
,@visitorType = @FORM_TYPE_REQUEST
,@FormFields = @FORM_FIELDS;