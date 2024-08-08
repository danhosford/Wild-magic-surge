ALTER TABLE dbo.cmUserCourses
ADD CONSTRAINT DF_userCourses_hasCompleted
DEFAULT 0 FOR hasCompleted;