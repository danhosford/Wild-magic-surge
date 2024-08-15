IF OBJECT_ID('tempdb..#translations') IS NOT NULL DROP TABLE #translations;
GO

DECLARE @batchSize INT = 500;

CREATE TABLE #translations
(
[id] INT,
[active] BIT,
[uuid] VARCHAR(50) NOT NULL,
[Etarget] VARCHAR(525),
[Ntarget] VARCHAR(525)
);

INSERT INTO #translations ([id],[active],[uuid],[Etarget],[Ntarget])
VALUES (2279,1,'7484f0f0-85e0-496d-9855-ce94b6ccf06e',N'Please fill out this field.',N'Vul alstublieft dit veld in.')
,(2280,1,'09c86a7e-1734-11ee-be56-0242ac120002',N'Please select an item in the list.',N'Selecteer een item in de lijst.')
,(2281,1,'0dc92ece-1734-11ee-be56-0242ac120002',N'Please check this box if you want to proceed.',N'Vink dit vakje aan als u verder wilt gaan')
;

SET IDENTITY_INSERT [kioskLanguage] ON;
BEGIN
    BEGIN TRANSACTION;
    INSERT INTO [kioskLanguage]
        ([klangID]
        ,[klangIsActive]
        ,[klangUUID]
        ,[en]
        ,[en_ie]
        ,[klangEnglish]
        ,[en_GB]
        ,[nl_NL])
    SELECT [translation].[id]
        ,[translation].[active]
        ,[translation].[uuid]
        ,REPLACE([translation].[Etarget], '''', '')
        ,REPLACE([translation].[Etarget], '''', '')
        ,REPLACE([translation].[Etarget], '''', '')
        ,REPLACE([translation].[Etarget], '''', '')
        ,REPLACE([translation].[Ntarget], '''', '')
    FROM #translations AS [translation]
    LEFT JOIN [kioskLanguage] AS [kiosk]
        ON [kiosk].[klangID] = [translation].[id]
    WHERE [kiosk].[klangID] IS NULL;

COMMIT TRANSACTION;
END