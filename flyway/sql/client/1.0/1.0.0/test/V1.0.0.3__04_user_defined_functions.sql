-- =============================================
-- Author:      Alexandre Tran
-- Create date: 01/02/2019
-- Description: Utils function for test
-- =============================================

IF NOT EXISTS (SELECT name FROM sys.schemas WHERE name = N'test')
BEGIN
  PRINT 'Creating the test schema';
    EXEC('CREATE SCHEMA [test] AUTHORIZATION [dbo]');
END

GO

CREATE OR ALTER FUNCTION [test].[RoundTime] (@Time datetime, @RoundTo float) RETURNS datetime
AS
BEGIN
    DECLARE @RoundedTime smalldatetime, @Multiplier float

    SET @Multiplier = 24.0 / @RoundTo;

    SET @RoundedTime= ROUND(CAST(CAST(CONVERT(varchar, @Time, 121) AS datetime) AS float) * @Multiplier, 0) / @Multiplier;

    RETURN @RoundedTime;
END
GO