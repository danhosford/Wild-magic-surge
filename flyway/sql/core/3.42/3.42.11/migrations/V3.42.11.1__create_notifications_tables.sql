/*
    Created At: 28/06/2024
    Create table for storing customer email notification information
*/
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[email_notification]
(
    [id]                UNIQUEIDENTIFIER NOT NULL,
    [customer_id]       UNIQUEIDENTIFIER NOT NULL,
    [location_id]       UNIQUEIDENTIFIER NOT NULL,
    [notification_type] NVARCHAR(255)    NOT NULL,
    [module_type]       NVARCHAR(255)    NOT NULL,
    [recipient_list]    NVARCHAR(1000)   NOT NULL,
    [subject]           NVARCHAR(1000)   NOT NULL,
    [body]              NVARCHAR(MAX)    NOT NULL,
    [processed]         BIT              NOT NULL DEFAULT 0,
    [processed_at]      DATETIMEOFFSET,
    [dispatched]        BIT              NOT NULL DEFAULT 0,
    [dispatched_at]     DATETIMEOFFSET,
    [retry_count]       SMALLINT         NOT NULL DEFAULT 0,
    [error_message]     NVARCHAR(3000),
    [created_by]        UNIQUEIDENTIFIER,
    [created_at]        DATETIMEOFFSET   NOT NULL,
    [updated_at]        DATETIMEOFFSET   NOT NULL,
    CONSTRAINT [pk_email_notification] PRIMARY KEY ([id])
);

-- Create unique index for processed column
CREATE INDEX [idx_dispatched_processed_module_type] ON [dbo].[email_notification] ([dispatched], [processed], [module_type]);
GO