CREATE INDEX idx_kafkaMessages_scheduled_task
    ON v3_sp.dbo.kafkaMessages (consumed, consumedAt, processed, kafkaEventType);