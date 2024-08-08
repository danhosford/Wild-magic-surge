BEGIN
  PRINT 'Add [ptGasMonitoring] into [dbo].[permitType] table...';
  ALTER TABLE [dbo].[permitType] ADD [ptGasMonitoring] BIT NOT NULL DEFAULT 0;
END