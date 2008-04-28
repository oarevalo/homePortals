<?xml version="1.0" encoding="UTF-8"?>
<homePortalsAccounts version="1.0">
	<!-- Database connection info -->
	<datasource></datasource>
	<username></username>
	<password></password>
	
	<!-- Root directory for account directories -->
	<accountsRoot>/Home/Accounts</accountsRoot>

	<!-- Default templates -->
	<newAccountTemplate>/Home/Common/AccountTemplates/default.xml</newAccountTemplate>
	<newPageTemplate>/Home/Common/AccountTemplates/newPage.xml</newPageTemplate>
	<siteTemplate>/Home/Common/AccountTemplates/site.xml</siteTemplate>
	
	<!-- Account Storage -->
	<storageType>xml</storageType>
	<storageCFC></storageCFC>
	<accountsTable>cfe_user</accountsTable>
	<dbtype>MSSQL</dbtype>
	<storageFileHREF>/Home/Accounts/accounts.xml</storageFileHREF>
</homePortalsAccounts>
