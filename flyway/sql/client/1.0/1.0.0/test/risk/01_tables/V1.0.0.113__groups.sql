-- ================================================================================
-- Author:      Alexandre Tran
-- Create date: 17/12/2019
-- Description: Table type for holding group permission
-- ================================================================================
IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
  EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

IF TYPE_ID('test.groups') IS NULL
BEGIN
  /* Create a table type. */  
  CREATE TYPE test.groups AS TABLE (
    [site] VARCHAR(255) NOT NULL
    ,[requestor] VARCHAR(255) NOT NULL
    ,[admin] VARCHAR(255) NOT NULL
    ,[taskowner] VARCHAR(255) NOT NULL
  );
END
GO