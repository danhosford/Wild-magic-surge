--- * 18/07/23 - LK - Adding ptCanPreApproverAddSigature column

ALTER TABLE [dbo].[logPermitType]
    ADD [ptCanPreApproverAddSignature] BIT NOT NULL DEFAULT 0;