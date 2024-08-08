BEGIN
  PRINT 'Add [paDeactivateUTC] into [dbo].[permitCreateApprover] table...';
  ALTER TABLE [dbo].[permitCreateApprover] ADD [paDeactivateUTC] DATETIME NULL DEFAULT NULL;
END