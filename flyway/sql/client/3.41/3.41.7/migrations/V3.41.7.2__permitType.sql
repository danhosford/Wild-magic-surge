--- * 18/07/23 - LK - Adding ptCanPreApproverAddSigature column

ALTER TABLE [dbo].[permitType]
    ADD [ptCanPreApproverAddSignature] BIT NOT NULL DEFAULT 0;
