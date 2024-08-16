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
           , 'entryLogChangeTracking'
           , 'SECURITY BREADCRUMB - for Entry Log Change Tracking'
           , 1
           , 0
           , 0
           , 0
           , 0
           , 0
           , 0
           , 1)
    PRINT 'Added breadcrumb entryLogChangeTracking'
END