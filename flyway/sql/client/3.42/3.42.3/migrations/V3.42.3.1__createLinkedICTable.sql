SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[permitLinkedIC](
	[permitLinkedICID]  [int] IDENTITY(1,1) NOT NULL,
	[permitPublicKey] [varchar](255) NOT NULL,
    [icID] [varchar](255) NOT NULL,
	[kioskID] [int] NOT NULL,
	[kioskSiteUUID] [varchar](255) NULL,
	[isActive] BIT NOT NULL,
	[linkedUTC] [datetime] NOT NULL,
    [linkedBy] [int] NOT NULL,
    [unlinkedUTC] [datetime] NULL,
    [unlinkedBy] [int] NULL
 CONSTRAINT [PK_permitLinkedICID_1] PRIMARY KEY CLUSTERED 
(
	permitLinkedICID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO