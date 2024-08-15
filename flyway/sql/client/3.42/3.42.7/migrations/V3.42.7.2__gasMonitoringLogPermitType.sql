BEGIN
  PRINT 'Add [ptGasMonitoring] into [dbo].[logPermitType] table...';
  ALTER TABLE [dbo].[logPermitType] ADD [ptGasMonitoring] BIT NOT NULL DEFAULT 0;
END