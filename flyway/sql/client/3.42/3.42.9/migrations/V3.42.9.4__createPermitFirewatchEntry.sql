SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[permitFirewatchMonitoring]
(
    [pfmID]            [int] IDENTITY (1,1) NOT NULL,
    [permitPublicKey]  [varchar](255)       NOT NULL,
    [entryDateTimeUTC] [datetime]           NOT NULL,
    [firewatchResults] [bit]                NOT NULL,
    [testerKUID]       [int]                NOT NULL,
    [comment]          [varchar](255)       NULL,
    [isActive]         [bit]                NOT NULL,
    [createdTimeUTC]   [datetime]           NOT NULL,
    [kioskID]          [int]                NOT NULL,
    [kioskSiteUUID]    [varchar](255)       NOT NULL,
    CONSTRAINT [PK_pfmID_1] PRIMARY KEY CLUSTERED
        (
         pfmID ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO