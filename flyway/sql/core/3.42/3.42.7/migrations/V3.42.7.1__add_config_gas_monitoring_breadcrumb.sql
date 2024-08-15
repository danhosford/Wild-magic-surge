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
            [kbcIcon],
            [kbcDisplaySection],
            [kbcOrder],
            [kioskID],
            [kaID]) 
    VALUES(1
            ,'configurePermitType'
            ,'configureGasToBeMonitored'
            ,'Configure Gas/Chemicals Monitoring'
            ,10
            ,1
            ,0
            ,1
            ,1
            ,'building_edit.png'
            ,NULL
            ,0
            ,0
            ,1)
    PRINT 'Configure Gas/Chemicals Monitoring'
END