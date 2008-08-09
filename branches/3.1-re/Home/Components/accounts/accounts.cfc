<cfcomponent displayname="accountsService" hint="This components acts as a service to perform account-related functions. The same instance of this component can perform actions on multiple accounts.">
	<cfscript>
		variables.configFilePath = "Config/accounts-config.xml.cfm";  // path of the config file relative to the root of the application
		variables.oAccountsConfigBean = 0;	// bean to store config settings
		variables.oHomePortalsConfigBean = 0;	// reference to the application settings
		variables.clientDAOPath = "Home.Components.accounts.db."; // here is where the DAO objects are located
		variables.oDataProvider = 0;	// provides access to account data storage
	</cfscript>

	<!--------------------------------------->
	<!----  init	 					----->
	<!--------------------------------------->
	<cffunction name="init" access="public" returntype="accounts" hint="Constructor">
		<cfargument name="configBean" type="Home.Components.homePortalsConfigBean" required="true" hint="HomePortals application settings">
		<cfscript>
			var pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
			var defaultConfigFilePath = "";
			var oConfigBean = 0;
			
			// copy reference to homeportals config bean
			setHomePortalsConfigBean( arguments.configBean );

			// create object to store configuration settings
			oConfigBean = createObject("component", "accountsConfigBean").init();

			// load default configuration settings
			defaultConfigFilePath = getDirectoryFromPath(getCurrentTemplatePath()) & pathSeparator & ".." & pathSeparator & ".." & pathSeparator & "Config" & pathSeparator & "accounts-config.xml.cfm";
			oConfigBean.load(defaultConfigFilePath);

			// load configuration settings for the application
			configFilePath = listAppend(getHomePortalsConfigBean().getAppRoot(), variables.configFilePath, "/");
			if(fileExists(expandPath(configFilePath)))
				oConfigBean.load(expandPath(configFilePath));
		
			// set accounts config bean
			setConfig( oConfigBean );
		
			// setup dataprovider
			loadDataProvider();
		
			return this;
		</cfscript>
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
		<cfset var qryAccount = queryNew("")>

		<!--- hash the password --->
		<cfif arguments.password eq "" and arguments.passwordHash neq "">
			<cfset pwdHSH = Arguments.passwordHash>
		<cfelse>		
			<cfset pwdHSH = Hash(Arguments.password)>
		</cfif>
		
		<!--- retrieve user information from the accounts storage --->
		<cfset qryAccount = getAccountByName(arguments.username)>

		<!--- validate the password --->
		<cfif (qryAccount.recordCount eq 0) or (qryAccount.password[1] neq pwdHSH)>
			<cfthrow message="Invalid account name or password" type="homePortals.accounts.invalidLogin">
		</cfif>			

		<!--- register user information into the user registry --->
		<!--- (this is to allow other components to access the current user information) --->
		<cfset oUserRegistry = createObject("component","Home.Components.userRegistry").init()>
		<cfset oUserRegistry.setUserInfo( qryAccount.accountID, qryAccount.userName, qryAccount )>
		
		<cfreturn qryAccount>
	</cffunction>
	
	<!--------------------------------------->
	<!----  logoutUser					----->
	<!--------------------------------------->
	<cffunction name="logoutUser" access="public" returntype="void" hint="Removes user information from the session">
		<cfset var oUserRegistry = 0>

		<!--- removes user information from the user registry --->
		<cfset oUserRegistry = createObject("component","Home.Components.userRegistry").init()>
		<cfset oUserRegistry.reinit()>
	</cffunction>


	<!--------------------------------------->
	<!----  getAccounts					----->
	<!--------------------------------------->
	<cffunction name="getAccounts" access="public" returntype="query" hint="Returns a query with all created accounts.">
		<cfset var oDAO = getDAO("Accounts")>
		<cfreturn oDAO.getAll()>
	</cffunction>

	<!--------------------------------------->
	<!----  search		 			    ----->
	<!--------------------------------------->
	<cffunction name="search" access="public" returntype="query" hint="Searches account records.">
		<cfargument name="accountname" type="string" required="no" default="">
		<cfargument name="lastname" type="string" required="no" default="">
		<cfargument name="email" type="string" required="no" default="">
		<cfset var oDAO = getDAO("Accounts")>
		<cfreturn oDAO.search(accountName = arguments.accountname, 
								lastName = arguments.lastName, 
								email = arguments.email)>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountByName			----->
	<!--------------------------------------->
	<cffunction name="getAccountByName" access="public" returntype="query" hint="Returns information about an account using the account name">
		<cfargument name="accountName" type="string" required="yes">
		<cfset var oDAO = getDAO("Accounts")>
		<cfreturn oDAO.search(accountName = arguments.accountname)>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountByID			    ----->
	<!--------------------------------------->
	<cffunction name="getAccountByID" access="public" returntype="query" hint="Returns information about an account using the account ID">
		<cfargument name="accountID" type="string" required="yes">
		<cfset var oDAO = getDAO("Accounts")>
		
		<!--- if the accountID is empty, then replace with -1 to avoid returning anything else --->
		<cfif arguments.accountID eq "">
			<cfset arguments.accountID = "-1">
		</cfif>
		
		<cfreturn oDAO.get(arguments.accountID)>
	</cffunction>



	<!--------------------------------------->
	<!----  createAccount				  ----->
	<!--------------------------------------->
	<cffunction name="createAccount" access="public" hint="Creates a new account" returntype="string">
		<cfargument name="accountName" type="string" required="yes">
		<cfargument name="Password" type="string" required="yes">
		<cfargument name="FirstName" type="string" required="no" default="">
		<cfargument name="MiddleName" type="string" required="no" default="">
		<cfargument name="LastName" type="string" required="no" default="">
		<cfargument name="Email" type="string" required="no" default="">
		
		<cfset var qry = 0>
		<cfset var txtDefault = "">
		<cfset var txtPublic = "">
		<cfset var tmpAccoutDir = "">
		<cfset var tmpAccPublic = "">
		<cfset var tmpAccDefault = "">
		<cfset var newAccountID = "">
		<cfset var oDAO = getDAO("Accounts")>
		<cfset var accountsRoot = oAccountsConfigBean.getAccountsRoot()>
		
		<!--- validate username --->
		<cfset qry = getAccountByName(arguments.accountName)>
		<cfif qry.RecordCount gt 0>
			<cfthrow message="The given account name already exists. Please choose another." type="homeportals.accounts.usernameExists">
		</cfif>
		
		<cftry>
			<!--- insert record in account storage --->
			<cfset newAccountID = oDAO.save(accountName = arguments.accountName, 
											Password = arguments.Password, 
											firstName = arguments.firstName, 
											middleName = arguments.middleName, 
											lastName = arguments.lastName, 
											email = arguments.email)>
			
			<!--- get homeportals settings --->
			<cfset hpEngineRoot = oHomePortalsConfigBean.getHomePortalsPath()>
			
			<!--- create user space --->
			<cfset txtDefault = processTemplate(Arguments.accountName,'#hpEngineRoot#/Common/AccountTemplates/index.txt')>
			<cfset txtPublic = processTemplate(Arguments.accountName, oAccountsConfigBean.getNewAccountTemplate())>
	
			<!--- define locations for the default account files --->
			<cfset tmpAccoutDir = ExpandPath("#accountsRoot#/#Arguments.accountName#/")>
			<cfset tmpAccPublic = ExpandPath("#accountsRoot#/#Arguments.accountName#/layouts/" & GetFileFromPath(oAccountsConfigBean.getNewAccountTemplate()))>
			<cfset tmpAccDefault = ExpandPath("#accountsRoot#/#Arguments.accountName#/index.cfm")>
			
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
			
			<cfcatch type="any">
				<cfset oDAO.delete(newAccountID)>
				<cfrethrow>			
			</cfcatch>
		</cftry>
		
		<cfreturn newAccountID>
	</cffunction>

	<!--------------------------------------->
	<!----  updateAccount   			  ----->
	<!--------------------------------------->
	<cffunction name="updateAccount" access="public" hint="Updates account data.">
		<cfargument name="accountID" type="string" required="yes">
		<cfargument name="FirstName" type="string" required="yes">
		<cfargument name="MiddleName" type="string" required="yes">
		<cfargument name="LastName" type="string" required="yes">
		<cfargument name="Email" type="string" required="yes">
		<cfset var oDAO = getDAO("Accounts")>
		<cfset oDAO.save(accountID = arguments.accountID,
							firstName = arguments.firstName, 
							middleName = arguments.middleName, 
							lastName = arguments.lastName, 
							email = arguments.email)>
	</cffunction>

	<!--------------------------------------->
	<!----  deleteAccount      			----->
	<!--------------------------------------->
	<cffunction name="deleteAccount" access="public" hint="Deletes an account record and removes all files and account directory.">
		<cfargument name="accountID" type="string" required="yes">
		
		<cfset var oDAO = getDAO("Accounts")>
		<cfset var qryAccount = oDAO.get(arguments.accountID)>
		<cfset var accountsRoot = getConfig().getAccountsRoot()>
		
		<cfif qryAccount.recordCount gt 0>
			<!--- delete record in table --->
			<cfset oDAO.delete(arguments.accountID)>
	
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
		<cfargument name="accountID" type="string" required="yes">
		<cfargument name="NewPassword" type="string" required="yes">
		<cfset var oDAO = getDAO("Accounts")>
		<cfset oDAO.save(accountID = arguments.accountID,
							password = arguments.NewPassword)>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountDefaultPage	    ----->
	<!--------------------------------------->
	<cffunction name="getAccountDefaultPage" access="public" hint="Returns the address of the account's main page." returntype="string">
		<cfargument name="accountName" type="string" required="yes">
		<cfset var oSite = 0>
		<cfset var defaultPageHREF = "">
		<cfset var defaultPageURL = "">	
		
		<!--- get the site object for this account --->
		<cfset oSite = getSite(arguments.accountName)>

		<!--- get the default page from the site --->
		<cfset defaultPageHREF = oSite.getDefaultPage()>

		<cfif defaultPageHREF neq "">
			<!--- if the default page contains the xml extension, then remove it --->
			<cfif right(defaultPageHREF,4) eq ".xml">
				<cfset defaultPageHREF = left(defaultPageHREF, len(defaultPageHREF)-4)>
			</cfif>
			
			<!--- get the location of the page --->
			<cfset defaultPageURL = getAccountPageHREF(arguments.accountName, defaultPageHREF)>
		</cfif>
		
		<cfreturn defaultPageURL>
	</cffunction>

	<!--------------------------------------->
	<!----  validatePageAccess		    ----->
	<!--------------------------------------->
	<cffunction name="validatePageAccess" access="public" returntype="void" hint="Validates access to a page">
		<cfargument name="page" type="Home.Components.pageBean" required="true">

		<cfscript>
			var oUserRegistry = 0;
			var stUserInfo = 0;
			var oFriendsService = 0;
			var accessLevel = arguments.page.getAccess();
			var owner = arguments.page.getOwner();
			
			if(accessLevel eq "friend" or accessLevel eq "owner") {
				// access to this page is restricted, so we must
				// check who is the current user
				oUserRegistry = createObject("component","Home.Components.userRegistry").init();
				stUserInfo = oUserRegistry.getUserInfo();
				
				// if not user logged in, then get out
				if(stUserInfo.userID eq "")
					throw("Access to this page is restricted. Please sign-in to validate access","","homePortals.engine.unauthorizedAccess");	

				// if logged in is the owner, then we are good
				if(stUserInfo.userName eq owner) 
					return;

				// validate owner-only page
				if(accessLevel eq "owner") 
					throw("Access to this page is restricted to the page owner.","","homePortals.engine.unauthorizedAccess");	
					
				// check that user is friend	
				if(accessLevel eq "friend") {
					
					// check if current friend is a friend of the owner
					oFriendsService = getFriendsService();
					
					if( not oFriendsService.isFriend(owner, stUserInfo.username) ) {
						throw("You must be a friend of the owner to access this page.","","homePortals.engine.unauthorizedAccess");	
					}
				
				}	
			} 
		</cfscript>
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

	<!--------------------------------------->
	<!----  getAccountPageHREF 			----->
	<!--------------------------------------->
	<cffunction name="getAccountPageHREF" access="public" hint="Returns the address of the page belonging to an account" returntype="string">
		<cfargument name="account" type="string" required="false" default="" hint="Account name, if empty will load the default account">
		<cfargument name="page" type="string" required="false" default="" hint="Page within the account, if empty will load the default page for the account">
		<cfscript>
			var pageHREF = "";
						
			// determine the page to load
			if(arguments.account eq "") arguments.account = getConfig().getDefaultAccount();
			
			if(arguments.page eq "") 
				pageHREF = getAccountDefaultPage(arguments.account);
			else
				pageHREF = getConfig().getAccountsRoot() & "/" & arguments.account & "/layouts/" & arguments.page & ".xml";

			return pageHREF;
		</cfscript>	
	</cffunction>

	<!--------------------------------------->
	<!----  getNewPage		 			----->
	<!--------------------------------------->
	<cffunction name="getNewPage" access="public" hint="Returns a page object for a new page based on the newPage template" returntype="pageBean">
		<cfargument name="AccountName" type="string" required="yes">
		<cfscript>
			var oConfig = getConfig();
			var oPage = 0;
			var xmlStr = "";
			
			// if a template for new pages has been defined then use that for the new page
			if(oConfig.getNewPageTemplate() eq "") {

				// get new page and process tokens
				xmlStr = processTemplate(arguments.accountName, oConfig.getNewPageTemplate());
	
				// convert into xml document
				oPage = createObject("component","Home.Components.pageBean").init(xmlStr);
			
			} else {
				// no template defined, so just get a blank page
				oPage = createObject("component","Home.Components.pageBean").init();
			}

			return oPage;
		</cfscript>
	</cffunction>



	<!--- /*************************** getters / setters **********************************/ ---->
	<cffunction name="getConfig" access="public" returntype="accountsConfigBean">
		<cfreturn variables.oAccountsConfigBean>
	</cffunction>

	<cffunction name="setConfig" access="public" returntype="void">
		<cfargument name="data" type="accountsConfigBean" required="true">
		<cfset variables.oAccountsConfigBean = arguments.data>
	</cffunction>
	
	<cffunction name="getHomePortalsConfigBean" access="public" returntype="Home.Components.homePortalsConfigBean">
		<cfreturn variables.oHomePortalsConfigBean>
	</cffunction>

	<cffunction name="setHomePortalsConfigBean" access="public" returntype="void">
		<cfargument name="data" type="Home.Components.homePortalsConfigBean" required="true">
		<cfset variables.oHomePortalsConfigBean = arguments.data>
	</cffunction>

	<cffunction name="getDataProvider" access="public" returntype="Home.Components.accounts.lib.DAOFactory.dataProvider">
		<cfreturn variables.oDataProvider>
	</cffunction>

	<cffunction name="setDataProvider" access="public" returntype="void">
		<cfargument name="data" type="Home.Components.lib.DAOFactory.dataProvider" required="true">
		<cfset variables.oDataProvider = arguments.data>
	</cffunction>



	<!--- /*************************** Private Methods **********************************/ --->
	
	<!--------------------------------------->
	<!--- loadDataProvider 	        	  --->
	<!--------------------------------------->
	<cffunction name="loadDataProvider" access="private" returntype="void" hint="Loads and configures the instance of the dataprovider to be used">
		<cfscript>
			var storageType = oAccountsConfigBean.getStorageType();
			var pkgPath = "Home.Components.lib.DAOFactory.";
			var oConfigBean = 0;

			// check that dataprovider exists
			if(not fileExists(expandPath("/Home/Components/lib/DAOFactory/" & storageType & "DataProviderConfigBean.cfc")))
				throw("Accounts storage type [#storageType#] is not supported","","homePortals.accounts.invalidStorageType");
					
			// create config		
			oConfigBean = createObject("component", pkgPath & storageType & "DataProviderConfigBean").init();
			
			// configure bean
			switch(storageType) {
				case "db":
					oConfigBean.setDSN( getConfig().getDatasource() );
					oConfigBean.setUsername( getConfig().getUsername() );
					oConfigBean.setPassword( getConfig().getPassword() );
					oConfigBean.setDBType( getConfig().getDBType() );
					break;
					
				case "xml":
					oConfigBean.setDataRoot( getConfig().getAccountsRoot() );
					break;
			}

			// initialize dataProvider
			variables.oDataProvider = createObject("component", pkgPath & storageType & "DataProvider").init(oConfigBean);
		</cfscript>	
	</cffunction>	

	<!--------------------------------------->
	<!--- getDAO		 	        	  --->
	<!--------------------------------------->
	<cffunction name="getDAO" access="package" returntype="DAO" hint="returns a properly configured instance of a DAO">
		<cfargument name="entity" type="string" required="true">
		<cfset var oDAO = createObject("component", variables.clientDAOPath & arguments.entity & "DAO")>
		<cfset oDAO.init(variables.oDataProvider)>
		<cfreturn oDAO>
	</cffunction>	

	<!--------------------------------------->
	<!--- processTemplate				    --->
	<!--------------------------------------->
	<cffunction name="processTemplate" returntype="private" access="package">
		<cfargument name="accountName" type="string" required="yes">
		<cfargument name="templateName" type="string" required="yes">

		<cfset var tmpDoc = "">
		<cfset var tmpDocPath = ExpandPath(Arguments.TemplateName)>

		<cfset var appRoot = getHomePortalsConfigBean().getAppRoot()>
		<cfset var accountsRoot = getConfig().getAccountsRoot()>

		<!--- read template file --->
		<cffile action="read" file="#tmpDocPath#" variable="tmpDoc">

		<!--- replace tokens --->
		<cfset tmpDoc = ReplaceList(tmpDoc,
									"$ACCOUNT_NAME$,$ACCOUNTS_ROOT$,$APP_ROOT$",
									"#Arguments.accountName#,#AccountsRoot#,#appRoot#")>
		<cfreturn tmpDoc>
	</cffunction>

	
	
	<cffunction name="dump" access="private" hint="facade for cfdump">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
	</cffunction>

	<cffunction name="abort" access="private" hint="facade for cfabort">
		<cfabort>
	</cffunction>
		
	<cffunction name="throw" access="private" hint="facade for cfthrow">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

			
</cfcomponent>
