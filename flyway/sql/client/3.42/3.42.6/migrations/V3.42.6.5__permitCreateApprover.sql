BEGIN
  PRINT 'Add [paInactive] into [dbo].[permitCreateApprover] table...';
  ALTER TABLE [dbo].[permitCreateApprover] ADD [paIsActive] BIT NOT NULL DEFAULT 1;
END
