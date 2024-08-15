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
            ,'modifySecondaryApprover'
            ,'SECURITY BREADCRUMB - generic one for Modify Secondary Approvers'
            ,1
            ,0
            ,0
            ,0
            ,0
            ,0
            ,0
            ,1)
	PRINT 'Added breadcrumb Modify Secondary Approvers'
END