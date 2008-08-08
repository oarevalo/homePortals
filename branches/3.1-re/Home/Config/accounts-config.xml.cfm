<?xml version="1.0" encoding="UTF-8"?>
<homePortalsAccounts>
	<!-- Account Storage 
	xml : stores account data in xml files in the accountsRoot dir
	db : stores account data in tables in a database
	-->
	<storageType>xml</storageType>

	<!-- Database connection info 
	** only applicable when storageType is db
	-->
	<datasource></datasource>
	<username></username>
	<password></password>
	<dbtype></dbtype>	<!-- mysql, mssql -->
	
	<!-- Root directory for account directories -->
	<accountsRoot>/Home/Accounts</accountsRoot>

	<!-- Default templates 
	newAccountTemplate : used as the template for the initial page when creating a new account
	newPageTemplate : used as the template when adding a new page to an account
	-->
	<newAccountTemplate>/Home/Common/AccountTemplates/default.xml</newAccountTemplate>
	<newPageTemplate>/Home/Common/AccountTemplates/newPage.xml</newPageTemplate>
	
</homePortalsAccounts>
