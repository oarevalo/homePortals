<cfcomponent name="ehAccounts" extends="ehBase">
	
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
	<!--- dspMain                                  ---->
	<!------------------------------------------------->
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oAccounts = structNew();
			var	oStorage = 0;
			var	oAccountsorage = 0;
			var	bIsAccountsSetup = false;
			
			try {
				oAccounts = getAccountObject();
				stAccountInfo = oAccounts.getConfig();
				
				// check if account storage have been setup 
				if(stAccountInfo.storageType neq "custom" or (stAccountInfo.storageType eq "custom" and stAccountInfo.storageCFC neq "")) {
					oStorage = oAccounts.getAccountStorage();
					bIsAccountsSetup = oStorage.isInitialized();
				}		
	
				if(Not bIsAccountsSetup) {
					getPlugin("messagebox").setMessage("info", "HomePortals Accounts settings have not been properly setup.<br> Please setup HomePortals Accounts before using this feature.");
					SetNextEvent("ehSettings.dspAccounts");
				}
				
				// check if there are search results to display
				if(structKeyExists(session,"qryAccountSearchResults")) {
					setValue("qryAccountSearchResults", session.qryAccountSearchResults);
				} else
					setNextEvent("ehAccounts.doSearch");
				
				// pass values to view
				setValue("accountsRoot", stAccountInfo.accountsRoot);
				
				session.mainMenuOption = "Accounts";
				setView("Accounts/vwMain");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehGeneral.dspStart");
			}

		</cfscript>		
	</cffunction>

	<!------------------------------------------------->
	<!--- dspCreateAccount                         ---->
	<!------------------------------------------------->
	<cffunction name="dspCreateAccount" access="public" returntype="void">
		<cfscript>
			session.mainMenuOption = "Accounts";
			setView("Accounts/vwCreateAccount");		
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- dspProfile                               ---->
	<!------------------------------------------------->
	<cffunction name="dspProfile" access="public" returntype="void">
		<cfscript>
			var oAccounts = structNew();
			var	qryAccount = 0;
			var userID = getValue("userID",0);
			
			try {
				// get accounts info 
				oAccounts = getAccountObject();
				stAccountInfo = oAccounts.getConfig();
	
				if(userID eq 0) throw("Please select an account first");
	
				// search account
				qryAccount = oAccounts.getAccountByUserID(userID);
				
				setValue("stAccountInfo", stAccountInfo);
				setValue("qryAccount", qryAccount);
				
				session.mainMenuOption = "Accounts";
				setView("Accounts/vwProfile");
	
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspMain");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- dspFileManager                           ---->
	<!------------------------------------------------->
	<cffunction name="dspFileManager" access="public" returntype="void">
		<cfscript>
			var oAccounts = structNew();
			var	qryAccount = 0;
			var userID = getValue("userID",0);
			var path = getValue("path","");
			var prevPath = "";
			
			try {
				// get accounts info 
				oAccounts = getAccountObject();
				stAccountInfo = oAccounts.getConfig();
	
				if(userID eq 0) throw("Please select an account first");
	
				// search account
				qryAccount = oAccounts.getAccountByUserID(userID);
				accountDir = stAccountInfo.accountsRoot & "/" & qryAccount.username;

				// get previous path
				if(path neq "" and path neq accountDir) {
					if(listLen(path,"/") gt 0) {
						prevPath = listDeleteAt(path,listLen(path,"/"),"/");			
						setValue("prevPath", prevPath);
					}
				}
				
				// get files
				if(path eq "") path = accountDir;
				if(Not DirectoryExists(expandPath(path))) throw("Directory [#path#] does not exists!");
				qryFiles = dir(path);
				
				setValue("qryFiles", qryFiles);
				setValue("qryAccount", qryAccount);
				setValue("path", path);
				
				session.mainMenuOption = "Accounts";
				setView("Accounts/vwFileManager");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspMain");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSetAccount                             ---->
	<!------------------------------------------------->
	<cffunction name="doSetAccount" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var oSite = 0;
			var userID = getValue("userID",0);
			
			try {
				// get accounts info 
				oAccounts = getAccountObject();

				if(userID eq 0) throw("Please select an account first");
				
				// create site object and instantiate for this user
				oSite = createInstance("../Components/site.cfc");
				oSite.init(userID, oAccounts);
				session.currentSite = oSite;
				
				// go to the site manager
				setNextEvent("ehSite.dspSiteManager");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspMain");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSearch                                 ---->
	<!------------------------------------------------->
	<cffunction name="doSearch" access="public" returntype="void">
		<cfscript>
			var oAccounts = structNew();
			var username = getValue("username","");
			var lastname = getValue("lastname","");
			var email = getValue("email","");
			
			try {
				oAccounts = getAccountObject();
				session.qryAccountSearchResults = oAccounts.SearchUsers(username, lastname, email);

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}
			
			setNextEvent("ehAccounts.dspMain","username=#username#&email=#email#&lastName=#lastName#");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSave                                   ---->
	<!------------------------------------------------->
	<cffunction name="doSave" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var userID = getValue("userID","");
			var username = getValue("username");
			var firstName = getValue("firstName");
			var middleName = getValue("middleName");
			var lastname = getValue("lastname");
			var email = getValue("email");
			var NewUserID = "";

			try {
				oAccounts = getAccountObject();

				if(username eq "") throw("Username cannot be empty.");
				if(email eq "") throw("Email address cannot be empty.");
				if(userID eq "" and password eq "") throw("Password cannot be empty.");

				if(UserID neq "") {
					oAccounts.UpdateAccount(userID, firstName, middleName, lastName, email);
					getPlugin("messagebox").setMessage("info", "Account saved");
				} else {
					userID = oAccounts.CreateAccount(username, password, email);
					oAccounts.UpdateAccount(NewUserID, firstName, middleName, lastName, email);
					getPlugin("messagebox").setMessage("info", "Account created");
				}

				setNextEvent("ehAccounts.dspProfile","userID=#userID#");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				if(UserID neq "") 
					setNextEvent("ehAccounts.dspProfile","userID=#userID#");
				else
					setNextEvent("ehAccounts.dspCreateAccount");
			}
		</cfscript>
	</cffunction>
			

	<!------------------------------------------------->
	<!--- doDelete                                 ---->
	<!------------------------------------------------->
	<cffunction name="doDelete" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var userID = getValue("userID","");

			try {
				if(userID eq "") throw("Please indicate the user account to delete.");
				
				oAccounts = getAccountObject();
				oAccounts.delete(userID);
				
				structDelete(session,"qryAccountSearchResults");
				
				getPlugin("messagebox").setMessage("info", "Account has been deleted.");
				setNextEvent("ehAccounts.dspMain");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspMain");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doChangePassword                         ---->
	<!------------------------------------------------->
	<cffunction name="doChangePassword" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var userID = getValue("userID","");
			var newPassword = getValue("newPassword","");

			try {
				if(userID eq "") throw("Please indicate the user account to change its password.");
				if(newPassword eq "") throw("Please indicate the new password.");
					
				oAccounts = getAccountObject();
				oAccounts.changePassword(userID, newPassword);
				
				getPlugin("messagebox").setMessage("info", "Account password has been changed.");
				setNextEvent("ehAccounts.dspProfile","userID=#userID#");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspProfile","userID=#userID#");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doDeleteFile                             ---->
	<!------------------------------------------------->
	<cffunction name="doDeleteFile" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var userID = getValue("userID","");
			var href = getValue("href","");
			var qryAccount = 0;
			var accountDir = 0;

			try {
				if(userID eq "") throw("Please indicate the user account.");
				if(href eq "") throw("Please indicate the file to delete.");
				
				oAccounts = getAccountObject();
	
				// get users account 
				qryAccount = oAccounts.getAccountByUserID(userID);
				
				// check that user is found
				if(qryAccount.recordCount eq 0) 
					throw("The requested user account cannot be found.");

				// check that file is located within account
				accountDir = oAccounts.stConfig.accountsRoot & "/" & qryAccount.username;
				if(left(href, len(accountDir)) neq accountDir) 
					throw("The file to delete must be located within the user account.");

				// delete file
				if(FileExists(ExpandPath(href)))
					deleteFile(href);
				
				getPlugin("messagebox").setMessage("info", "File has been deleted.");
				setNextEvent("ehAccounts.dspFileManager","userID=#userID#");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspFileManager","userID=#userID#");
			}
		</cfscript>
	</cffunction>
	

	<!------------------------------------------------->
	<!--- P R I V A T E   M E T H O D S            ---->
	<!------------------------------------------------->
	<cffunction name="getAccountObject" access="private" returntype="any">
		<cfscript>
			var oAccounts = 0;
			oAccounts = createInstance("../Components/accounts.cfc");
			oAccounts.init(true, getSetting("HomeRoot"));
		</cfscript>
		<cfreturn oAccounts>
	</cffunction>

	<cffunction name="dir" access="private" returnttye="query">
		<cfargument name="path" type="string" required="true">
		<cfargument name="recurse" type="boolean" required="false" default="false">
		<cfset var qry = QueryNew("")>

		<cfdirectory action="list" name="qry" 
					directory="#ExpandPath(arguments.path)#" 
					recurse="#arguments.recurse#">
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				ORDER BY Type, Name
		</cfquery>		
		<cfreturn qry>	
	</cffunction>
	
	<cffunction name="deleteFile" access="private">
		<cfargument name="filePath" type="string" required="true">
		<cffile action="delete" file="#ExpandPath(arguments.filePath)#">
	</cffunction>	
</cfcomponent>
