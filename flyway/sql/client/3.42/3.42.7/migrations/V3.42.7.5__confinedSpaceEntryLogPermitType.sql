BEGIN
  PRINT 'Add [ptConfinedSpaceEntryLog] into [dbo].[permitType] table...';
  ALTER TABLE [dbo].[permitType] ADD [ptConfinedSpaceEntryLog] BIT NOT NULL DEFAULT 0;
END