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
	VALUES(1
            ,'permitCreate'
            ,'linkIC'
            ,'SECURITY BREADCRUMB - generic one for Link IC'
            ,1
            ,0
            ,0
            ,0
            ,0
            ,0
            ,0
            ,1)
	PRINT 'Added breadcrumb Link IC'
END