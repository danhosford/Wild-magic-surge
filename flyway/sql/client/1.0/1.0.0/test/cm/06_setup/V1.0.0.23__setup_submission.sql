-- =============================================
-- Author:      Alexandre Tran
-- Create date: 10/10/2019
-- Description: Setup path file for submission
-- =============================================

PRINT 'Set up before and after submission for course...';
UPDATE [dbo].[formType]
SET [formBeforeSubmitCustomFile] = '/SafePermitApp/course/courseCreateSubmit/courseCustomCreateSubmit_before.cfm'
,[formAfterSubmitCustomFile] = '/SafePermitApp/course/courseCreateSubmit/courseCustomCreateSubmit_after.cfm'
WHERE formModuleID = 5