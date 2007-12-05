<cfcomponent name="ehGeneral" extends="ehBase">
	
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

	<!----------------------------->
	<!--- App Event Handlers    --->
	<!----------------------------->
	<cffunction name="onApplicationStart" access="public" returntype="void">
		<cfscript>
			// instantiate license manager object
		//	application.licenseManager = createInstance(arguments.state.cfcPaths.license);
		</cfscript>
	</cffunction>

	<cffunction name="onRequestStart" access="public" returntype="void">
		<cfparam name="session.isLoggedIn" default="false">
		<cfparam name="session.mainMenuOption" default="Start">
		<cfscript>
			if (Not session.isLoggedIn and 
				Not ListFind("ehGeneral.dspLogin,ehGeneral.doLogin,ehGeneral.dspLicense,ehGeneral.doSetLicense",getValue("event"))) {
				SetNextEvent("ehGeneral.dspLogin");
			}
		</cfscript>
	</cffunction>


	<!------------------------------>
	<!--- Display Event Handlers --->
	<!------------------------------>
	<cffunction name="dspStart" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var qryAccounts = 0;
			var accountsRoot = 0;
			var stFeed = 0;
			var oLicense = 0;
			var trialExpirationDate = "";

			// get recent accounts
			try {
				oAccounts = createInstance("../Components/accounts.cfc");
				oAccounts.init(true, getSetting("HomeRoot"));
	
				// get recent accounts
				qryAccounts = oAccounts.GetUsers();
				
				// get accounts root
				accountsRoot = oAccounts.getConfig().accountsRoot;

			} catch(any e) {
				// account not initialized
			}
			
			
			// get homeportals feed
			try {
				stFeed = getHomePortalsRSS();
				
			} catch(any e) {
				// no feed
			}

			// for trial accounts, get expiration date
			oLicense = createInstance("../Components/license.cfc");
			trialExpirationDate = oLicense.getTrialExpirationDate();

			// pass values to view
			setValue("qryAccounts",qryAccounts);
			setValue("accountsRoot",accountsRoot);
			setValue("stFeed",stFeed);
			setValue("trialExpirationDate",trialExpirationDate);

			session.mainMenuOption = "Start";
			setView("vwStart");
		</cfscript>
	</cffunction>

	<cffunction name="dspLogin" access="public" returntype="void">
		<cfscript>
			var oLicense = 0;
			var stKeyCheck = structNew();
			
			try {
				// instantiate license manager object
				oLicense = createInstance("../Components/license.cfc");
				
				// get license info
				myLicense = oLicense.getLicenseKey();
				stKeyCheck = oLicense.validateLicenseKey(myLicense);
				
				if(not stKeyCheck.Valid) setNextEvent("ehGeneral.dspLicense");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message);
			}
					
			session.mainMenuOption = "";
			setView("vwLogin");
		</cfscript>
	</cffunction>

	<cffunction name="dspLicense" access="public" returntype="void">
		<cfscript>
			var oLicense = 0;
			var stLicenseCheck = structNew();
			var stLicense = structNew();
			var trialExpirationDate = "";
			
			try {
				// instantiate license manager object
				oLicense = createInstance("../Components/license.cfc");
				
				// get license info
				stLicense = oLicense.getLicenseKey();
				stLicenseCheck = oLicense.validateLicenseKey(stLicense);
				trialExpirationDate = oLicense.getTrialExpirationDate();

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message);
			}
					
			session.mainMenuOption = "";
			setValue("trialExpirationDate",trialExpirationDate);
			setView("vwLicense");
		</cfscript>
	</cffunction>



	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>
	<cffunction name="doLogin" access="public" returntype="void">
		<cfscript>
			var pwd = getValue("password","");
			var oLicense = 0;
			var bValid = false; 
			
			try {
				if(pwd eq "") throw("Password cannot be empty.");
				
				// instantiate license manager object
				oLicense = createInstance("../Components/license.cfc");
				
				// check if password is valid
				bValid = oLicense.verifyAdminPassword(pwd);
				
				if(Not bValid) throw("Invalid Password");

				// password is valid
				session.isLoggedIn = true;
				SetNextEvent("ehGeneral.dspStart");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message);
				setNextEvent("ehGeneral.dspLogin");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doLogout" access="public" returntype="void">
		<cfset session.isLoggedIn = false>
		<cfset structDelete(session, "currentSite")>
		<cfset structDelete(session, "currentPage")>
		<cfset SetNextEvent("ehGeneral.dspLogin")>
	</cffunction>

	<cffunction name="doSetLicense" access="public" returntype="void">
		<cfscript>
			var oLicense = 0;
			var licenseKey = getValue("licenseKey","");
			var isTrial = getValue("isTrial",false);
			var stKeyCheck = structNew();

			try {
				// instantiate license manager object
				oLicense = createInstance("../Components/license.cfc");
				
				// set new license
				oLicense.saveLicenseKey(licenseKey, isTrial);
				
				// get license info
				myLicense = oLicense.getLicenseKey();
				stKeyCheck = oLicense.validateLicenseKey(myLicense);
				if(not stKeyCheck.Valid) throw(stKeyCheck.message);
				setNextEvent("ehGeneral.dspLogin");
				
			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message);
				setNextEvent("ehGeneral.dspLicense");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doResetHomePortals" access="public" returntype="void">
		<cfset var tmpURL = getSetting("HOMEROOT") & "/?refreshApp=1&refresh=1">
		<cflocation url="#tmpURL#">
	</cffunction>


	<!-------------------------------------->
	<!--- getHomePortalsRSS              --->
	<!-------------------------------------->	
	<cffunction name="getHomePortalsRSS" access="public" returntype="struct">
		
		<cfset var xmlDoc = 0>
		<cfset var feed = StructNew()>
		<cfset var isRSS1 = false>
		<cfset var isRSS2 = false>
		<cfset var isAtom = false>
		<cfset var rss_url = getSetting("HomePortalsRSS")>

		<cfif rss_url eq "">
			<cfthrow message="HomePortals RSS URL not set.">
		</cfif>		

		<cfset variables.cacheDir = "./cache">
		
		<!--- replace "feed://" with "http://" --->
		<cfset arguments.url = ReplaceNoCase(rss_url,"feed://","http://")> 
			
		<!--- Check if feed is on cache--->
		<cfset cacheValid = false>
		<cfset cacheFileName = ReplaceList(rss_url,"/,:,?","_,_,_") & ".xml">
		<cfset cacheFile = ExpandPath(variables.cacheDir & "/" & cacheFileName)> 
		
		<!--- check if cache directory exists, otherwise create it --->
		<cfif not DirectoryExists(expandPath(variables.cacheDir))>
			<cfdirectory action="create" directory="#expandPath(variables.cacheDir)#" mode="777">
		</cfif>
		
		<!--- if there is a cache then check if it is less than 30 minutes old --->
		<cfif fileExists(cacheFile)>
			<cfdirectory action="list" directory="#ExpandPath(variables.cacheDir)#" name="qryDir" filter="#cacheFileName#">
			<cfif DateDiff("n", qryDir.dateLastModified, now()) lt 30>
				<cfset cacheValid = true>
			</cfif>
		</cfif>

		<!--- if cached data is valid, get it from there, otherwise, get from web --->
		<cfif cacheValid>
			<cffile action="read" file="#cacheFile#" variable="txtDoc">
			<cfset xmlDoc = XMLParse(txtDoc)>
		<cfelse>
			<cfhttp method="get" url="#rss_url#" 
					resolveurl="yes" redirect="yes" 
					throwonerror="true"></cfhttp>
			<!---
			<cfif Not IsXML(cfhttp.FileContent)>
				<cfthrow message="A problem ocurred while processing the requested link [<a href='#arguments.url#' target='_blank'>#arguments.url#</a>]. Check that the resource is available and is a valid RSS or Atom feed.">
			</cfif>
			--->
			<cfset xmlDoc = XMLParse(cfhttp.FileContent)>
			<cffile action="write" file="#cacheFile#" output="#toString(xmlDoc)#">	
		</cfif>
				
		<cfscript>
			feed.title = "";
			feed.link = "";
			feed.description = "";
			feed.date = "";
			feed.image = StructNew();
			feed.image.url = "";
			feed.image.title = "";
			feed.image.link = "##";
			feed.items = ArrayNew(1);
			
			// get feed type
			isRSS1 = StructKeyExists(xmlDoc.xmlRoot,"item");
			isRSS2 = StructKeyExists(xmlDoc.xmlRoot,"channel") and StructKeyExists(xmlDoc.xmlRoot.channel,"item");
			isAtom = StructKeyExists(xmlDoc.xmlRoot,"entry");
			
			// get title
			if(isRSS1 or isRSS2) {
				if(isRSS1) feed.items = xmlDoc.xmlRoot.item;
				if(isRSS2) feed.items = xmlDoc.xmlRoot.channel.item;
				
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"title")) feed.Title = xmlDoc.xmlRoot.channel.title.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"link")) feed.Link = xmlDoc.xmlRoot.channel.link.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"description")) feed.Description = xmlDoc.xmlRoot.channel.description.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"lastBuildDate")) feed.Date = xmlDoc.xmlRoot.channel.lastBuildDate.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot.channel,"image")) {
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"url")) feed.Image.URL = xmlDoc.xmlRoot.channel.image.url.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"title")) feed.Image.Title = xmlDoc.xmlRoot.channel.image.title.xmlText;
					if(StructKeyExists(xmlDoc.xmlRoot.channel.image,"link")) feed.Image.Link = xmlDoc.xmlRoot.channel.image.link.xmlText;
				}
			}
			if(isAtom) {
				if(isAtom) feed.items = xmlDoc.xmlRoot.entry;
				if(StructKeyExists(xmlDoc.xmlRoot,"title")) feed.Title = xmlDoc.xmlRoot.title.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"link")) feed.Link = xmlDoc.xmlRoot.link.xmlAttributes.href;
				if(StructKeyExists(xmlDoc.xmlRoot,"info")) feed.Description = xmlDoc.xmlRoot.info.xmlText;
				if(StructKeyExists(xmlDoc.xmlRoot,"modified")) feed.Date = xmlDoc.xmlRoot.modified.xmlText;
			}
		</cfscript>
		<cfreturn feed>
	</cffunction>

</cfcomponent>