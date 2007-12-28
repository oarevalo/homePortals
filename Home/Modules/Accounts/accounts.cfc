<cfcomponent>
	<cfscript>
		this.stConfig = StructNew();
		
		// location of the xml file to store account settings
		this.configFilePath = GetDirectoryFromPath(GetCurrentTemplatePath()) & "../../Config/accounts-config.xml";
		
		// list of keys on the config structure
		this.configKeys = "version,accountsRoot,homeRoot,mailServer,emailAddress,newAccountTemplate,newPageTemplate,siteTemplate,allowRegisterAccount,storageType,storageCFC";
	</cfscript>

	<!--------------------------------------->
	<!----  loadConfig 					----->
	<!--------------------------------------->
	<cffunction name="loadConfig" access="public">
		<cfscript>
			var tmpXML = "";
			var xmlConfigDoc = 0;
			var i = 0;
			var xmlNode = 0;
		
			// ***** Get accounts configuration ******
			tmpXML = readFile(this.configFilePath);
			if(Not IsXML(tmpXML)) throw("The given Accounts Config file is not a valid XML document.");
			xmlConfigDoc = xmlParse(tmpXML);
		
			this.stConfig = structNew();
			for(i=1;i lte listLen(this.configKeys);i=i+1) {
				this.stConfig[listGetAt(this.configKeys,i)] = "";
			}
			this.stConfig.allowRegisterAccount = false;
			this.stConfig.storageType = "db";
				
			for(i=1;i lte ArrayLen(xmlConfigDoc.xmlRoot.xmlChildren);i=i+1) {
				// get poiner to current node
				xmlNode = xmlConfigDoc.xmlRoot.xmlChildren[i];
				tmpString = xmlUnformat(xmlNode.xmlText);
				if(tmpString neq "") tmpString = decrypt(tmpString, getServerKey());
				
				this.stConfig[xmlNode.xmlName] = tmpString;
			}
		</cfscript>
	</cffunction>
	
	<!--------------------------------------->
	<!----  saveConfig				  ----->
	<!--------------------------------------->
	<cffunction name="saveConfig" access="public">

		<cfset var xmlConfigDoc = "">
		<cfset var xmlOriginalConfigDoc = "">
		<cfset var backupFileName = "">
		<cfset var tmpKeyList = "">

		<cfscript>
			// ***** Get account settings ******
			tmpXML = readFile(this.configFilePath);
			if(Not IsXML(tmpXML)) throw("The given Accounts Config file is not a valid XML document.");
			xmlConfigDoc = xmlParse(tmpXML);		
			xmlOriginalConfigDoc = xmlParse(tmpXML);		
			
			// define name for backup file
			backupFileName = ReplaceNoCase(this.configFilePath,".xml",".bak");
			
			// add config keys for storage
			oStorage = getAccountStorage();
			lstStorageAttributes = oStorage.getStorageSettingsList();
			
			tmpKeyList = listAppend(this.configKeys, lstStorageAttributes);
			
			// save simple value settings
			for(i=1;i lte ListLen(tmpKeyList);i=i+1) {
				thisKey = ListGetAt(tmpKeyList,i);

				if(Not StructKeyExists(xmlConfigDoc.xmlRoot,thisKey))  {
					arrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, xmlElemNew(xmlConfigDoc,thisKey));
				}

				if(structKeyExists(this.stConfig,thisKey) and this.stConfig[thisKey] neq "")
					tmpString = encrypt(this.stConfig[thisKey], getServerKey());
				else
					tmpString = "";

				xmlConfigDoc.xmlRoot[thisKey].xmlText = xmlFormat(tmpString);
			}
		</cfscript>		
		
		<!--- store page --->
		<cffile action="write" file="#this.configFilePath#" output="#toString(xmlConfigDoc)#">

		<!--- store backup --->
		<cffile action="write" file="#backupFileName#" output="#toString(xmlOriginalConfigDoc)#">
	</cffunction>

	<!--------------------------------------->
	<!----  setConfig					----->
	<!--------------------------------------->
	<cffunction name="setConfig" access="public">
		<cfargument name="data" type="struct" required="yes">
		<cfset this.stConfig = Duplicate(arguments.data)>
	</cffunction>

	<!--------------------------------------->
	<!----  getConfig					----->
	<!--------------------------------------->
	<cffunction name="getConfig" access="public" returntype="struct">
		<cfreturn this.stConfig>
	</cffunction>
				
	<!--------------------------------------->
	<!--- getAccountStorage  		        --->
	<!--------------------------------------->
	<cffunction name="getAccountStorage" access="public" returntype="storage"
				hint="Returns the storage object for the type of storage selected">

		<cfset var obj = createObject("component","storage")>
		
		<cfif Not StructKeyExists(this.stConfig, "storageType")>
			<cfthrow message="Object not intialized properly. Please load configuration before calling this method.">
		</cfif>
		
		<cfswitch expression="#this.stConfig.storageType#">
			<cfcase value="db">
				<cfset storageCFC = "dbStorage">
			</cfcase>
			<cfcase value="xml">
				<cfset storageCFC = "xmlStorage">
			</cfcase>
			<cfcase value="custom">
				<cfset storageCFC = this.stConfig.storageCFC>
			</cfcase>
			<cfdefaultcase>
				<cfthrow message="Unknown storage type!">
			</cfdefaultcase>
		</cfswitch>
		
		<cfif storageCFC neq "">
			<cfset obj = createObject("component",storageCFC)>
			<cfset obj.setConfig(this.stConfig)>
		</cfif>
		<cfreturn obj>
	</cffunction>	

	
	<!--------------------------------------->
	<!----  GetUsers					----->
	<!--------------------------------------->
	<cffunction name="GetUsers" access="public" returntype="query" hint="Returns a query with recently created accounts.">
		<cfargument name="maxRows" type="numeric" required="no" default="11">
		<cfreturn getAccountStorage().search("","","","",arguments.maxRows,"createDate,username")>
	</cffunction>

	<!--------------------------------------->
	<!----  checkLogin					----->
	<!--------------------------------------->
	<cffunction name="checkLogin" access="public" returntype="query" hint="Returns a query with the account matching the given login info.">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		
		<cfset var qryRet = QueryNew("")>
		<cfset var qryUser = QueryNew("")>
		<cfset var pwdHSH = Hash(Arguments.password)>
		<cfset var obj = getAccountStorage()>

		<cfset qryUser = obj.search("",arguments.username)>

		<cfif (qryUser.recordCount gt 0) and (qryUser.password[1] eq pwdHSH)>
			<cfset qryRet = qryUser>
		</cfif>			

		<cfreturn qryRet>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountByUsername		  ----->
	<!--------------------------------------->
	<cffunction name="getAccountByUsername" access="public" returntype="query" hint="Returns info on a user.">
		<cfargument name="username" type="string" required="yes">
		<cfreturn getAccountStorage().search("",arguments.username)>
	</cffunction>

	<!--------------------------------------->
	<!----  createAccount				  ----->
	<!--------------------------------------->
	<cffunction name="createAccount" access="public" hint="Creates a new account" returntype="string">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="Password" type="string" required="yes">
		<cfargument name="Email" type="string" required="yes">
		
		<cfset var qry = 0>
		<cfset var oHP = 0>
		<cfset var txtDefault = "">
		<cfset var txtPublic = "">
		<cfset var txtSite = "">
		<cfset var txtContent = "">
		<cfset var tmpAccoutDir = "">
		<cfset var tmpAccPublic = "">
		<cfset var tmpAccDefault = "">
		<cfset var tmpAccSite = "">
		<cfset var tmpAccContent = "">
		<cfset var homePortalsCFCPath = "">
		<cfset var newUserID = createUUID()>
		<cfset var objStorage = getAccountStorage()>
		<cfset var stHPConfig = "">
		
		<!--- validate username --->
		<cfset qry = this.getAccountByUsername(arguments.username)>
		<cfif qry.RecordCount gt 0>
			<cfthrow message="That username is already taken. Please choose another.">
		</cfif>
		
		<cftry>
			<!--- insert record in account storage --->
			<cfset newUserID = objStorage.create(arguments.username, Arguments.Password, arguments.Email)>
			
			<!--- get homeportals settings --->
			<cfset homePortalsCFCPath = ListAppend(application.homePortalsRoot, "Components/homePortals", "/")>
			<cfset oHP = CreateObject("component", homePortalsCFCPath)>
			<cfset oHP.init()>
			<cfset stHPConfig = oHP.getConfig()>	
			
			<!--- create user space --->
			<cfset txtDefault = processTemplate(Arguments.Username,'#this.stConfig.accountsRoot#/default/Templates/index.cfm',stHPConfig)>
			<cfset txtPublic = processTemplate(Arguments.Username, this.stConfig.newAccountTemplate, stHPConfig)>
			<cfset txtSite = processTemplate(Arguments.Username, this.stConfig.siteTemplate, stHPConfig)>
	
			<cfset tmpAccoutDir = ExpandPath("#this.stConfig.accountsRoot#/#Arguments.Username#/")>
			<cfset tmpAccPublic = ExpandPath("#this.stConfig.accountsRoot#/#Arguments.Username#/layouts/" & GetFileFromPath(this.stConfig.newAccountTemplate))>
			<cfset tmpAccDefault = ExpandPath("#this.stConfig.accountsRoot#/#Arguments.Username#/index.cfm")>
			<cfset tmpAccSite = ExpandPath("#this.stConfig.accountsRoot#/#Arguments.Username#/site.xml")>
			
			<!--- create directory structure --->
			<cftry>
				<cfif Not DirectoryExists(tmpAccoutDir)>
					<cfdirectory action="create" directory="#tmpAccoutDir#">
				</cfif>
				<cfif Not DirectoryExists(tmpAccoutDir & "/layouts")>
					<cfdirectory action="create" directory="#tmpAccoutDir#/layouts">
				</cfif>
				
				<cfcatch type="any">
					<cfthrow message="Could not create directory structure for new account. Account was not created. #cfcatch.message#">			
				</cfcatch>
			</cftry>
	
			<!--- create public page --->
			<cffile action="write" file="#tmpAccPublic#" output="#txtPublic#"> 

			<!--- create default.htm --->
			<cffile action="write" file="#tmpAccDefault#" output="#txtDefault#"> 
			
			<!--- create site definition --->
			<cffile action="write" file="#tmpAccSite#" output="#txtSite#"> 
			
			<cfcatch type="any">
				<cfset objStorage.delete(newUserID)>
				<cfrethrow>			
			</cfcatch>
		</cftry>
		
		<cfreturn newUserID>
	</cffunction>

	<!--------------------------------------->
	<!----  gotoAccount  				  ----->
	<!--------------------------------------->
	<cffunction name="gotoAccount" access="public" hint="Redirects browse to accounts main page. If main page is private displays a message.">
		<cfargument name="username" type="string" required="yes">
			
		<!--- get accounts config --->
		<cfset LoadConfig()>
	
		<!--- define default page to go --->	
		<cfset defaultPageHREF = "">
		<cfset defaultPageURL = this.stConfig.homeRoot>	
		
		<!--- read site definition --->
		<cfset siteURL = this.stConfig.accountsRoot & "/" & arguments.username & "/site.xml">
		<cfset txtSiteDoc = readFile(ExpandPath(siteURL))>
		<cfset xmlSiteDoc = xmlParse(txtSiteDoc)>
		
		<!--- get site pages --->
		<cfset aPages = xmlSiteDoc.xmlRoot.pages>
		
		<!--- find default page (in case there is more than one, we use the first one we find) --->
		<cfloop from="1" to="#arrayLen(aPages.xmlChildren)#" index="i">
			<cfset thisPage = aPages.xmlChildren[i]>
			<cfparam name="thisPage.xmlAttributes.default" default="false">
			<cfparam name="thisPage.xmlAttributes.private" default="false">
			<cfif isboolean(thisPage.xmlAttributes.default) and thisPage.xmlAttributes.default>
				<cfset defaultPageHREF = thisPage.xmlAttributes.href>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<!--- if there is no default page defined for this account, go to the first one --->
		<cfif defaultPageHREF eq "" and arrayLen(aPages.xmlChildren) gt 0>
			<cfset defaultPageHREF = aPages.xmlChildren[1].xmlAttributes.href>
		</cfif>
		
		<!--- if we found a page within the account then go there --->
		<cfif defaultPageURL neq "">
			<cfset defaultPageURL = this.stConfig.homeRoot 
									& "/index.cfm?currentHome=" 
									& this.stConfig.accountsRoot 
									& "/" & arguments.username & "/layouts/" 
									& defaultPageHREF>
		</cfif>

		<!--- redirect to the selected page --->
		<cfoutput>
			<script type="text/javascript">
				window.location.replace("#defaultPageURL#");
			</script>
		</cfoutput>
	</cffunction>


	<!--------------------------------------->
	<!--- processTemplate				    --->
	<!--------------------------------------->
	<cffunction name="processTemplate" returntype="string" access="public">
		<cfargument name="UserName" type="string" required="yes">
		<cfargument name="TemplateName" type="string" required="yes">
		<cfargument name="HomePortalsConfig" type="struct" required="yes">

		<cfset var tmpDoc = "">
		<cfset var tmpDocPath = ExpandPath(Arguments.TemplateName)>

		<cfset var homeURL = Arguments.HomePortalsConfig.homePortalsPath & "index.cfm">
		<cfset var ModulesRoot = Arguments.HomePortalsConfig.moduleLibraryPath>

		<!--- read template file --->
		<cffile action="read" file="#tmpDocPath#" variable="tmpDoc">

		<!--- replace tokens --->
		<cfset tmpDoc = ReplaceList(tmpDoc,
									"$USERNAME$,$HOME$,$ACCOUNTS_ROOT$,$MODULES_ROOT$,$HOME_ROOT$",
									"#Arguments.Username#,#homeURL#,#this.stConfig.AccountsRoot#,#ModulesRoot#,#Arguments.HomePortalsConfig.homePortalsPath#")>
		<cfreturn tmpDoc>
	</cffunction>

	<!--------------------------------------->
	<!----  SearchUsers				  ----->
	<!--------------------------------------->
	<cffunction name="SearchUsers" access="public" returntype="query" hint="Searches account records.">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="lastname" type="string" required="yes">
		<cfargument name="email" type="string" required="yes">
		<cfreturn getAccountStorage().search("",arguments.username, arguments.lastName, arguments.email)>
	</cffunction>

	<!--------------------------------------->
	<!----  getAccountByUserID		  ----->
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
		
		<cfif qryAccount.recordCount gt 0>
			<!--- delete record in table --->
			<cfset objStorage.delete(arguments.UserID)>
	
			<!--- delete directory and files --->
			<cfset tmpAccoutDir = ExpandPath("#this.stConfig.accountsRoot#/#qryAccount.Username#/")>
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


	<!--- /*************************** Private Methods **********************************/ --->


	<!--- ************************************ --->
	<!--- * dump						 	 * --->
	<!--- ************************************ --->
	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
	</cffunction>
	
	
	<!--- ************************************ --->
	<!--- * throw						 	 * --->
	<!--- ************************************ --->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>
	

	<!--- ************************************ --->
	<!--- * readFile						 * --->
	<!--- ************************************ --->
	<cffunction name="readFile" returntype="string" access="private" hint="reads a file from the filesystem and returns its contents">
		<cfargument name="file" type="string">
		<cftry>
			<cffile action="read" file="#arguments.file#" variable="tmp"> 
			
			<cfcatch type="any">
				<cfif cfcatch.Type eq "Application" and FindNoCase("FileNotFound",cfcatch.Detail)>
					<cfset throw("The requested file [#arguments.file#] does not exist.")>
				<cfelse>
					<cfrethrow>
				</cfif>
			</cfcatch>
		</cftry>
		<cfreturn tmp>
	</cffunction>
	

	<!--- ************************************ --->
	<!--- * XMLUnFormat						 * --->
	<!--- ************************************ --->
	<cffunction name="XMLUnFormat" access="private" returntype="string">
		<cfargument name="string" type="string" default="">
		<cfscript>
			var resultString=arguments.string;
			resultString=ReplaceNoCase(resultString,"&apos;","'","ALL");
			resultString=ReplaceNoCase(resultString,"&quot;","""","ALL");
			resultString=ReplaceNoCase(resultString,"&lt;","<","ALL");
			resultString=ReplaceNoCase(resultString,"&gt;",">","ALL");
			resultString=ReplaceNoCase(resultString,"&amp;","&","ALL");
		</cfscript>
		<cfreturn resultString>
	</cffunction>	


	<!--- ************************************ --->
	<!--- * getServerKey					 * --->
	<!--- ************************************ --->
	<cffunction name="getServerKey" access="private" returntype="string" hint="returns the key used to encrypt values on this server.">
		<cfset var myServerKey = "cotahuasi_#cgi.HTTP_HOST#">
		<cfreturn myServerKey>
	</cffunction>

			
</cfcomponent>
