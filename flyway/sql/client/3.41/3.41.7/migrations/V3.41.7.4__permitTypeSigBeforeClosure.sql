IF COL_LENGTH('[dbo].[permitType]', 'ptUserCanAddSigBeforeClosure') IS NULL
    BEGIN
        ALTER TABLE [dbo].[permitType]
            ADD [ptUserCanAddSigBeforeClosure] INT NOT NULL DEFAULT 0;
    END