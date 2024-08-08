/* 
 * THIS SCRIPT IS ONLY FOR TEST ENVIRONMENT
 *
 * This script will clean up any existing course in the 
 * backup in order to have not corrupted file linked
 *
 * Need to set environment variable OLSMAILSETTINGS with email setting
 * to be pick up by this script.
 *
You are recommended to back up your database before running this script
Script created by Alex from OLS at 17/01/2019 15:17
*/

SET NOCOUNT ON;
DECLARE @KIOSKID VARCHAR(10) = SUBSTRING(db_name(),5,4);

DELETE FROM [cmUserCoursePrerequisites] WHERE kioskid = @KIOSKID;
DELETE FROM cmCoursePrerequisites WHERE kioskid = @KIOSKID;
SET NOCOUNT OFF;
