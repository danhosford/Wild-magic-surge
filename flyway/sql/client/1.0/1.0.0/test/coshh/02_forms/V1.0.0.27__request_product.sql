-- ==========================================================
-- Author:      Alexandre Tran
-- Create date: 01/12/2018
-- Description: TESTING ONLY SCRIPT - Setup COSHH Product
-- * 01/12/2018 - AT - Created
-- * 11/05/2020 - AT - Set up admin form type
-- * 11/05/2020 - AT - Set up approver
-- * 07/06/2020 - AT - Move set up approver group to its own
-- ==========================================================

SET NOCOUNT ON;

-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @PASS VARCHAR(255) = '$(OLS_KEY_PASS)';
DECLARE @FORM_NAME VARCHAR(255) = 'Request Product';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'COSHH Request Product - Auto generated';
DECLARE @FORM_APPROVER_LEVEL INT = 1;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_TYPE_REQUEST INT = 1;
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'General';

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
VALUES ('Product Name','coshhProductName',@FIRST_PAGE_NAME,1,1)
,('Supplier Name','coshhProductSupplier',@FIRST_PAGE_NAME,1,1)
,('Supplier Address','coshhProductSupplierAddress',@FIRST_PAGE_NAME,1,1)
,('Supplier Phone Number','coshhProductSupplierNumber',@FIRST_PAGE_NAME,1,1)
,('Container Size','coshhContainerSize',@FIRST_PAGE_NAME,1,1)
,('Container Unit','coshhContainerSizeUnit',@FIRST_PAGE_NAME,1,1)
,('EHS Manager','coshhApprover',@FIRST_PAGE_NAME,1,1)
,('Area to be used in','textLine',@FIRST_PAGE_NAME,1,1)
,('Possible Areas of Use','textLine',@FIRST_PAGE_NAME,1,1)
,('Storage Location','locationTree',@FIRST_PAGE_NAME,1,1)
,('SDS Expiry Date','coshhSDSExpiry',@FIRST_PAGE_NAME,1,1)
,('Electronic SDS Attachment','coshhSDSAttachment',@FIRST_PAGE_NAME,1,1);

PRINT 'Setup initial COSHH Product default form...';

EXEC [test].[create_COSHH_form] 
@name = @FORM_NAME
,@description = @FORM_DESCRIPTION
,@ApproverLevel = @FORM_APPROVER_LEVEL
,@coshhtype = @FORM_TYPE_REQUEST
,@FormFields = @FORM_FIELDS;

PRINT 'Setup administration COSHH Product settings...';

SET @results = 1;
SET @count = 0;

WHILE (@results > 0)
BEGIN

  SET @starttime = GETUTCDATE();

  INSERT INTO [formTypeAdministrationSetting](
  [formTypeAdministrationSettingIsActive],[formTypeAdministrationSettingFormType]
  ,[formTypeAdministrationSettingCreateBy],[formTypeAdministrationSettingCreateUTC]
  ,[formTypePublicKey],[kioskID],[kioskSiteUUID])
  SELECT TOP(@batchSize) 1,@FORM_TYPE_REQUEST,0,GETUTCDATE()
  ,[type].[formTypePublicKey],[type].[kioskID],[type].[kioskSiteUUID]
  FROM [dbo].[formType] AS [type]
  LEFT JOIN [dbo].[formTypeAdministrationSetting] AS [register]
    ON [register].[kioskID] = [type].[kioskID]
    AND [register].[kioskSiteUUID] = [type].[kioskSiteUUID]
    AND [register].[formTypePublicKey] = [type].[formTypePublicKey]
  WHERE [register].[formTypeAdministrationSettingID] IS NULL
    AND [type].[formName] = @FORM_NAME
    AND [type].[formNarrative] = @FORM_DESCRIPTION;

  -- Get rowcount to avoid infinite loop
  SET @results = @@ROWCOUNT
  SET @count = @count + @results;
  SET @endtime = GETUTCDATE();
  SET @difftime = DATEDIFF(MILLISECOND, @starttime, @endtime);
  RAISERROR('Cumulative COSHH Product settings administration setup: %d ---- Execution time: %I64d ms', 0, 1, @count,@difftime) WITH NOWAIT;

  CHECKPOINT;

END

SET @endScriptTime = GETUTCDATE();
SET @difftime = DATEDIFF(MILLISECOND, @startScriptTime, @endScriptTime);
RAISERROR('Script execution time: %I64d ms', 0, 1,@difftime) WITH NOWAIT;