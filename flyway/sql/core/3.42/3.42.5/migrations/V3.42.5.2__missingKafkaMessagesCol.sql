ALTER TABLE kafkaMessages
    ADD kafkaEventType VARCHAR(255),
        correlationId UNIQUEIDENTIFIER;