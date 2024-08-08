-- Create trigger to insert data for any permitLinkedIC in future
CREATE TRIGGER [trg_InsertPermitLinkedIC]
ON [dbo].[permitLinkedIC]
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO [dbo].[permitLinkedICKafkaHistory] (permitPublicKey, icID, kioskID, kioskSiteUUID, isActive, linkedUTC, linkedBy, unlinkedUTC, unlinkedBy, updatedUTC, processed, produced, retryCount)
    SELECT permitPublicKey, icID, kioskID, kioskSiteUUID, isActive, linkedUTC, linkedBy, unlinkedUTC, unlinkedBy, GETDATE(), 0, 0, 0
    FROM inserted;
END;