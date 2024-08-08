SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[cpContractorCompaniesBookmark](
	[cpBookmarkID]  [int] IDENTITY(1,1) NOT NULL,
	[cpCompanyID] [int] NOT NULL,
	[kioskID] [int] NOT NULL,
	[kioskSiteUUID] [varchar](255) NULL,
	[kuID] [int] NOT NULL,
	[addedUTC] [datetime] NOT NULL,
	[isBookmarked] [int] NOT NULL
 CONSTRAINT [PK_cpBookmarkID_1] PRIMARY KEY CLUSTERED 
(
	cpBookmarkID ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO