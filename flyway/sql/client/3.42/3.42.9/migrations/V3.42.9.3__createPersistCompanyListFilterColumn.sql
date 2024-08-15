BEGIN
  PRINT 'Add [persistCompanyListFilter] into [dbo].[kioskSite] table...';
  ALTER TABLE [dbo].[kioskSite] ADD [persistCompanyListFilter] BIT NOT NULL DEFAULT 0;
END