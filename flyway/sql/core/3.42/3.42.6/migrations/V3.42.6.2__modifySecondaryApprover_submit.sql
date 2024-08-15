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
            ,'modifySecondaryApprover_submit'
            ,'SECURITY BREADCRUMB - generic one for Modify Secondary Approvers submission'
            ,1
            ,0
            ,0
            ,0
            ,0
            ,0
            ,0
            ,1)
	PRINT 'Added breadcrumb Modify Secondary Approvers submission'
END