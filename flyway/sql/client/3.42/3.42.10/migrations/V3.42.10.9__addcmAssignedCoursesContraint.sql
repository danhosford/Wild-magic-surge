ALTER TABLE dbo.cmAssignedCourses
ADD CONSTRAINT DF_assignedCourses_hasCompleted
DEFAULT 0 FOR hasCompleted;