BEGIN
  PRINT 'Add [ptConfinedSpaceEntryLog] into [dbo].[logPermitType] table...';
  ALTER TABLE [dbo].[logPermitType] ADD [ptConfinedSpaceEntryLog] BIT NOT NULL DEFAULT 0;
END