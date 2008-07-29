<cfcomponent extends="eventHandler">

	<!------------------------------------------------->
	<!--- saveAccountInfo                         ---->
	<!------------------------------------------------->
	<cffunction name="saveAccountInfo" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 

		<cfset var frm = arguments.form>
		<cfset var oAccounts = 0>
		<cfset var accountsCFCPath = "">
		<cfset var stConfig = structNew()>

		<cfparam name="frm.accountsRoot" default="">
		<cfparam name="frm.homeRoot" default="">
		<cfparam name="frm.dbtype" default="">
		<cfparam name="frm.mailServer" default="">
		<cfparam name="frm.emailAddress" default="">
		<cfparam name="frm.newAccountTemplate" default="">
		<cfparam name="frm.newPageTemplate" default="">
		<cfparam name="frm.siteTemplate" default="">
		<cfparam name="frm.allowRegisterAccount" default="">
		
		<cfscript>
			if(frm.accountsRoot eq "") throw("Accounts Root name cannot be empty.");
			if(frm.homeRoot eq "") throw("HomePortals Root name cannot be empty.");
			if(Not IsBoolean(frm.allowRegisterAccount)) frm.allowRegisterAccount = false;

			// get instance for accounts object				
			oAccounts = createObject("Component", arguments.state.stConfig.moduleLibraryPath & "Accounts.accounts");

			// get current config
			oAccounts.loadConfig();
			stConfig = oAccounts.getConfig();
			
			// populate with new data
			stConfig.accountsRoot = frm.accountsRoot;
			stConfig.homeRoot = frm.homeRoot;
			stConfig.mailServer = frm.mailServer;
			stConfig.emailAddress = frm.emailAddress;
			stConfig.newAccountTemplate = frm.newAccountTemplate;
			stConfig.newPageTemplate = frm.newPageTemplate;
			stConfig.siteTemplate = frm.siteTemplate;
			stConfig.allowRegisterAccount = frm.allowRegisterAccount;
			stConfig.storageType = frm.storageType;
			stConfig.storageCFC = frm.storageCFC;

			// set configuration
			oAccounts.setConfig(stConfig); 
			
			// save configuration
			oAccounts.saveConfig(); 
			arguments.state.infoMessage = "Account Configuration Saved.";
		</cfscript>
					
		<cfreturn arguments.state>
	</cffunction>	


	<!------------------------------------------------->
	<!--- saveAccountStorageInfo                   ---->
	<!------------------------------------------------->
	<cffunction name="saveAccountStorageInfo" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 

		<cfset var frm = arguments.form>
		<cfset var oAccounts = 0>
		<cfset var accountsCFCPath = "">
		<cfset var stConfig = structNew()>
		<cfset var bIsAccountSetup = false>	
		<cfset var lstStorageProperties = "">

		<cfscript>
			// get instance for accounts object				
			oAccounts = createObject("Component", arguments.state.stConfig.moduleLibraryPath & "Accounts.accounts");

			// get current config
			oAccounts.loadConfig();
			stConfig = oAccounts.getConfig();

			// get storage properties
			oStorage = oAccounts.getAccountStorage();
			if(Not IsSimpleValue(oStorage)) lstStorageProperties = oStorage.getStorageSettingsList();
	
			for(i=1;i lte listLen(lstStorageProperties);i=i+1) {
				fld = listGetAt(lstStorageProperties,i);
				stConfig[fld] = frm[fld];
			}
	
			// set configuration
			oAccounts.setConfig(stConfig); 
			
			// save configuration
			oAccounts.saveConfig(); 
			arguments.state.infoMessage = "Account Storage Configuration Saved.";
		</cfscript>

		<cfreturn arguments.state>
	</cffunction>
	
	
	<!------------------------------------------------->
	<!--- initializeAccountStorage                 ---->
	<!------------------------------------------------->
	<cffunction name="initializeAccountStorage" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 

		<cfset var frm = arguments.form>
		<cfset var oAccounts = 0>
		<cfset var accountsCFCPath = "">
		<cfset var stConfig = structNew()>

		<cfscript>
			// get instance for accounts object				
			oAccounts = createObject("Component", arguments.state.stConfig.moduleLibraryPath & "Accounts.accounts");

			// get current config
			oAccounts.loadConfig();
						
			oStorage = oAccounts.getAccountStorage();
			oStorage.initializeStorage();
			
			arguments.state.infoMessage = "Account Storage Initialized.";
		</cfscript>

		<cfreturn arguments.state>
	</cffunction>	
		
</cfcomponent>