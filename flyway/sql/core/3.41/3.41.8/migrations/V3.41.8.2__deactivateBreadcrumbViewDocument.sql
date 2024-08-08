USE [v3_sp]

UPDATE [dbo].[kioskBreadcrumb]
SET [kbcIsLinkClickable] = 0
WHERE [kbcSection] = 'document'
AND [kbcPage] = 'documentViewApproved'
AND [kbcTitle] = 'View Document'