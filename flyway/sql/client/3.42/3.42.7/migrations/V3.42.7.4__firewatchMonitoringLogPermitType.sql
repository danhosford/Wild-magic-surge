BEGIN
  PRINT 'Add [ptFireWatchMonitoring] into [dbo].[logPermitType] table...';
  ALTER TABLE [dbo].[logPermitType] ADD [ptFireWatchMonitoring] BIT NOT NULL DEFAULT 0;
END