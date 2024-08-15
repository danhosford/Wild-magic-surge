-- ==========================================================================================
-- Author:      Alexxandre Tran
-- Create date: 17/12/2019
-- Description: 
-- * 17/12/2019 - AT - Setup RISK group permission for Ireland test site
-- ==========================================================================================

DECLARE @GROUPS AS test.groups;

-- Define which group for which permission
INSERT INTO @GROUPS(
  [site],[requestor],[admin],[taskowner]
)
VALUES ('Ireland','RISK Super Admin','RISK Super Admin','RISK Super Admin')
;

EXEC test.populate_RISK_groups
@groups=@GROUPS;