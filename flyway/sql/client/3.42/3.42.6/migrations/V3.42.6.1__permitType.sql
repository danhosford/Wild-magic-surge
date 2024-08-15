BEGIN
  PRINT 'Add [ptCanModifySecondaryApprover] into [dbo].[permitType] table...';
  ALTER TABLE [dbo].[permitType] ADD [ptCanModifySecondaryApprover] BIT NOT NULL DEFAULT 0;
END