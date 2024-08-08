SET QUOTED_IDENTIFIER ON
GO

-- Create new permitLinkedICKafka history table for tracking and processing of kafka messages for permitLinkedICs
CREATE TABLE [dbo].[permitLinkedICKafkaHistory](
	[permitLinkedICKafkaHistoryID]  [int] IDENTITY(1,1) NOT NULL,
	[permitPublicKey] [varchar](255) NOT NULL,
    [isolationCertificateID] [varchar](255) NOT NULL,
	[kioskID] [int] NOT NULL,
	[kioskSiteUUID] [varchar](255) NULL,
	[isActive] BIT NOT NULL,
	[linkedUTC] [datetime] NOT NULL,
    [linkedBy] [uniqueidentifier] NOT NULL,
    [unlinkedUTC] [datetime] NULL,
    [unlinkedBy] [uniqueidentifier] NULL,
	[updatedUTC] [datetime] NOT NULL,
    [processed] BIT NOT NULL,
	[processedUTC] [datetime] NULL,
	[produced] BIT NOT NULL,
	[producedUTC] [datetime] NULL,
	[retryCount] [int] NOT NULL,
	[errorMessage] [varchar](1000) NULL,
 CONSTRAINT [PK_permitLinkedICKafkaHistory] PRIMARY KEY CLUSTERED 
(
	permitLinkedICKafkaHistoryID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

-- Adding index
CREATE INDEX idx_permitLinkedICKafkaHistory_scheduled_task
    ON [dbo].[permitLinkedICKafkaHistory] (updatedUTC, processed);
GO

-- Insert existing data from permitLinkedIC into permitLinkedICKafkaHistory
INSERT INTO permitLinkedICKafkaHistory (permitPublicKey, isolationCertificateID, kioskID, kioskSiteUUID, isActive, linkedUTC, linkedBy, unlinkedUTC, unlinkedBy, updatedUTC, processed, produced, retryCount)
SELECT permitPublicKey, isolationCertificateID, kioskID, kioskSiteUUID, isActive, linkedUTC, linkedBy, unlinkedUTC, unlinkedBy, 
       CASE WHEN unlinkedUTC IS NULL THEN linkedUTC ELSE unlinkedUTC END AS updatedUTC,
       0 AS processed, 0 AS produced, 0 AS retryCount
FROM permitLinkedIC;

