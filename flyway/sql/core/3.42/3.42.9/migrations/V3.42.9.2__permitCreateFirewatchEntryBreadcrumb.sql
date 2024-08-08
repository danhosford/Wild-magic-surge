BEGIN
    INSERT INTO [dbo].[kioskBreadcrumb]
    ([kbcIsActive],
     [kbcSection],
     [kbcPage],
     [kbcTitle],
     [kbcParentID],
     [kbcIsLinkClickable],
     [kbcIsFeatureLink],
     [kbcIsSelectableLink],
     [kbcIsSuperuserOnly],
     [kbcOrder],
     [kioskID],
     [kaID])
    VALUES ( 1
           , 'permitCreate'
           , 'firewatchMonitoring'
           , 'SECURITY BREADCRUMB - for Firewatch Monitoring'
           , 1
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 1)
    PRINT 'Added breadcrumb firewatchMonitoring'
END