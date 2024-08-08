BEGIN
  PRINT 'Add [paDeactivateBy] into [dbo].[permitCreateApprover] table...';
  ALTER TABLE [dbo].[permitCreateApprover] ADD [paDeactivateBy] INT NULL DEFAULT NULL;
END