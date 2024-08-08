-- ==========================================================
-- Author:      Alexandre Tran
-- Create date: 12/12/2019
-- Description: Type for linking field together
-- ==========================================================
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

IF TYPE_ID('test.linkFields') IS NULL
BEGIN
  /* Create a table type. */  
  CREATE TYPE test.linkFields AS TABLE (
    [formName] VARCHAR(255) NOT NULL
    ,[parent] VARCHAR(255) NOT NULL
    ,[name] VARCHAR(255) NOT NULL
    ,[when] VARCHAR(255) NOT NULL
    ,[mandatory] BIT NOT NULL DEFAULT 1
  ); 
END

