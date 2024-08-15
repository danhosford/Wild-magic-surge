ALTER TABLE [dbo].[email_notification]
    ADD CONSTRAINT [df_email_notification_id] DEFAULT NEWID() FOR [id];
GO
