/*
THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT

You are recommended to back up your database before running this script
Script created by Alex from OLS at 07/11/2018 13:21
- Clean up any existing MOC form
- Clear MOC group settings
*/

DECLARE @DEBUG BIT = 0;

DECLARE @MOC_MODULE_ID INT = 3;
DECLARE @FORM_PUBLICKEY VARCHAR(255);
DECLARE @COLUMN_NAME VARCHAR(255) = 'formTypePublicKey';

SET NOCOUNT ON;

-- Enable cascading delete on foreign keys

IF (OBJECT_ID('dbo.FK_formAdministrationNotification_formAdministration', 'F') IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[formAdministrationNotification] DROP CONSTRAINT [FK_formAdministrationNotification_formAdministration];
	ALTER TABLE [dbo].[formAdministrationNotification]  WITH CHECK ADD  CONSTRAINT [FK_formAdministrationNotification_formAdministration] FOREIGN KEY([formAdministrationID])
		REFERENCES [dbo].[formAdministration] ([formAdministrationID]) ON DELETE CASCADE;
	ALTER TABLE [dbo].[formAdministrationNotification] CHECK CONSTRAINT [FK_formAdministrationNotification_formAdministration];
END

IF (OBJECT_ID('dbo.FK_formAdministrationOption_formAdministration','F') IS NOT NULL)
BEGIN
	ALTER TABLE [dbo].[formAdministrationOption] DROP CONSTRAINT [FK_formAdministrationOption_formAdministration];
	ALTER TABLE [dbo].[formAdministrationOption]  WITH CHECK ADD  CONSTRAINT [FK_formAdministrationOption_formAdministration] FOREIGN KEY([formAdministrationID])
		REFERENCES [dbo].[formAdministration] ([formAdministrationID]) ON DELETE CASCADE;
	ALTER TABLE [dbo].[formAdministrationOption] CHECK CONSTRAINT [FK_formAdministrationOption_formAdministration];
END

IF(@DEBUG = 1) SELECT formTypePublicKey FROM formType WHERE formModuleID = @MOC_MODULE_ID;

DECLARE CUR_FORMS CURSOR LOCAL FAST_FORWARD FOR
	SELECT formTypePublicKey FROM formType WHERE formModuleID = @MOC_MODULE_ID;
OPEN CUR_FORMS;
FETCH NEXT FROM CUR_FORMS INTO @FORM_PUBLICKEY;

WHILE @@FETCH_STATUS = 0
BEGIN
   
	
	DECLARE @TABLE_NAME VARCHAR(255);
	DECLARE @SQL VARCHAR(MAX);

	DECLARE CUR_TABLE CURSOR LOCAL FAST_FORWARD FOR
		SELECT t.name AS TableName
		FROM sys.columns c
		JOIN sys.tables t ON c.object_id = t.object_id
	WHERE c.name LIKE @COLUMN_NAME;
	OPEN CUR_TABLE;
	FETCH NEXT FROM CUR_TABLE INTO @TABLE_NAME;

	WHILE @@FETCH_STATUS = 0
	BEGIN
    
		SET @SQL = 'DELETE FROM ' + @TABLE_NAME + ' WHERE ' + @COLUMN_NAME + ' = ''' + @FORM_PUBLICKEY + '''';
		
		IF(@DEBUG = 1) PRINT @SQL; 
		
		EXEC(@SQL);

		FETCH NEXT FROM CUR_TABLE INTO @TABLE_NAME;
	END

	CLOSE CUR_TABLE;
	DEALLOCATE CUR_TABLE;

	FETCH NEXT FROM CUR_FORMS INTO @FORM_PUBLICKEY;

END

CLOSE CUR_FORMS;
DEALLOCATE CUR_FORMS;

IF (OBJECT_ID('dbo.mocGroupSetting') IS NOT NULL)
BEGIN
	TRUNCATE TABLE [mocGroupSetting];
	DBCC CHECKIDENT ([mocGroupSetting], RESEED, 1)
END

SET NOCOUNT OFF;


