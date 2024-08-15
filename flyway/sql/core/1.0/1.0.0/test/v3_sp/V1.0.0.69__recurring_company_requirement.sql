-- ==========================================================
-- Author:      Alexandre Tran
-- Create date: 2019
-- Description: Setup renewal compliance requirement job
-- CHANGELOG:
-- 24/07/2020 - AT - Reenable the job all the time at release
-- ==========================================================

USE [v3_sp];
GO

CREATE OR ALTER PROCEDURE [dbo].[execRecurringCompliance]
AS
BEGIN
	DECLARE @kioskdata VARCHAR(50);
	DECLARE @BATCH_SIZE INT = 50;
	DECLARE CUR_KIOSK CURSOR FOR   
		SELECT REPLACE([kiosk].[kioskData],'dsn_','')
		FROM [v3_sp].[dbo].[kiosk] AS [kiosk]
		LEFT JOIN [master].[dbo].[sysdatabases] AS [sysdb]
			ON [sysdb].[name] = REPLACE([kiosk].[kioskData],'dsn_','') COLLATE SQL_Latin1_General_CP1_CI_AS
		WHERE [kiosk].[kioskIsActive] = 1
			AND [sysdb].[sid] IS NOT NULL;

	OPEN CUR_KIOSK;  
	FETCH NEXT FROM CUR_KIOSK   
	INTO @kioskdata
  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  

		DECLARE @dbname VARCHAR(50) = REPLACE(@kioskdata,'dsn_','');
		DECLARE @statement VARCHAR(MAX) = CONCAT('USE ',QUOTENAME(@dbname),'; EXEC [dbo].[createRecurringComplianceRequirement] @batchSize=',@BATCH_SIZE,';');
		EXEC(@statement);

		FETCH NEXT FROM CUR_KIOSK   
		INTO @kioskdata;

	END   
	CLOSE CUR_KIOSK;  
	DEALLOCATE CUR_KIOSK;
END
GO

USE [msdb]
GO
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

DECLARE @enableJob BIT = 1;
DECLARE @job NVARCHAR(128) = 'Recurring Compliance Requirement';
DECLARE @description NVARCHAR(MAX) = 'Job to add notification for recurring compliance requirement'
DECLARE @startdatetime DATETIME = DATEADD(SECOND,5,GETUTCDATE());

DECLARE @servername NVARCHAR(28) = CAST(serverproperty('servername') AS VARCHAR(255));
DECLARE @startdate NVARCHAR(8) =  FORMAT(@startdatetime,'yyyyMMdd');
DECLARE @starttime NVARCHAR(8) =  FORMAT(@startdatetime,'hhmmss');
DECLARE @jobId BINARY(16);

DECLARE @SQL_recurring VARCHAR(MAX);
SET @SQL_recurring = 'EXEC [v3_sp].[dbo].[execRecurringCompliance];'

SELECT @jobId = job_id FROM msdb.dbo.sysjobs WHERE (name = @job)
IF (@jobId IS NOT NULL)
BEGIN
    EXEC msdb.dbo.sp_delete_job @jobId
END

----Add a job
EXEC @ReturnCode = dbo.sp_add_job
  @enabled = @enableJob
  ,@job_name = @job
  ,@description=@description;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--Add a job step named process step. This step runs the stored procedure
EXEC @ReturnCode = dbo.sp_add_jobstep
    @job_name = @job,
    @step_name = N'Run recurring Compliance Requirement',
    @subsystem = N'TSQL',
    @command = @SQL_recurring 
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

--Schedule the job at a specified date and time
exec @ReturnCode = dbo.sp_add_jobschedule @job_name = @job,
@name = 'Daily application notification compliance requirement',
@enabled=@enableJob, 
@freq_type=4, 
@freq_interval=1, 
@freq_subday_type=8, 
@freq_subday_interval=8, 
@freq_relative_interval=0, 
@freq_recurrence_factor=0, 
@active_start_date = @startdate,
--@active_end_date=@enddate,
@active_start_time = @starttime;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
-- Add the job to the SQL Server Server
EXEC @ReturnCode = dbo.sp_add_jobserver
    @job_name =  @job,
    @server_name = @servername;

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
