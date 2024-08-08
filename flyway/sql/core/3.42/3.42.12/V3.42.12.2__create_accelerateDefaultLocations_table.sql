SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[accelerateDefaultLocations]
(
    [accelerateDefaultLocationID]                   [INT] IDENTITY(1,1) NOT NULL,
    [velocityCustomerLocationId]                    [UNIQUEIDENTIFIER] NOT NULL,
    [velocityCustomerId]                            [UNIQUEIDENTIFIER] NOT NULL,
    [name]                                          [VARCHAR](255) NOT NULL,
    [parentId]                                      [UNIQUEIDENTIFIER] NOT NULL,
    [lineage]                                       [VARCHAR](255) NOT NULL,
    [locationStatus]                                [VARCHAR](255) NOT NULL,
    [executedBy]                                    [UNIQUEIDENTIFIER] NOT NULL,
    [createdUTC]                                    [DATETIME] NOT NULL,
    [isTagged]                                      [BIT] DEFAULT 0,
    [taggedBy]                                      [UNIQUEIDENTIFIER] NULL,
    [taggedUTC]                                     [DATETIME] NULL,
 CONSTRAINT [PK_accelerateDefaultLocationID_1] PRIMARY KEY CLUSTERED 
(
	accelerateDefaultLocationID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO