<cftry>

<!--- index.cfm

<doc>
	This is the main page for the HomePortals framework. All links must point to this page.
	To load a particular application, indicate the path of the XML definition for
	that application using the CurrentHome url variable.
</doc>

Change History: 
6/18/03 - oarevalo
7/15/04 - oarevalo - added "basePath" attribute to Modules tag. This indicates a default path to locate modules
10/1/04 - oarevalo - removed cookies functionality
10/28/04 - oarevalo - added event listeners
11/3/04 - oarevalo - add check to see if running on cfmx, so xml can be improved
9/26/05 - oarevalo - modified logic in Home.cfm to parse the entire config xml on the first run
					so that following invocations of the same page have a lot less of processing to do.
				   - removed "loginService" logic, since it can be implemented via modules and event handlers.
				   - added protocol parameter to be able to choose between http and https when calling config pages
				   - changed javascript backend library from DOMAPI to prototype (http://prototype.conio.net)
				    prototype is more newer, lighter and goes straight to the point of the server side calls.
					Using prototype makes easier to create the server side components, they no longer need to
					create a special format for the returned text, so there is no need to use the buildOutput 
					method anymore, however, i changed it so I don;t have to make many changes on the modules.
					Unluckily there is one needed change, now the output of the remote components is now processed
					directly as html, which means that if a module calls a javscript function, now these calls
					must be wrapped within <script> tags.
11/10/05 - oarevalo - moved debug info to a separate page. Changed debug info layout and added link to current config page.
					- added a separate configuration file for server-wide settings
					- removed onLoadStack, now all initial javascript execution should be driven handled via events
					- pages are loaded using the file system, this is faster than doing an http request
11/11/05 - oarevalo - Moved all processing into the page initialization.
					- Created HomePortals.cfc to handle all parsing of settings and pages.
					- custom tags showLayoutSection and showModule are no longer used, all their functionality
					  has been moved into the HomePortals.cfc
1/4/06 - oarevalo   - Added license control. Each time HomePortals settings are initialized, it
					will look if it has a valid license. If so, then processing continues as normal,
					otherwise an error is thrown and processing stops. 
					To set the license, the administrator must go to /home/license.cfm and enter the
					license. Licenses are domain and host specific.
3/21/06 - oarevalo  - Added custom headers and footers that are always displayed for each page. These are defined
					as part of the base resources on the config.xml	
7/16/05 - oarevalo  - HomePortals 2.0  page is no longer named home.cfm, now its index.cfm
--->

<!------- Page parameters ----------->
<cfparam name="currentHome" default=""> <!--- HomePortals page to load --->
<cfparam name="debug" default="false"> 	<!--- Flag to display debugging info --->
<cfparam name="refresh" default="false"> <!--- Force a reload and parse of the current HomePortals page --->
<cfparam name="refreshApp" default="false"> <!--- Force a reload and parse of the HomePortals application --->
<!----------------------------------->

<cfscript>
	if(Not isBoolean(debug)) debug = false;
	if(Not isBoolean(refresh)) refresh = false;
	if(Not isBoolean(refreshApp)) refreshApp = false;
	
	// define app reload conditions
	refreshApp = refreshApp
				or (Not StructKeyExists(application, "homePortalsRoot"))
				or (Not StructKeyExists(application, "AccountsManager"));

	// initialize HomePortal object
	tmpHomePath = GetDirectoryFromPath(cgi.script_Name);

	// check if we have a SES path for the current page, and if it does, check for other URL parameters
	pathInfo = reReplaceNoCase(trim(cgi.path_info), ".+\.cfm/? *", "");
	SESpath = pathInfo;
	isSESpath = (listLen(pathInfo,"/") eq 2);
	hasParams = (listLen(pathInfo,"&") gt 1);
	if(hasParams and isSESPath) {
		for(i=1;i lte listLen(pathInfo,"&");i=i+1) {
			tmpUrlPart = listGetAt(pathInfo,i,"&");
			if(listLen(tmpUrlPart,"=") gt 1) {
				variables[listFirst(tmpURLPart,"=")] = listLast(tmpURLPart,"=");
			} 
			if(listLen(tmpUrlPart,"/") eq 2) SESpath = tmpUrlPart;
		}
	}

	// Refresh application settings
	if(refreshApp) {
		// clean all application level structures
		StructDelete(application,"HomeSettings");
		StructDelete(application,"moduleProperties");
		StructDelete(application,"AccountsManager");
		StructDelete(application,"homePortalsRoot");
		StructDelete(application,"catalog");

		// check license (only when refreshing the application)
		oLicense = CreateObject("component","Components.license");
		stLicense = oLicense.getLicenseKey();
		stLicenseCheck = oLicense.validateLicenseKey(stLicense);
		if(Not stLicenseCheck.valid) {
			if(stLicenseCheck.message eq "invalid key.")
				throw("This installation of HomePortals does not have a valid license.");
			else
				throw(stLicenseCheck.message);
		}

		// set an application variable so that anyone will be able to find
		// where all the HomePortals stuff is located
		application.homePortalsRoot = tmpHomePath;
		
		// instantiate the accounts manager object, and cache it in memory
		oAccounts = CreateObject("Component","Components.accounts");
		oAccounts.init(true, tmpHomePath);
		application.AccountsManager = oAccounts;

		// instantiate the catalog and cache it in memory
		oCatalog = CreateObject("Component","Components.catalog");
		oCatalog.init(tmpHomePath);
		application.catalog = oCatalog;
	}

	// initialize HomePortals object
	oHP = CreateObject("component","Components.homePortals");
	oHP.init(refreshApp, tmpHomePath);

	// check for the SES way to specify pages
	if(isSESpath) {
		// we are only looking for the form: /<account_name>/<page_name>
		accountName = listFirst(SESpath,"/");
		pageName = listLast(SESpath,"/");
		if(right(pageName,4) neq ".xml") pageName = pageName & ".xml";  // so that we can have only the page name without the extension
		
		// get the accounts root
		stAccountsConfig = application.accountsManager.getConfig(); 
		accountsRoot = stAccountsConfig.accountsRoot;
			
		// build the actual path to the page
		currentHome = accountsRoot & "/" & accountName & "/layouts/" & pageName;		

	} else if(currentHome eq "") {
		// Use the default page of the default account if no other page is given
		defAccount = oHP.getDefaultAccount();
		currentHome = application.AccountsManager.getAccountDefaultPage(defAccount);
	}

	// define refresh condition
	refresh = refresh 
				or refreshApp
				or (Not StructKeyExists(session, "homeConfig"))
				or (StructKeyExists(session, "homeConfig") and session.HomeConfig.href neq currentHome);

	// load page
	if(refresh) {
		oHP.loadPage(currentHome);
		HomeConfig = oHP.getPage();
		Session.HomeConfig = duplicate(HomeConfig);
		
		// clear config beans persistent storage
		oConfigBeanStore = createObject("component","Components.configBeanStore");
		oConfigBeanStore.flushAll();
	} else  {
		HomeConfig = Session.HomeConfig;
		oHP.setPage(HomeConfig);
	}
	
	// write the current home on a cookie, so it can obtained anywhere
	cookie.hp_currentHome = currentHome;
	
	// process modules in this page
	oHP.processModules();
</cfscript>


<cfoutput>
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<!-- Page rendered using  HomePortals Server on #lsDateFormat(now())# #LSTimeFormat(now())# -->
			<title>#HomeConfig.page.title#</title>
			<META name="generator" content="HomePortals Portal Framework">
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
			<meta http-equiv="Expires" content="0">
			<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
			<META name="expires" content="0">
			<cfheader name="Expires" value="0">
			<cfheader name="Pragma" value="no-cache">
			<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
			#oHP.renderHTMLHeadCode()#
		</head>

		<body onLoad="#oHP.getBodyOnLoad()#">
			<!--- Render custom headers --->
			#oHP.renderCustomSection("header")#
			
			<!--- Header Sections --->
			#oHP.renderLayoutSection("header","div")#

			<!--- Column sections --->
			<table border="0" cellspacing="0" cellpadding="0" width="100%" id="h_body_main">
				<tr>#oHP.renderLayoutSection("column","td")#</tr>
			</table>

			<!--- Footer sections --->
			#oHP.renderLayoutSection("footer","div")#	

			<!--- Render custom footers --->
			#oHP.renderCustomSection("footer")#
		</body>
	</html>
</cfoutput>

<!--- display debug info if required --->
<cfif debug>
	<cfinclude template="Common/Templates/debugInfo.cfm">
</cfif>

<!--- Error handling routines --->
<cfcatch type="any">
	<cfinclude template="Common/Templates/error.cfm">
</cfcatch>		
</cftry>

<!--- functions --->
<cffunction name="throw">
	<cfargument name="message" required="yes" type="string">
	<cfargument name="type" required="no" type="string" default="custom">
	<cfthrow message="#arguments.message#" type="#arguments.type#">
</cffunction>


