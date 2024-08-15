-- ================================================================================
-- Author:      Jamie Conroy
-- Create date: 11/12/2019
-- Description: Handle the creation of the test.formDropDown table type
-- * 11/12/2019 - AT - Add column for holding value of dropdown option
-- * 12/12/2019 - AT - Rename columns
-- ================================================================================
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

IF TYPE_ID('test.formDropDowns') IS NULL
BEGIN
  /* Create a table type. */  
  CREATE TYPE test.formDropDowns AS TABLE (
    [formName] VARCHAR(255) NOT NULL
    ,[fieldName] VARCHAR(255) NOT NULL
    ,[value] VARCHAR(255) NOT NULL
    ,[alternativeValue] VARCHAR(255)
    ,[isActive] BIT NOT NULL DEFAULT 1
  ); 
END

