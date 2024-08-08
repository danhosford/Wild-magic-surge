IF COL_LENGTH('[document_approval]', 'uuid') IS NULL
BEGIN
  PRINT 'Add [uuid] into [dbo].[document_approval] table...';
  ALTER TABLE [dbo].[document_approval] ADD [uuid] UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID();
END