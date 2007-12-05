<cfcomponent name="ehSettings" extends="ehBase">
	
	<!--- ************************************************************* --->
	<!--- 
		This method should not be altered, unless you want code to be executed
		when this handler is instantiated. This init method should be on all
		event handlers, usually left untouched.
	--->
	<cffunction name="init" access="public" returntype="Any">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->


	<!------------------------------------------------->
	<!--- dspMain		                           ---->
	<!------------------------------------------------->
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var oHP = 0;
			
			// get settings
			oHP = createInstance("../Components/homePortals.cfc");
			oHP.init(true, getSetting("HomeRoot"));
			stConfig = oHP.getConfig();		

			setValue("defaultAccount",stConfig.defaultAccount);
			setValue("homePortalsPath", stConfig.homePortalsPath);
			setValue("moduleLibraryPath", stConfig.moduleLibraryPath);
			setValue("SSLRoot", stConfig.SSLRoot);
			setValue("mailServer", stConfig.mailServer);
			setValue("mailUsername", stConfig.mailUsername);
			setValue("mailPassword", stConfig.mailPassword);
			
			session.mainMenuOption = "Settings";
			setView("Settings/vwMain");
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspPageResources                         ---->
	<!------------------------------------------------->
	<cffunction name="dspPageResources" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var oHP = 0;
			
			// get settings
			oHP = createInstance("../Components/homePortals.cfc");
			oHP.init(true, getSetting("HomeRoot"));
			stConfig = oHP.getConfig();		
			
			setValue("stResources", stConfig.resources);
			
			session.mainMenuOption = "Settings";
			setView("Settings/vwPageResources");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- dspAccounts	                           ---->
	<!------------------------------------------------->
	<cffunction name="dspAccounts" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var oHP = 0;
			var	oStorage = 0;
			var stAccountInfo = 0;
			var bIsAccountsSetup = false;
			var stConfigHelp = structNew();
			
			
			// get settings
			oHP = createInstance("../Components/homePortals.cfc");
			oHP.init(true, getSetting("HomeRoot"));
			
			// get accounts info 
			oAccounts = createInstance("../Components/accounts.cfc");
			oAccounts.init(true, getSetting("HomeRoot"));
			stAccountInfo = oAccounts.getConfig();
			
			// check if account storage have been setup 
			if(stAccountInfo.storageType neq "custom" or (stAccountInfo.storageType eq "custom" and stAccountInfo.storageCFC neq "")) {
				oStorage = oAccounts.getAccountStorage();
				bIsAccountsSetup = oStorage.isInitialized();
			}		
			
			// help for field items
			stConfigHelp.accountsRoot = "Base path for the HomePortals Accounts files.";
			stConfigHelp.homeRoot = "Base path for the HomePortals installation.";
			stConfigHelp.mailServer = "Mail server addresss. Leave empty to use default ColdFusion settings.";
			stConfigHelp.emailAddress = "Email address to use as sender for emails related to HomePortals accounts.";
			stConfigHelp.newAccountTemplate = "Document to use as template for the main page when creating new accounts.";
			stConfigHelp.newPageTemplate = "Document to use as template when creating a new HomePortals page.";
			stConfigHelp.siteTemplate = "Default document to use as Site descriptor file for new accounts.";
			stConfigHelp.allowRegisterAccount = "Allows open registration for new accounts.";
			
			setValue("stAccountInfo", stAccountInfo);
			setValue("stConfigHelp", stConfigHelp);
			setValue("oStorage", oStorage);
			setValue("bIsAccountsSetup", bIsAccountsSetup);
			
			session.mainMenuOption = "Settings";
			setView("Settings/vwAccounts");
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspAccountStorage                        ---->
	<!------------------------------------------------->
	<cffunction name="dspAccountStorage" access="public" returntype="void">
		<cfscript>
			var oHP = 0;
			var oAccounts = 0;
			var oStorage = 0;
			var stAccountInfo = structNew();
			var bIsAccountsSetup = false;
			var lstStorageProperties = "";
			
			// get settings
			oHP = createInstance("../Components/homePortals.cfc");
			oHP.init(true, getSetting("HomeRoot"));
			
			// get accounts info 
			oAccounts = createInstance("../Components/accounts.cfc");
			oAccounts.init(true, getSetting("HomeRoot"));
			stAccountInfo = oAccounts.getConfig();
			
			// check if account storage have been setup 
			if(stAccountInfo.storageType neq "custom" or (stAccountInfo.storageType eq "custom" and stAccountInfo.storageCFC neq "")) {
				oStorage = oAccounts.getAccountStorage();
				bIsAccountsSetup = oStorage.isInitialized();
				lstStorageProperties = oStorage.getStorageSettingsList();
			} 
			
			setValue("stAccountInfo", stAccountInfo);
			setValue("lstStorageProperties", lstStorageProperties);
			setValue("oStorage", oStorage);
			setValue("bIsAccountsSetup", bIsAccountsSetup);
			
			session.mainMenuOption = "Settings";
			setView("Settings/vwAccountStorage");
		</cfscript>	
	</cffunction>


	<!------------------------------------------------->
	<!--- dspChangePassword                        ---->
	<!------------------------------------------------->
	<cffunction name="dspChangePassword" access="public" returntype="void">
		<cfset session.mainMenuOption = "Settings">
		<cfset setView("Settings/vwChangePassword")>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSaveSettings                           ---->
	<!------------------------------------------------->
	<cffunction name="doSaveSettings" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var oHP = 0;
			
			try {
				// get settings
				oHP = createInstance("../Components/homePortals.cfc");
				oHP.init(true, getSetting("HomeRoot"));
				stConfig = oHP.getConfig();		
				
				stConfig.homePortalsPath = getValue("homePortalsPath");
				stConfig.moduleLibraryPath = getValue("moduleLibraryPath");
				stConfig.SSLRoot = getValue("SSLRoot");
				stConfig.defaultAccount = getValue("defaultAccount");
				stConfig.mailServer = getValue("mailServer");
				stConfig.mailUsername = getValue("mailUsername");
				stConfig.mailPassword = getValue("mailPassword");
				
				oHP.setConfig(stConfig);
				oHP.SaveConfig();

				getPlugin("messagebox").setMessage("info", "Settings changed.");
				SetNextEvent("ehSettings.dspMain");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSettings.dspMain");
			}
		</cfscript>
	</cffunction>		


	<!------------------------------------------------->
	<!--- doSavePageResource                       ---->
	<!------------------------------------------------->
	<cffunction name="doSavePageResource" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var oHP = 0;
			var resourceIndex = 0;
			var resourceType = "";
			var type = "";
			var href = "";
			
			try {
				// get settings
				oHP = createInstance("../Components/homePortals.cfc");
				oHP.init(true, getSetting("HomeRoot"));
				stConfig = oHP.getConfig();		
				
				resourceIndex = getValue("resourceIndex",0);
				resourceType = getValue("resourceType","");
				type = getValue("type","");
				href = getValue("href","");

				if(Not StructKeyExists(stConfig.resources, type))
					stConfig.resources[type] = ArrayNew(1);
				
				if(resourceIndex gt 0) {
					if(resourceType eq type)
						stConfig.resources[resourceType][resourceIndex] = href;
					else {
						ArrayDeleteAt(stConfig.resources[resourceType], resourceIndex);
						ArrayAppend(stConfig.resources[type], href);
					}
				} else {
					ArrayAppend(stConfig.resources[type], href);
				}			
				
				oHP.setConfig(stConfig);
				oHP.SaveConfig();

				getPlugin("messagebox").setMessage("info", "Page resource saved.");
				SetNextEvent("ehSettings.dspPageResources");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSettings.dspPageResources");
			}
		</cfscript>
	</cffunction>
	
	
	<!------------------------------------------------->
	<!--- doDeletePageResource                     ---->
	<!------------------------------------------------->
	<cffunction name="doDeletePageResource" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var oHP = 0;
			var resourceIndex = 0;
			var resourceType = "";
			
			try {
				// get settings
				oHP = createInstance("../Components/homePortals.cfc");
				oHP.init(true, getSetting("HomeRoot"));
				stConfig = oHP.getConfig();		
				
				resourceIndex = getValue("resourceIndex",0);
				resourceType = getValue("resourceType","");

				if(resourceIndex gt 0)
					ArrayDeleteAt(stConfig.resources[resourceType], resourceIndex);
				
				oHP.setConfig(stConfig);
				oHP.SaveConfig();

				getPlugin("messagebox").setMessage("info", "Page resource deleted.");
				SetNextEvent("ehSettings.dspPageResources");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSettings.dspPageResources");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSaveAccountSettings                    ---->
	<!------------------------------------------------->
	<cffunction name="doSaveAccountSettings" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var oAccounts = 0;
			var stAccountInfo = structNew();
			
			try {
				if(getValue("accountsRoot","") eq "") throw("Accounts Root name cannot be empty.");
				if(getValue("homeRoot","") eq "") throw("HomePortals Root name cannot be empty.");
				if(Not IsBoolean(getValue("allowRegisterAccount",""))) getValue("allowRegisterAccount",false);
				
				// get accounts info 
				oAccounts = createInstance("../Components/accounts.cfc");
				oAccounts.init(true, getSetting("HomeRoot"));
				stAccountInfo = oAccounts.getConfig();

				// populate with new data
				stAccountInfo.accountsRoot = getValue("accountsRoot");
				stAccountInfo.homeRoot = getValue("homeRoot");
				stAccountInfo.newAccountTemplate = getValue("newAccountTemplate");
				stAccountInfo.newPageTemplate = getValue("newPageTemplate");
				stAccountInfo.siteTemplate = getValue("siteTemplate");
				stAccountInfo.allowRegisterAccount = getValue("allowRegisterAccount");
				stAccountInfo.storageType = getValue("storageType");
				stAccountInfo.storageCFC = getValue("storageCFC");
	
				// set configuration
				oAccounts.setConfig(stAccountInfo); 
				
				// save configuration
				oAccounts.saveConfig(); 

				getPlugin("messagebox").setMessage("info", "Account settings saved.");
				SetNextEvent("ehSettings.dspAccounts");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				SetNextEvent("ehSettings.dspAccounts");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSaveAccountStorageSettings             ---->
	<!------------------------------------------------->
	<cffunction name="doSaveAccountStorageSettings" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var stAccountInfo = structNew();
			var oAccounts = 0;
			var oStorage = 0;
			var lstStorageProperties = "";
			var i = 0;
			var fld = 0;
			
			try {
				// get accounts info 
				oAccounts = createInstance("../Components/accounts.cfc");
				oAccounts.init(true, getSetting("HomeRoot"));
				stAccountInfo = oAccounts.getConfig();

				// get storage properties
				oStorage = oAccounts.getAccountStorage();
				if(Not IsSimpleValue(oStorage)) lstStorageProperties = oStorage.getStorageSettingsList();
		
				for(i=1;i lte listLen(lstStorageProperties);i=i+1) {
					fld = listGetAt(lstStorageProperties,i);
					stAccountInfo[fld] = getValue(fld,"");
				}

				// set configuration
				oAccounts.setConfig(stAccountInfo); 
				
				// save configuration
				oAccounts.saveConfig(); 
				
				getPlugin("messagebox").setMessage("info", "Account storage settings saved.");
				SetNextEvent("ehSettings.dspAccountStorage");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				SetNextEvent("ehSettings.dspAccountStorage");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doInitializeAccountStorage               ---->
	<!------------------------------------------------->
	<cffunction name="doInitializeAccountStorage" access="public" returntype="void">
		<cfscript>
			var stConfig = structNew();
			var oAccounts = 0;
			var oStorage = 0;
			
			try {
				// get accounts info 
				oAccounts = createInstance("../Components/accounts.cfc");
				oAccounts.init(true, getSetting("HomeRoot"));

				// initialize storage 
				oStorage = oAccounts.getAccountStorage();
				oStorage.initializeStorage();
			
				getPlugin("messagebox").setMessage("info", "Account storage initialized.");
				SetNextEvent("ehSettings.dspAccountStorage");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				SetNextEvent("ehSettings.dspAccountStorage");
			}
		</cfscript>
	</cffunction>



	<!------------------------------------------------->
	<!--- doChangePassword                         ---->
	<!------------------------------------------------->
	<cffunction name="doChangePassword" access="public" returntype="void">
		<cfscript>
			var oldPwd = getValue("oldPwd","");
			var newPwd = getValue("newPwd","");
			var newPwd2 = getValue("newPwd2","");
			var oLicense = 0;
			var bValid = false;

			try {
				if(oldPwd eq "") throw("Please enter your current password.");
				if(newPwd eq "") throw("Please enter the new password.");
				if(newPwd2 eq "") throw("Please confirm the new password.");
				if(len(newPwd) lt 5) throw("The new password must be at least 6 characters long.");
				if(newPwd neq newPwd2) throw("Both new passwords do not match.");
	
				// instantiate license manager object 
				oLicense = createInstance("../Components/license.cfc");
	
				// check if current password is okay
				bValid = oLicense.verifyAdminPassword(oldPwd);
				
				if(Not bValid)
					throw("The current password is not correct. Please enter your current password.");
	
				oLicense.saveAdminPassword(newPwd);
				getPlugin("messagebox").setMessage("info", "The administrator password has been changed.");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}

			setNextEvent("ehSettings.dspChangePassword");
		</cfscript>
	</cffunction>	
	
</cfcomponent>
