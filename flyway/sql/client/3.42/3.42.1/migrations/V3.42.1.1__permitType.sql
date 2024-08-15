
BEGIN
  PRINT 'Add [showHTMLQRCode] into [dbo].[permitTemplate] table...';
  ALTER TABLE [dbo].[permitTemplate] ADD [showHTMLQRCode] INT NOT NULL DEFAULT 1;
END

BEGIN
  PRINT 'Add [QRCodeXPosition] into [dbo].[permitTemplate] table...';
  ALTER TABLE [dbo].[permitTemplate] ADD QRCodeXPosition INT NOT NULL DEFAULT 100;
END

BEGIN
  PRINT 'Add [QRCodeYPosition] into [dbo].[permitTemplate] table...';
  ALTER TABLE [dbo].[permitTemplate] ADD QRCodeYPosition INT NOT NULL DEFAULT 100;
END

BEGIN
  PRINT 'Add [showPDFQRCode] into [dbo].[permitTemplate] table...';
  ALTER TABLE [dbo].[permitTemplate] ADD showPDFQRCode INT NOT NULL DEFAULT 0;
END