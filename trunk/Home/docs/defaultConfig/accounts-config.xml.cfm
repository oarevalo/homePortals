<?xml version="1.0" encoding="UTF-8"?>
<homePortalsAccounts version="1.0">
	<!-- Database connection info -->
	<datasource></datasource>
	<username></username>
	<password></password>
	
	<!-- Root directory for account directories -->
	<accountsRoot>/Accounts</accountsRoot>
	<homeRoot>/Home</homeRoot>

	<!-- Mail settings -->
	<mailServer></mailServer>
	<emailAddress></emailAddress>

	<!-- Default templates -->
	<newAccountTemplate>/Home/Common/AccountTemplates/default.xml</newAccountTemplate>
	<newPageTemplate>/Home/Common/AccountTemplates/newPage.xml</newPageTemplate>
	<siteTemplate>/Home/Common/AccountTemplates/site.xml</siteTemplate>
	
	<!-- Account Storage -->
	<allowRegisterAccount>true</allowRegisterAccount>
	<version></version>
	<storageType>xml</storageType>
	<storageCFC></storageCFC>
	<accountsTable>cfe_user</accountsTable>
	<dbtype>MSSQL</dbtype>
	<storageFileHREF>/Accounts/accounts.xml</storageFileHREF>
</homePortalsAccounts>
