-- ==========================================================================================
-- Author:      Shane Gibbons
-- Create date: 27/11/2019
-- Description: Hazard script form
-- * 27/11/2019 - SG - Created
-- * 11/12/2019 - SG - Configuring dropdowns and inserting all values in formDropDown
-- * 08/01/2020 - AT - Move configuration link field to top
-- ==========================================================================================

SET NOCOUNT ON;
-- Default Script Setting
DECLARE @DEBUG BIT = 0;

DECLARE @FORM_NAME VARCHAR(255) = 'Hazard';
DECLARE @FORM_DESCRIPTION VARCHAR(255) = 'Hazard - Auto generated';
DECLARE @FORM_APPROVER_LEVEL INT = 0;
DECLARE @IS_APPROVER_BY_LOCATION BIT = 0;
DECLARE @FORM_AFTER_SUBMIT_CUSTOM_FILE VARCHAR(255) = '';
DECLARE @FIRST_PAGE_NAME VARCHAR(255) = 'Details';
DECLARE @DISPLAY_TEXT VARCHAR(255) = 'Add Hazard';
DECLARE @OPEN_VIA VARCHAR(255) = 'dialog';
DECLARE @MAIN_PARENT_NAME VARCHAR(255) = 'Task';
DECLARE @CREATE_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @EDIT_GROUP VARCHAR(255) = 'RISK Super Admin';
DECLARE @MODULE_PREFIX VARCHAR(255) = 'risk';

DECLARE @FORM_FIELDS AS test.formFields;
DECLARE @FORM_DROP_DOWN AS test.formDropDowns;
DECLARE @LINK_FIELD AS test.linkFields;
DECLARE @KIOSKID INT = dbo.udf_GetKioskID(db_name());

PRINT 'Insert Into form fields table...';
-- Set Field type name variable
INSERT INTO @FORM_FIELDS(
	[name],[type],[pagename],[isActive],[isMandatory],[formFieldWhenToShow]
)
VALUES ('Hazards','dropdown',@FIRST_PAGE_NAME,1,1,0)
,('Other','textline',@FIRST_PAGE_NAME,1,0,0)
,('Potential Harm','dropdown',@FIRST_PAGE_NAME,1,1,0)
,('Who could be harmed&#x3f;','dropdown',@FIRST_PAGE_NAME,1,1,0)
,('Risk Value','riskRating',@FIRST_PAGE_NAME,1,0,0)
,('Risk Likelihood','dropdown',@FIRST_PAGE_NAME,1,0,0)
,('Risk Severity','dropdown',@FIRST_PAGE_NAME,1,0,0)
,('Existing Controls in place','textarea',@FIRST_PAGE_NAME,1,1,0)
,('REMINDER&#x3a; It is unusual but not impossible for the residual severity to decrease, is this accurate&#x3f;','sectionDetail',@FIRST_PAGE_NAME,1,0,0)
,('Residual Risk Value','riskRating',@FIRST_PAGE_NAME,1,0,0)
,('Risk Likelihood','dropdown',@FIRST_PAGE_NAME,1,0,0)
,('Risk Severity','dropdown',@FIRST_PAGE_NAME,1,0,0);

