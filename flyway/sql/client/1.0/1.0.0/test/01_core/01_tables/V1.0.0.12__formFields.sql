-- ==========================================================
-- Author:      Shane Gibbons
-- Create date: 04/12/2019
-- Description: Handle the creation of the test.formFields table type
-- ==========================================================
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
	PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END
IF TYPE_ID('test.formFields') IS NULL
BEGIN
  /* Create a table type. */  
	CREATE TYPE test.formFields AS TABLE ( 
		name VARCHAR(255)
		,type VARCHAR(255)
		,pagename VARCHAR(255)
		,isActive BIT
		,isMandatory BIT
		,formFieldWhenToShow INT
		,orderIndex INT IDENTITY(1,1)
		,useDefaultOrder BIT DEFAULT 1
		,maxCharacters INT DEFAULT 500
		,isRandomQuestion BIT DEFAULT 1
	); 
END