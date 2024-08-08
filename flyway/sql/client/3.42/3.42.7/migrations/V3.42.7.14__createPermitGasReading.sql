SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[permitGasReading]
(
    [pgrID]            [int] IDENTITY (1,1) NOT NULL,
    [groupID]          [uniqueidentifier]   NOT NULL,
    [gasID]            [int]                NULL,
    [permitPublicKey]  [varchar](255)       NULL,
    [readingValue]     [numeric](8,3)       NULL,
    [enteredBy]        [int]                NULL,
    [enteredByUTC]     [datetime]           NOT NULL,
    [measuredBy]       [int]                NULL,
    [measuredByUTC]    [datetime]           NOT NULL,
    [isActive]         [bit]                NOT NULL,
    [deactivatedBy]    [int]                NULL,
    [deactivatedByUTC] [datetime]           NULL,
    [kioskID]          [int]                NULL,
    [kioskSiteUUID]    [varchar](255)       NULL,
    CONSTRAINT [PK_pgrID_1] PRIMARY KEY CLUSTERED
        (
         pgrID ASC
            ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO