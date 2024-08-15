USE [v3_sp]
GO

INSERT INTO [dbo].[accelerateDefaultLocations]
    ([velocityCustomerLocationId]
    ,[velocityCustomerId]
    ,[name]
    ,[parentId]
    ,[lineage]
    ,[locationStatus]
    ,[executedBy]
    ,[createdUTC]
    ,[isTagged]
    ,[taggedBy]
    ,[taggedUTC])
VALUES
    ('dffebb18-7787-46d7-a385-bb5c8a7c824a'
    ,'02739042-a79c-40c0-8ef3-a0f74466fa73'
    ,'A_Cork_1'
    ,'6d928d45-ff47-47c2-a7bd-c23ce71222be'
    ,'CoWCust1'
    ,'Active'
    ,'05c09542-dc7e-4780-83fa-9949b1c895f3'
    ,GETDATE()
    ,1
    ,'05c09542-dc7e-4780-83fa-9949b1c895f3'
    ,GETDATE())
GO