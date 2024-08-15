EXEC sp_rename 'permitGasReading.measuredBy', 'monitor', 'COLUMN';
EXEC sp_rename 'permitGasReading.measuredByUTC', 'monitorUTC', 'COLUMN';
EXEC sp_rename 'permitFirewatchMonitoring.testerKUID', 'monitorKUID', 'COLUMN';