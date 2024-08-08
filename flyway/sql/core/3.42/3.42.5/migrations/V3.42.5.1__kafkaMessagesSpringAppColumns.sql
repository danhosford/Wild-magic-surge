ALTER TABLE [dbo].[kafkaMessages]
    ADD
        consumed BIT,
        consumedAt DATETIME,
        produced BIT,
        producedAt DATETIME,
        processed BIT,
        processedAt DATETIME,
        retryCount TINYINT,
        errorMessage VARCHAR(4000);
