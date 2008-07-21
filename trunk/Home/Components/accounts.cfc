<cfcomponent displayname="accounts" hint="This components acts as a service to perform account-related functions. The same instance of this component can perform actions on multiple accounts.">
	<cfscript>
		variables.configFilePath = "Config/accounts-config.xml.cfm";  // path of the config file relative to the root of the application
		variables.oAccountsConfigBean = 0;	// bean to store config settings
		variables.oHomePortalsConfigBean = 0;	// reference to the application settings
	</cfscript>

	<!--------------------------------------->
	<!----  init	 					----->
	<!--------------------------------------->
	<cffunction name="init" access="public" returntype="accounts" hint="Constructor">
		<cfargument name="configBean" type="homePortalsConfigBean" required="true" hint="HomePortals application settings">
		
		<cfscript>
			var pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
			var defaultConfigFilePath = "";
			
			// copy reference to homeportals config bean
			variables.oHomePortalsConfigBean = arguments.configBean;

			// create object to store configuration settings
			variables.oAccountsConfigBean = createObject("component", "accountsConfigBean").init();

			// load default configuration settings
			defaultConfigFilePath = getDirectoryFromPath(getCurrentTemplatePath()) & pathSeparator & ".." & pathSeparator & "Config" & pathSeparator & "accounts-config.xml.cfm";
			variables.oAccountsConfigBean.load(defaultConfigFilePath);

			// load configuration settings for the application
			configFilePath = listAppend(oHomePortalsConfigBean.getAppRoot(), variables.configFilePath, "/");
			variables.oAccountsConfigBean.load(expandPath(configFilePath));
		
			return this;
		</cfscript>
	</cffunction>
	

	<!--------------------------------------->
	<!----  getConfig					----->
	<!--------------------------------------->
	<cffunction name="getConfig" access="public" returntype="accountsConfigBean" hint="Returns the accounts config bean for the application">
		<cfreturn variables.oAccountsConfigBean>
	</cffunction>
				
	<!--------------------------------------->
	<!--- getAccountStorage  		        --->
	<!--------------------------------------->
	<cffunction name="getAccountStorage" access="public" returntype="storage"
				hint="Returns the storage object for the type of storage selected">

		<cfset var obj = createObject("component","storage")>
		<cfset var storageType = oAccountsConfigBean.getStorageType()>
		<cfset var storageCFC = oAccountsConfigBean.getStorageCFC()>
				
		<cfswitch expression="#storageType#">
			<cfcase value="db">
				<cfset storageCFC = "dbStorage">
			</cfcase>
			<cfcase value="xml">
				<cfset storageCFC = "xmlStorage">
			</cfcase>
			<cfcase value="custom">
				<cfset storageCFC = storageCFC>
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="Unknown storage type!" type="homePortals.accounts.invalidStorageType">
			</cfdefaultcase>
		</cfswitch>
		
		<cfset obj = createObject("component",storageCFC).init(oAccountsConfigBean)>
		<cfreturn obj>
	</cffunction>	

	
	<!--------------------------------------->
	<!----  GetUsers					----->
	<!--------------------------------------->
	<cffunction name="GetUsers" access="public" returntype="query" hint="Returns a query with recently created accounts.">
		<cfreturn getAccountStorage().search("","","","","createDate,username")>
	</cffunction>

	<!--------------------------------------->
	<!----  loginUser					----->
	<!--------------------------------------->
	<cffunction name="loginUser" access="public" returntype="query" hint="Authenticates a user and stores user information into the session. Returns a query object with the user information">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="passwordHash" type="string" required="no" default="" hint="MD5 hash of user's password. Used if password argument is empty">
		
		<cfset var pwdHSH = "">
		<cfset var oUserRegistry = 0>
		<cfset var qryUser = queryNew("")>

		<!--- hash the password --->
		<cfif arguments.password eq "" and arguments.passwordHash neq "">
			<cfset pwdHSH = Arguments.passwordHash>
		<cfelse>		
			<cfset pwdHSH = Hash(Arguments.password)>
		</cfif>
		
		<!--- retrieve user information from the accounts storage --->
		<cfset qryUser = getAccountByUsername(arguments.username)>

		<!--- validate the password --->
		<cfif (qryUser.recordCount eq 0) or (qryUser.password[1] neq pwdHSH)>
			<cfthrow message="Invalid username or password" type="homePortals.accounts.invalidLogin">
		</cfif>			

		<!--- register user information into the user registry --->
		<!--- (this is to allow other components to access the current user information) --->
		<cfset oUserRegistry = createObject("component","userRegistry").init()>
		<cfset oUserRegistry.setUserInfo( qryUser.userID, qryUser.userName, qryUser )>
		
		<cfreturn qryUser>
	</cffunction>
	
	<!--------------------------------------->
	<!----  logoutUser					----->
	<!--------------------------------------->
	<cffunction name="logoutUser" access="public" returntype="void" hint="Removes user information from the session">
		<cfset var oUserRegistry = 0>

		<!--- removes user information from the user registry --->
		<cfset oUserRegistry = createObject("component","userRegistry").init()>
		<cfset oUserRegistry.reinit()>
	</cffunction>



	<!--------------------------------------->
	<!----  SearchUsers				  ----->
	<!--------------------------------------->
	<cffunction name="SearchUsers" access="public" returntype="query" hint="Searches account records.">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="lastname" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
		<cfreturn getAccountStorage().search("",arguments.username & "%", arguments.lastName & "%", arguments.email & "%")>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountByUsername		----->
	<!--------------------------------------->
	<cffunction name="getAccountByUsername" access="public" returntype="query" hint="Returns info on a user.">
		<cfargument name="username" type="string" required="yes">
		<cfreturn getAccountStorage().search("",arguments.username)>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountByUserID		    ----->
	<!--------------------------------------->
	<cffunction name="getAccountByUserID" access="public" returntype="query" hint="Retrieves an account by the UserID.">
		<cfargument name="UserID" type="string" required="yes">
		
		<!--- if the userID is empty, then replace with -1 to avoid returning anything else --->
		<cfif arguments.userID eq "">
			<cfset arguments.userID = "-1">
		</cfif>
		
		<cfreturn getAccountStorage().search(arguments.UserID)>
	</cffunction>



	<!--------------------------------------->
	<!----  createAccount				  ----->
	<!--------------------------------------->
	<cffunction name="createAccount" access="public" hint="Creates a new account" returntype="string">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="Password" type="string" required="yes">
		<cfargument name="FirstName" type="string" required="no" default="">
		<cfargument name="MiddleName" type="string" required="no" default="">
		<cfargument name="LastName" type="string" required="no" default="">
		<cfargument name="Email" type="string" required="no" default="">
		
		<cfset var qry = 0>
		<cfset var oHPConfig = 0>
		<cfset var txtDefault = "">
		<cfset var txtPublic = "">
		<cfset var txtSite = "">
		<cfset var txtContent = "">
		<cfset var tmpAccoutDir = "">
		<cfset var tmpAccPublic = "">
		<cfset var tmpAccDefault = "">
		<cfset var tmpAccSite = "">
		<cfset var tmpAccContent = "">
		<cfset var newUserID = createUUID()>
		<cfset var objStorage = getAccountStorage()>
		<cfset var stHPConfig = "">
		<cfset var accountsRoot = oAccountsConfigBean.getAccountsRoot()>
		
		<!--- validate username --->
		<cfset qry = getAccountByUsername(arguments.username)>
		<cfif qry.RecordCount gt 0>
			<cfthrow message="The given account name already exists. Please choose another." type="homeportals.accounts.usernameExists">
		</cfif>
		
		<cftry>
			<!--- insert record in account storage --->
			<cfset newUserID = objStorage.create(arguments.username, Arguments.Password, arguments.firstName, arguments.middleName, arguments.lastName, arguments.email)>
			
			<!--- get homeportals settings --->
			<cfset hpEngineRoot = oHomePortalsConfigBean.getHomePortalsPath()>
			
			<!--- create user space --->
			<cfset txtDefault = processTemplate(Arguments.Username,'#hpEngineRoot#/Common/AccountTemplates/index.txt')>
			<cfset txtPublic = processTemplate(Arguments.Username, oAccountsConfigBean.getNewAccountTemplate())>
			<cfset txtSite = processTemplate(Arguments.Username, oAccountsConfigBean.getSiteTemplate())>
	
			<!--- define locations for the default account files --->
			<cfset tmpAccoutDir = ExpandPath("#accountsRoot#/#Arguments.Username#/")>
			<cfset tmpAccPublic = ExpandPath("#accountsRoot#/#Arguments.Username#/layouts/" & GetFileFromPath(oAccountsConfigBean.getNewAccountTemplate()))>
			<cfset tmpAccDefault = ExpandPath("#accountsRoot#/#Arguments.Username#/index.cfm")>
			<cfset tmpAccSite = ExpandPath("#accountsRoot#/#Arguments.Username#/site.xml")>
			
			<!--- create directory structure --->
			<cftry>
				<cfif Not DirectoryExists(tmpAccoutDir)>
					<cfdirectory action="create" directory="#tmpAccoutDir#">
				</cfif>
				<cfif Not DirectoryExists(tmpAccoutDir & "/layouts")>
					<cfdirectory action="create" directory="#tmpAccoutDir#/layouts">
				</cfif>
				
				<cfcatch type="any">
					<cfthrow message="Could not create directory structure for new account. Account was not created. #cfcatch.message#" type="homePortals.accounts.directoryCreationException">			
				</cfcatch>
			</cftry>
	
			<!--- create public page --->
			<cffile action="write" file="#tmpAccPublic#" output="#txtPublic#"> 

			<!--- create default.htm --->
			<cffile action="write" file="#tmpAccDefault#" output="#txtDefault#"> 
			
			<!--- create site definition (only if a site template has been given) --->
			<cfif txtSite neq "">
				<cffile action="write" file="#tmpAccSite#" output="#txtSite#"> 
			</cfif>
			
			<cfcatch type="any">
				<cfset objStorage.delete(newUserID)>
				<cfrethrow>			
			</cfcatch>
		</cftry>
		
		<cfreturn newUserID>
	</cffunction>


	<!--------------------------------------->
	<!----  getAccountDefaultPage	    ----->
	<!--------------------------------------->
	<cffunction name="getAccountDefaultPage" access="public" hint="Returns the address of the account's main page." returntype="string">
		<cfargument name="accountName" type="string" required="yes">

		<cfset var defaultPageHREF = "">
		<cfset var oSite = 0>
		<cfset var defaultPageURL = "">	
		
		<cfset oSite = getSite(arguments.accountName)>

		<cfset defaultPageHREF = oSite.getDefaultPage()>

		<cfif defaultPageHREF neq "">
			<cfset defaultPageURL = variables.oAccountsConfigBean.getAccountsRoot()
									& "/" 
									& arguments.accountName 
									& "/layouts/" 
									& defaultPageHREF>
		</cfif>
		
		<cfreturn defaultPageURL>
	</cffunction>


	<!--------------------------------------->
	<!--- processTemplate				    --->
	<!--------------------------------------->
	<cffunction name="processTemplate" returntype="string" access="package">
		<cfargument name="UserName" type="string" required="yes">
		<cfargument name="TemplateName" type="string" required="yes">

		<cfset var tmpDoc = "">
		<cfset var tmpDocPath = ExpandPath(Arguments.TemplateName)>

		<cfset var homeURL = oHomePortalsConfigBean.getAppRoot()>
		<cfset var ModulesRoot = oHomePortalsConfigBean.getResourceLibraryPath() & "/Modules/">
		<cfset var accountsRoot = oAccountsConfigBean.getAccountsRoot()>

		<!--- read template file --->
		<cffile action="read" file="#tmpDocPath#" variable="tmpDoc">

		<!--- replace tokens --->
		<cfset tmpDoc = ReplaceList(tmpDoc,
									"$USERNAME$,$HOME$,$ACCOUNTS_ROOT$,$MODULES_ROOT$,$HOME_ROOT$",
									"#Arguments.Username#,#homeURL#,#AccountsRoot#,#ModulesRoot#,#homeURL#")>
		<cfreturn tmpDoc>
	</cffunction>




	<!--------------------------------------->
	<!----  updateAccount   			  ----->
	<!--------------------------------------->
	<cffunction name="updateAccount" access="public" hint="Updates account data.">
		<cfargument name="UserID" type="string" required="yes">
		<cfargument name="FirstName" type="string" required="yes">
		<cfargument name="MiddleName" type="string" required="yes">
		<cfargument name="LastName" type="string" required="yes">
		<cfargument name="Email" type="string" required="yes">
		
		<cfset var obj = getAccountStorage()>
		<cfset obj.update(arguments.userID, 
							arguments.FirstName, 
							arguments.MiddleName, 
							arguments.LastName, 
							arguments.Email)>
	</cffunction>

	<!--------------------------------------->
	<!----  delete          			----->
	<!--------------------------------------->
	<cffunction name="delete" access="public" hint="Deletes an account record and removes all files and account directory.">
		<cfargument name="UserID" type="string" required="yes">
		
		<cfset var objStorage = getAccountStorage()>
		<cfset var qryAccount = objStorage.search(arguments.userID)>
		<cfset var accountsRoot = oAccountsConfigBean.getAccountsRoot()>
		
		<cfif qryAccount.recordCount gt 0>
			<!--- delete record in table --->
			<cfset objStorage.delete(arguments.UserID)>
	
			<!--- delete directory and files --->
			<cfset tmpAccoutDir = ExpandPath("#accountsRoot#/#qryAccount.Username#/")>
			<cfif DirectoryExists(tmpAccoutDir)>
				<cfdirectory action="delete" directory="#tmpAccoutDir#" recurse="true">
			</cfif>
		</cfif>
		
	</cffunction>

	<!--------------------------------------->
	<!----  changePassword   			----->
	<!--------------------------------------->
	<cffunction name="changePassword" access="public" hint="Change accont password.">
		<cfargument name="UserID" type="string" required="yes">
		<cfargument name="NewPassword" type="string" required="yes">

		<cfset var objStorage = getAccountStorage()>
		<cfset objStorage.changePassword(arguments.UserID, arguments.NewPassword)>
	</cffunction>




	<!--------------------------------------->
	<!----  getFriendsService  			----->
	<!--------------------------------------->
	<cffunction name="getFriendsService" access="public" hint="Returns the friends service." returntype="friends">
		<cfreturn createObject("component","friends").init(oAccountsConfigBean)>
	</cffunction>

	<!--------------------------------------->
	<!----  getSite  			----->
	<!--------------------------------------->
	<cffunction name="getSite" access="public" hint="Returns the account's site object." returntype="site">
		<cfargument name="AccountName" type="string" required="yes">
		<cfreturn createObject("component","site").init(arguments.AccountName, this)>
	</cffunction>




	<!--- /*************************** Private Methods **********************************/ --->
	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
	</cffunction>
	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

			
</cfcomponent>
