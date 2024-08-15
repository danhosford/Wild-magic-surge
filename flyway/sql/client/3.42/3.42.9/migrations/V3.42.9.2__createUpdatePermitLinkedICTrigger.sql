-- Create trigger to insert data for any updates on permitLinkedIC
CREATE TRIGGER [trg_UpdatePermitLinkedIC]
ON [dbo].[permitLinkedIC]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[permitLinkedICKafkaHistory] (permitPublicKey, isolationCertificateID, kioskID, kioskSiteUUID, isActive, linkedUTC, linkedBy, unlinkedUTC, unlinkedBy, updatedUTC, processed, produced, retryCount)
    SELECT permitPublicKey, isolationCertificateID, kioskID, kioskSiteUUID, isActive, linkedUTC, linkedBy, unlinkedUTC, unlinkedBy, GETDATE(), 0, 0, 0
    FROM inserted;
END;