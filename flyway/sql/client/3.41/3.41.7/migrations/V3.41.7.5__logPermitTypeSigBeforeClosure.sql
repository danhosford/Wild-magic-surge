IF COL_LENGTH('[dbo].[logPermitType]', 'ptUserCanAddSigBeforeClosure') IS NULL
    BEGIN
        ALTER TABLE [dbo].[logPermitType]
            ADD [ptUserCanAddSigBeforeClosure] INT NOT NULL DEFAULT 0;
    END