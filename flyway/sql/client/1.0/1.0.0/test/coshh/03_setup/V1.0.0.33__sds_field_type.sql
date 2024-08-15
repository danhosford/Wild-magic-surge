-- =================================================================
-- Author:      Chaitanya Kulkarni
-- Create date: 08/02/2022
-- Description:
-- * This script will ensure to update SDS related values in permitFieldType table.
-- 15/02/2022 - JC - Tidy up the script and removing uneccessary code
-- =================================================================
USE [v3_sp];
SET NOCOUNT ON;

UPDATE [dbo].[permitFieldType]
SET [pftOptionValue] = 'coshhSDSStart'
WHERE [pftOutputValue] = 'COSHH SDS Expiry'

UPDATE [dbo].[permitFieldType]
SET [pftOutputValue] = 'COSHH SDS Start Date'
WHERE [pftOutputValue] = 'COSHH SDS Expiry'