INSERT INTO @FORM_DROP_DOWN(
  [formName],[fieldName],[value],[alternativeValue]
)
VALUES(@FORM_NAME, 'Hazards', 'Biological Agents &#x28;Legionella, Pathogens etc.&#x29;', NULL),
(@FORM_NAME, 'Hazards', 'Blades&#x2f;Sharp Object', NULL),
(@FORM_NAME, 'Hazards', 'Chemical&#x2f;Hazardous Substances', NULL),
(@FORM_NAME, 'Hazards', 'Compressed gas', NULL),
(@FORM_NAME, 'Hazards', 'Confined Space', NULL),
(@FORM_NAME, 'Hazards', 'Dust', NULL),
(@FORM_NAME, 'Hazards', 'Electricity', NULL),
(@FORM_NAME, 'Hazards', 'Equipment', NULL),
(@FORM_NAME, 'Hazards', 'Ergonomic', NULL),
(@FORM_NAME, 'Hazards', 'Explosion', NULL),
(@FORM_NAME, 'Hazards', 'Falling Object', NULL),
(@FORM_NAME, 'Hazards', 'Fire', NULL),
(@FORM_NAME, 'Hazards', 'Flying Particles', NULL),
(@FORM_NAME, 'Hazards', 'Fumes', NULL),
(@FORM_NAME, 'Hazards', 'Hot Object', NULL),
(@FORM_NAME, 'Hazards', 'Lighting', NULL),
(@FORM_NAME, 'Hazards', 'Lone Worker', NULL),
(@FORM_NAME, 'Hazards', 'Machinery', NULL),
(@FORM_NAME, 'Hazards', 'Manual Handling', NULL),
(@FORM_NAME, 'Hazards', 'Noise', NULL),
(@FORM_NAME, 'Hazards', 'OTHER&#x3a;', NULL),
(@FORM_NAME, 'Hazards', 'Radiation', NULL),
(@FORM_NAME, 'Hazards', 'Slip&#x2c; Trip&#x2c; Fall', NULL),
(@FORM_NAME, 'Hazards', 'Space', NULL),
(@FORM_NAME, 'Hazards', 'Stairs', NULL),
(@FORM_NAME, 'Hazards', 'Vehicles', NULL),
(@FORM_NAME, 'Hazards', 'Work at Height &#x28;Incl. Use of Ladders&#x29;', NULL),
(@FORM_NAME, 'Potential Harm', 'Cut&#x2f;Laceration', NULL),
(@FORM_NAME, 'Potential Harm', 'Bruise', NULL),
(@FORM_NAME, 'Potential Harm', 'Fracture', NULL),
(@FORM_NAME, 'Potential Harm', 'Amputation', NULL),
(@FORM_NAME, 'Potential Harm', 'Hearing Loss&#x2f;Impairment', NULL),
(@FORM_NAME, 'Potential Harm', 'Muscular Strain', NULL),
(@FORM_NAME, 'Potential Harm', 'Sprain', NULL),
(@FORM_NAME, 'Potential Harm', 'Burn', NULL),
(@FORM_NAME, 'Potential Harm', 'Irritation to Eyes', NULL),
(@FORM_NAME, 'Potential Harm', 'Irritation to Skin', NULL),
(@FORM_NAME, 'Potential Harm', 'Puncture', NULL),
(@FORM_NAME, 'Potential Harm', 'Foreign object in Eye', NULL),
(@FORM_NAME, 'Potential Harm', 'Back Strain', NULL),
(@FORM_NAME, 'Who could be harmed&#x3f;', 'All Employees', NULL),
(@FORM_NAME, 'Who could be harmed&#x3f;', 'Contractor', NULL),
(@FORM_NAME, 'Who could be harmed&#x3f;', 'Everyone', NULL),
(@FORM_NAME, 'Who could be harmed&#x3f;', 'Visitor &#x28;s&#x29;', NULL),
(@FORM_NAME, 'Risk Likelihood', '1. Almost Impossible', '1'),
(@FORM_NAME, 'Risk Likelihood', '2. Unlikely', '2'),
(@FORM_NAME, 'Risk Likelihood', '3. Possible', '3'),
(@FORM_NAME, 'Risk Likelihood', '4. Likely', '4'),
(@FORM_NAME, 'Risk Likelihood', '5. Almost certain', '5'),
(@FORM_NAME, 'Risk Severity', '1. Insignificant', '1'),
(@FORM_NAME, 'Risk Severity', '2. Minor', '2'),
(@FORM_NAME, 'Risk Severity', '3. Serious', '3'),
(@FORM_NAME, 'Risk Severity', '4. Significant', '4'),
(@FORM_NAME, 'Risk Severity', '5. Severe', '5');

INSERT INTO @LINK_FIELD(
[formName],[parent],[name],[when])
VALUES
(@FORM_NAME,'Risk Value','Risk Likelihood',''),
(@FORM_NAME,'Risk Value','Risk Severity',''),
(@FORM_NAME,'Residual Risk Value','Risk Likelihood',''),
(@FORM_NAME,'Residual Risk Value','Risk Severity','');

PRINT 'Insert Into form fields table...';

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

PRINT 'Insert Into form drop down table...';
EXEC [test].[populate_formDropDowns] 
@FormDropDown = @FORM_DROP_DOWN,
@kioskid = @KIOSKID;

PRINT 'Link the dropdown tables containing the Hazards to the OTHER dropdown';
INSERT INTO @LINK_FIELD(
[formName],[parent],[name],[when])
VALUES
(@FORM_NAME,'Hazards','OTHER&#x3a;','Other')

EXEC [test].[link_dropdwons] 
@linkFields = @LINK_FIELD,
@kioskid = @KIOSKID;

PRINT 'Link the risk rating fields';

EXEC [test].[link_risk_rating_fields] 
@linkFields = @LINK_FIELD,
@kioskid = @KIOSKID;