BEGIN
  PRINT 'Add [ptCanModifySecondaryApprover] into [dbo].[logPermitType] table...';
  ALTER TABLE [dbo].[logPermitType] ADD [ptCanModifySecondaryApprover] BIT NOT NULL DEFAULT 0;
END