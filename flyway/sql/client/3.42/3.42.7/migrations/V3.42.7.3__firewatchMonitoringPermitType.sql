BEGIN
  PRINT 'Add [ptFireWatchMonitoring] into [dbo].[permitType] table...';
  ALTER TABLE [dbo].[permitType] ADD [ptFireWatchMonitoring] BIT NOT NULL DEFAULT 0;
END