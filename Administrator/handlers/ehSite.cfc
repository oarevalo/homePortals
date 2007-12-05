<cfcomponent name="ehSite" extends="ehBase">
	
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
	<!--- dspSiteManager                           ---->
	<!------------------------------------------------->
	<cffunction name="dspSiteManager" access="public" returntype="void">
		<cfscript>
			var oAccounts = 0;
			var	qryAccount = 0;
			var accountDir = "";
			var qryFiles = 0;
			var accountSize = 0;
			var oSite = 0;
			var userID = 0;
			
			try {

				// check if we have a site cfc loaded 
				if(Not structKeyExists(session,"currentSite")) {
					throw("Please select an account first.");
				}
				
				// get site from session
				oSite = session.currentSite;

				// get user
				userID = oSite.getUserID();

				// get accounts info 
				oAccounts = oSite.getAccount();
				stAccountInfo = oAccounts.getConfig();

				// search account
				qryAccount = oAccounts.getAccountByUserID(userID);

				// get account dir info
				accountDir = stAccountInfo.accountsRoot & "/" & qryAccount.username;
				qryFiles = dir(accountDir, true);
				accountSize = arraySum(listToArray(valueList(qryFiles.size)));
				
				setValue("stAccountInfo", stAccountInfo);
				setValue("qryAccount", qryAccount);
				setValue("siteTitle", oSite.getSiteTitle());
				setValue("accountDir", accountDir);
				setValue("accountSize", accountSize);
				setValue("aPages", oSite.getPages() );
				setValue("userID", userID );
				
				session.mainMenuOption = "Accounts";
				setView("SiteManager/vwSiteManager");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehAccounts.dspMain");
			}
		</cfscript>
	</cffunction>

	<!------------------------------------------------->
	<!--- dspAddPage                               ---->
	<!------------------------------------------------->
	<cffunction name="dspAddPage" access="public" returntype="void">
		<cfscript>
			var oSite = 0;
			var oAccounts = 0;
			var userID = 0;
			var qryAccount = 0;
			var aCatalogPages = 0;
			var aPages = 0;

			try {
				// check if we have a site cfc loaded 
				if(Not structKeyExists(session,"currentSite")) throw("Please select an account first.");
				
				// get site from session
				oSite = session.currentSite;

				// get info from site
				userID = oSite.getUserID();
				aPages = oSite.getPages();

				// get accounts info 
				oAccounts = oSite.getAccount();
				qryAccount = oAccounts.getAccountByUserID(userID);

				// get catalog
				oCatalog = createInstance("../Components/catalog.cfc");
				oCatalog.init(getSetting("HomeRoot"));
				aCatalogPages = oCatalog.getPages();
				
				setValue("qryAccount", qryAccount);
				setValue("aPages", aPages);
				setValue("aCatalogPages", aCatalogPages);

				session.mainMenuOption = "Accounts";
				setView("SiteManager/vwAddPage");		

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSite.dspSiteManager");
			}
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSetSiteTitle                           ---->
	<!------------------------------------------------->
	<cffunction name="doSetSiteTitle" access="public" returntype="void">
		<cfscript>
			var title = getValue("title","");
			var oSite = 0;
			
			try {
				oSite = session.currentSite;
				oSite.setSiteTitle(title);
				getPlugin("messagebox").setMessage("info", "Site title changed.");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
			setNextEvent("ehSite.dspSiteManager");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSetPageNavStatus                       ---->
	<!------------------------------------------------->
	<cffunction name="doSetPageNavStatus" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var status = getValue("status",true);
			var oSite = 0;
			
			try {
				oSite = session.currentSite;
				oSite.setPageNavStatus(href,status);
				getPlugin("messagebox").setMessage("info", "Page sitemap status changed");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
			setNextEvent("ehSite.dspSiteManager");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSetDefaultPage         	               ---->
	<!------------------------------------------------->
	<cffunction name="doSetDefaultPage" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var oSite = 0;
			try {
				oSite = session.currentSite;
				oSite.setDefaultPage(href);
				getPlugin("messagebox").setMessage("info", "Default page set.");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
			setNextEvent("ehSite.dspSiteManager");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doMovePageUp         			           ---->
	<!------------------------------------------------->
	<cffunction name="doMovePageUp" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var oSite = 0;
			try {
				oSite = session.currentSite;
				oSite.movePageUp(href);
				getPlugin("messagebox").setMessage("info", "Default page set.");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
			setNextEvent("ehSite.dspSiteManager");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doMovePageDown	                       ---->
	<!------------------------------------------------->
	<cffunction name="doMovePageDown" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var oSite = 0;
			try {
				oSite = session.currentSite;
				oSite.movePageDown(href);
				getPlugin("messagebox").setMessage("info", "Default page set.");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
			setNextEvent("ehSite.dspSiteManager");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSetPagePrivacyStatus                   ---->
	<!------------------------------------------------->
	<cffunction name="doSetPagePrivacyStatus" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var status = getValue("status",true);
			var oSite = 0;
			
			try {
				oSite = session.currentSite;
				oSite.setPagePrivacyStatus(href,status);
				getPlugin("messagebox").setMessage("info", "Page privacy status changed");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
			setNextEvent("ehSite.dspSiteManager");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doDeletePage                       	   ---->
	<!------------------------------------------------->
	<cffunction name="doDeletePage" access="public" returntype="void">
		<cfscript>
			var href = getValue("href","");
			var oSite = 0;
			var userID = "";
			
			try {
				oSite = session.currentSite;
				oSite.deletePage(href);
				userID = oSite.getUserID();
				getPlugin("messagebox").setMessage("info", "Page deleted");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
			}			
			setNextEvent("ehAccounts.doSetAccount","userID=#userID#");
		</cfscript>
	</cffunction>


	<!------------------------------------------------->
	<!--- doAddPage         	     	           ---->
	<!------------------------------------------------->
	<cffunction name="doAddPage" access="public" returntype="void">
		<cfscript>
			var pageName = getValue("pageName","");
			var oSite = 0;
			var userID = "";
			
			try {
				oSite = session.currentSite;
				oSite.addPage(pageName);
				userID = oSite.getUserID();
				getPlugin("messagebox").setMessage("info", "New page created.");
				setNextEvent("ehAccounts.doSetAccount","userID=#userID#");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSite.dspAddPage");
			}			
		</cfscript>
	</cffunction>	
	
	
	<!------------------------------------------------->
	<!--- doCopyPage            	               ---->
	<!------------------------------------------------->
	<cffunction name="doCopyPage" access="public" returntype="void">
		<cfscript>
			var pageHREF = getValue("pageHREF","");
			var oSite = 0;
			var userID = "";
			
			try {
				oSite = session.currentSite;
				oSite.addPage("",pageHREF);
				userID = oSite.getUserID();
				getPlugin("messagebox").setMessage("info", "Page copied.");
				setNextEvent("ehAccounts.doSetAccount","userID=#userID#");

			} catch(any e) {
				getPlugin("messagebox").setMessage("error", e.message & "<br/>" & e.detail);
				setNextEvent("ehSite.dspAddPage");
			}			
		</cfscript>
	</cffunction>		
	

	<!------------------------------------------------->
	<!--- P R I V A T E   M E T H O D S            ---->
	<!------------------------------------------------->
	<cffunction name="dir" access="private" returnttye="query">
		<cfargument name="path" type="string" required="true">
		<cfargument name="recurse" type="boolean" required="false" default="false">
		<cfset var qry = QueryNew("")>

		<cfdirectory action="list" name="qry" directory="#ExpandPath(arguments.path)#" recurse="#arguments.recurse#">
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				ORDER BY Type, Name
		</cfquery>		
		<cfreturn qry>	
	</cffunction>

</cfcomponent>