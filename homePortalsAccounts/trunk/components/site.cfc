<cfcomponent hint="This component is used to manipulate a user site">

	<cfscript>
		variables.instance = structNew();
		variables.instance.oAccountsService = 0;
		variables.instance.owner = "";
		variables.instance.siteTitle = "";
		variables.instance.aPages = arrayNew(1);
		variables.instance.siteID = "";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="site" hint="constructor">
		<cfargument name="owner" type="string" required="true" hint="The owner of the site to load. this is the name of a homeportals account">
		<cfargument name="accounts" type="accounts" required="true" hint="This is a reference to the Accounts object">
		<cfscript>
			if(arguments.owner eq "") throw("Page owner is missing or blank","homePortals.site.pageOwnerMissing");
			
			setAccountsService( arguments.accounts );
			setOwner( arguments.owner );

			loadSite();
				
			return this;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- create				           --->
	<!---------------------------------------->	
	<cffunction name="create" access="public" returntype="site" hint="creates a new site structure for an account.">
		<cfargument name="owner" type="string" required="true" hint="The owner of the site to load. this is the name of a homeportals account">
		<cfargument name="accounts" type="accounts" required="true" hint="This is a reference to the Accounts object">

		<cfset var oPageProvider = 0>
		<cfset var accRoot = "">
		
		<cfset setAccountsService( arguments.accounts )>
		<cfset setOwner( arguments.owner )>

		<cfset oPageProvider = getPageProvider()>
		<cfset accRoot = getAccountsService().getConfig().getAccountsRoot()>

		<!--- check that the accounts directory exists, if not lets create it --->
		<cfif not oPageProvider.folderExists( accRoot )>
			<cfset oPageProvider.createFolder( "", accRoot )>
		</cfif>

		<!--- create directory for account (if doesnt exist already) ---->
		<cfif Not oPageProvider.folderExists( accRoot & "/" & getOwner() )>
			<cfset oPageProvider.createFolder( accRoot, getOwner() )>
		</cfif>
		
		<!--- create site index --->
		<cfset loadSite()>
		
		<cfreturn this>
	</cffunction>
	
	<!---------------------------------------->
	<!--- delete				           --->
	<!---------------------------------------->	
	<cffunction name="delete" access="public" returntype="void" hint="deletes the site structure for the account.">
		<cfset var oPageProvider = getPageProvider()>
		<cfset var oLinkedPagesDAO = getLinkedPagesDAO()>
		<cfset var qrySite = 0>
		<cfset var qryPages = 0>
	
		<!--- delete directory for account (if exists) ---->
		<cfif oPageProvider.folderExists( getSiteHREF() )>
			<cfset oPageProvider.deleteFolder( getSiteHREF() )>
		</cfif>
		
		<!--- check if there is a record for the site --->
		<cfset qrySite = getSitesDAO().get(variables.instance.siteID)>
		
		<!--- if not found, then delete site record --->
		<cfif qrySite.recordCount gt 0>
			<cfset qryPages = oLinkedPagesDAO.search(siteID = qrySite.siteID)>
			<cfif qryPages.recordCount gt 0>
				<cfloop query="qryPages">
					<cfset oLinkedPagesDAO.delete(qryPages.linkedPageID)>
				</cfloop>
			</cfif>
			
			<cfset getSitesDAO().delete(qrySite.siteID)>
		</cfif>		
		
		<!--- clear instance --->
		<cfset variables.instance.owner = "">
		<cfset variables.instance.siteTitle = "">
		<cfset variables.instance.siteID = "">
		<cfset variables.instance.aPages = arrayNew(1)>
	</cffunction>


	<!---------------------------------------->
	<!--- renamePage			           --->
	<!---------------------------------------->	
	<cffunction name="renamePage" access="public" output="false" returntype="void" hint="Renames a page">
		<cfargument name="oldPageName" type="string" required="true" hint="The current name of the page">
		<cfargument name="newPageName" type="string" required="true" hint="The new name of the page.">
		<cfscript>
			var i = 1;
			var tmpTitle = "";
			var xmlPageDoc = 0;
			var bFoundOnSite = false;
			var href =  "";
			var pageIndex = 0;
			
			if(isLinkedPage(arguments.pageName)) 
				throw("A linked page cannot be modified from within a site", "homePortals.site.notAllowed");
				
			// get the location of the page (this will also check for existence)
			href = getPageHREF(arguments.oldPageName);

			// get index of page in pages array
			pageIndex = getPageIndex(arguments.oldPageName);
			
			// construct new file name
			newHref = replaceNoCase(href, arguments.oldPageName, arguments.newPageName);
			
			// rename file
			getPageProvider().move(href, newHref);
			
			// update site info
			variables.instance.aPages[pageIndex].href = getFileFromPath(newHref);
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- updatePageTitle	 		       --->
	<!---------------------------------------->	
	<cffunction name="updatePageTitle" access="public" output="false" returntype="void" hint="Updates the title of a page">
		<cfargument name="pageName" type="string" required="true" hint="The name of the page">
		<cfargument name="pageTitle" type="string" required="false" default="" hint="The title of the page. This title is only used for the Site object and may be different than the actual page title">
		<cfscript>
			var i = 1;
			var tmpTitle = "";
			var xmlPageDoc = 0;
			var pageIndex = false;

			// find page in site
			pageIndex = getPageIndex(arguments.pageName);
			if(pageIndex eq 0) throw("Page not found in site.","homePortals.site.pageNotFound");
			
			// if not page title is given then get the actual title from the page
			// this allows to have a different title on the site than on the page
			if(arguments.pageTitle eq "") {
				oPage = getPage(arguments.pageName);
				tmpTitle = oPage.getTitle();
			} else 
				tmpTitle = arguments.pageTitle;
			
			// update site info
			variables.instance.aPages[pageIndex].title = tmpTitle;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- setDefaultPage	               --->
	<!---------------------------------------->	
	<cffunction name="setDefaultPage" access="public" output="false" returntype="void" hint="Sets a page as the default page for the current account">
		<cfargument name="pageName" type="string" required="true" hint="The page to set as default">
		<cfscript>
			var i = 1;
			var index = 0;
			
			// check that the page exists
			index = getPageIndex(arguments.pageName);
			
			// clear the default setting of all pages
			for(i=1;i lte arrayLen(variables.instance.aPages);i=i+1) 
				variables.instance.aPages[i]["default"] = false;
			
			// set the new default page
			variables.instance.aPages[index]["default"] = true;
			
			saveSite();
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getDefaultPage	               --->
	<!---------------------------------------->	
	<cffunction name="getDefaultPage" access="public" output="false" returntype="string" hint="Returns the name of the default page">
		<cfscript>
			var i = 1;
			var aPages = getPages();
			
			// make sure we have at least one page on the site
			if(not arrayLen(aPages)) return "";
			
			// get the page marked as the default page
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				if(aPages[i]["default"]) {
					return aPages[i].href;
				}
			}
			
			// if no page is default then return the first one on the site
			return aPages[1].href;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- deletePage		               --->
	<!---------------------------------------->	
	<cffunction name="deletePage" access="public" output="false" returntype="void">
		<cfargument name="pageName" type="string" required="true">
		<cfscript>
			var tmpPageHREF = "";
			var pageIndex = 0;
			var aPages = getPages();
			var oDAO = 0;
			var qrySite = 0;
			var qry = 0;

			// find page in site
			pageIndex = getPageIndex(arguments.pageName);
			
			if(pageIndex gt 0) {
				
				// get location of page
				tmpPageHREF = getPageHREF(aPages[pageIndex].href,false);

				// delete page		
				if(not isLinkedPage(arguments.pageName)) {
					getPageProvider().delete(tmpPageHREF);		
				} else {
					qrySite = getSitesDAO().get(variables.instance.siteID);
					if(qrySite.recordCount gt 0) {
						oDAO = getLinkedPagesDAO();
						qry = oDAO.search(siteID = qrySite.siteID,
											linkPath = aPages[pageIndex].linkPath);
						if(qry.recordCount gt 0)
							oDAO.delete(qry.linkedPageID);
					}
				}

				// delete from site
				arrayDeleteAt(variables.instance.aPages, pageIndex);
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- addPage			               --->
	<!---------------------------------------->	
	<cffunction name="addPage" access="public" output="false" returntype="string" hint="This method creates a new page and adds it to the site. The new page can be completely new or can be an existing page">
		<cfargument name="pageName" required="true" type="string" hint="the name of the new page.">
		<cfargument name="pageHREF" required="false" default="" type="string" hint="Optional. The page to copy, if pageHREF is only the document name (without path), then assumes it is a local page on the current account">
		<cfargument name="pageBean" required="false" type="homePortals.components.pageBean" hint="Optional. The pageBean object to add to the site. Mutually exclusive with the pageHREF argument">
		<cfscript>
			var oPage = 0;
			var xmlPage = 0;
			var pname = "";
			var currIndex = 0;
			var	bFound = true;
			var i = 1;
			var newPageHREF = "";
			var newNode = structNew();
			var aPages = getPages();

			// check that pagename is not empty 
			if(arguments.pageName eq "") 
				throw("Please enter a name for the new page","homePortals.site.pageNameMissing");

			// get the new page
			if(arguments.pageHREF eq "") {
				if(structKeyExists(arguments,"pageBean")) {
					oPage = arguments.pageBean;
				} else {
					// get a new page for this account
					oPage = getAccountsService().getNewPage( getOwner() );
				}

			} else {
				// we have a pageHREF, so we are copying an existing page 
				if(left(arguments.pageHREF,1) neq "/")
					arguments.pageHREF = getPageHREF(arguments.pageHREF);

				// load page
				oPage = getPageProvider().load( arguments.pageHREF );
			}
			
		
			// make sure the page has a unique name within the account
			pName = arguments.pageName;
			while(bFound) {
				bFound = false;
				for(i=1;i lte arrayLen(aPages);i=i+1) {
					if(replaceNoCase(aPages[i].href,".xml","","ALL") eq pName) {
						currIndex = currIndex + 1;
						pName = arguments.pageName & currIndex;
						bFound = true;
					}
				}
			}

			// if page has no title, then use the unique pagename as a title
			if(oPage.getTitle() eq "")
				oPage.setTitle(pName);

			// set page owner
			oPage.setOwner(getOwner());
			
			// get location of new page
			newPageHREF = getPageHREF(pname, false);
			
			// save page
			getPageProvider().save(newPageHREF, oPage);

			// append new page name to site definition
			newNode = structNew();
			newNode.title = oPage.getTitle();
			newNode.href = getFileFromPath(newPageHREF);
			newNode.default = false;
			newNode.linkPath = "";
			ArrayAppend(variables.instance.aPages, newNode);
			
			return newPageHREF;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getPage			               --->
	<!---------------------------------------->	
	<cffunction name="getPage" access="public" returntype="homePortals.components.pageBean" output="false" hint="Returns a pageBean object representing a site page">
		<cfargument name="pageName" type="string" required="true" hint="The name of the page document">
		<cfscript>
			var href = getPageHREF(arguments.pageName);
			var oPage = getPageProvider().load(href);
			return oPage;	
		</cfscript>		
	</cffunction>

	<!---------------------------------------->
	<!--- savePage				           --->
	<!---------------------------------------->	
	<cffunction name="savePage" access="public" hint="Updates a site page" returntype="void">
		<cfargument name="pageName" type="string" required="true" hint="The name of the page document">
		<cfargument name="page" type="homePortals.components.pageBean" required="true" hint="The page object">
		<!--- get page location --->
		<cfset var href =  getPageHREF(arguments.pageName)>	
		<!--- check that this is not a linked page --->
		<cfif isLinkedPage(arguments.pageName)>
			<cfthrow message="A linked page cannot be modified from within a site" type="homePortals.site.notAllowed">
		</cfif>
		<!--- store page --->
		<cfset getPageProvider().save(href, arguments.page)>
		<!--- update page title in site --->
		<cfset updatePageTitle(arguments.pageName, arguments.page.getTitle())>
	</cffunction>

	<!---------------------------------------->
	<!--- isLinkedPage			           --->
	<!---------------------------------------->	
	<cffunction name="isLinkedPage" access="public" returntype="boolean" hint="Checks whether the given page is a linked (external) page">
		<cfargument name="pageName" type="string" required="true" hint="The name of the page">
		<cfset var index = getPageIndex(arguments.pageName)>
		<cfreturn ( index gt 0 and variables.instance.aPages[index].linkPath neq "" )>
	</cffunction>

	<!---------------------------------------->
	<!--- linkPage			               --->
	<!---------------------------------------->	
	<cffunction name="linkPage" access="public" output="false" returntype="string" hint="This method links an existing page to a site. The added page remains external to the site.">
		<cfargument name="pageName" required="true" type="string" hint="The name of the new page.">
		<cfargument name="pageHREF" required="true" type="string" hint="The path to the page to link to the site">
		<cfscript>
			var oPage = 0;
			var xmlPage = 0;
			var pname = "";
			var currIndex = 0;
			var	bFound = true;
			var i = 1;
			var newNode = structNew();
			var aPages = getPages();
			
			// check that pagename is not empty 
			if(arguments.pageName eq "") throw("Please enter a name for the new page","homePortals.site.pageNameMissing");
			if(arguments.pageHREF eq "") throw("Please the path of the page to link","homePortals.site.pagePathMissing");

			// check if the page is already linked to this site
			getLinkedPagesDAO().search();

			// load page
			oPage = getPageProvider().load( arguments.pageHREF );

			// make sure the page has a unique name within the account
			pName = arguments.pageName;
			while(bFound) {
				bFound = false;
				for(i=1;i lte arrayLen(aPages);i=i+1) {
					if(replaceNoCase(aPages[i].href,".xml","","ALL") eq pName) {
						currIndex = currIndex + 1;
						pName = arguments.pageName & currIndex;
						bFound = true;
					}
				}
			}		
			
			// save linked page
			getLinkedPagesDAO().save(siteID = variables.instance.siteID,
									 name = pName,
									 linkPath = arguments.pageHREF);
			
			// append new page name to site definition
			newNode = structNew();
			newNode.title = oPage.getTitle();
			newNode.href = pName;
			newNode.default = false;
			newNode.linkPath = arguments.pageHREF;
			ArrayAppend(variables.instance.aPages, newNode);
			
			return arguments.pageHREF;
		</cfscript>
	</cffunction>

	
	<!---------------------------------------->
	<!--- G E T T E R S  /  S E T T E R S  --->
	<!---------------------------------------->
	<cffunction name="getAccountsService" access="public" returntype="accounts">
		<cfreturn variables.instance.oAccountsService>
	</cffunction>

	<cffunction name="setAccountsService" access="public" returntype="void">
		<cfargument name="data" type="accounts" required="true">
		<cfset variables.instance.oAccountsService = arguments.data>
	</cffunction>

	<cffunction name="getOwner" access="public" returntype="string">
		<cfreturn variables.instance.Owner>
	</cffunction>

	<cffunction name="setOwner" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.Owner = arguments.data>
	</cffunction>

	<cffunction name="getSiteTitle" access="public" returntype="string">
		<cfreturn variables.instance.siteTitle>
	</cffunction>
	
	<cffunction name="setSiteTitle" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.siteTitle = arguments.data>
		<cfset saveSite()>
	</cffunction>
	
	<cffunction name="getPages" access="public" returntype="array">
		<cfreturn variables.instance.aPages>
	</cffunction>	
	
	<cffunction name="getSiteHREF" access="public" returntype="string" hint="Returns the path to the account site">
		<cfreturn getAccountsService().getConfig().getAccountsRoot() 
					& "/" 
					& getOwner()>
	</cffunction>

	<cffunction name="getPageHREF" access="public" returntype="string" hint="Returns the path to a page document contained in the current site">
		<cfargument name="pageName" type="string" required="true" hint="The name of the page">
		<cfargument name="checkIfExists" type="boolean" required="false" default="true" hint="Flag to indicate whether to check that the file exists on the site">
		<cfscript>
			var pageIndex = 0;
			var href = "";
			
			// build file location
			if(isLinkedPage(arguments.pageName)) {
				pageIndex = getPageIndex(arguments.pageName);
				href = variables.instance.aPages[ pageIndex ].linkPath;
			} else 
				href = getSiteHREF() & "/" & arguments.pageName;
	
			if(arguments.checkIfExists) {
				// check if page exists on site
				pageIndex = getPageIndex(arguments.pageName);
				if(pageIndex eq 0) throw("Page not found in site [#arguments.pageName#].","homePortals.site.pageNotFound");

				// check if page exists on file system
				if(not getPageProvider().pageExists(href))
					throw("Page not found in storage [#href#].","homePortals.site.pageNotFound");
			}

			// create page location
			return href;	
		</cfscript>		
	</cffunction>

	
	<!---------------------------------------->
	<!--- P R I V A T E     M E T H O D S  --->
	<!---------------------------------------->

	<cffunction name="getPageProvider" access="private" returntype="homePortals.components.pageProvider" hint="Retrieves an instance of the pageProvider object responsible for page persistance">
		<cfreturn getAccountsService().getHomePortals().getPageProvider()>
	</cffunction>
	
	<cffunction name="getPageIndex" access="private" returntype="numeric" hint="Returns the index of the requested page in the local pages array. Returns 0 if page is not found">
		<cfargument name="pageName" type="string" required="true">
		<cfscript>
			var i = 1;
			
			for(i=1;i lte arrayLen(variables.instance.aPages);i=i+1) {
				if(variables.instance.aPages[i].href eq arguments.pageName) {
					return i;
				}
			}
			return 0;
		</cfscript>
	</cffunction>	
	
	<cffunction name="loadSite" access="private" returntype="void" hint="Populates the site information">
		<cfset var qryPages = 0>
		<cfset var qrySite = 0>
		<cfset var aPages = arrayNew(1)>
		<cfset var st = "">
		<cfset var oPage = 0>
		<cfset var oPageProvider = getPageProvider()>
		<cfset var oDAO = getSitesDAO()>
		<cfset var qryAccountInfo = getAccountsService().getAccountByName( getOwner() )>
		<cfset var defaultPage = "">

		<!--- check that there is a corresponding account --->
		<cfif qryAccountInfo.recordCount eq 0>
			<cfthrow message="Account [#getOwner()#] does not exist" type="HomePortals.site.accountNotFound">
		</cfif>

		<!--- get list of pages --->
		<cfset qryPages = oPageProvider.listFolder( getSiteHREF() )>

		<!--- check if there is a record for the site --->
		<cfset qrySite = oDAO.search(accountID = qryAccountInfo.accountID)>
		
		<!--- if not found, then create record --->
		<cfif qrySite.recordCount eq 0>

			<cfif qryPages.recordCount gt 0>
				<!--- lets take the first page as the default page --->
				<cfset defaultPage = qryPages.name[1]>
			</cfif>

			<cfset variables.instance.siteID = oDAO.save(accountID = qryAccountInfo.accountID,
														 title = getOwner(),
														 defaultPage = defaultPage,
														 createdOn = now())>
		<cfelse>
			<!--- set site info --->
			<cfset setSiteTitle( qrySite.title )>
			<cfset variables.instance.siteID = qrySite.siteID>
		</cfif>
		
		<!--- add local pages --->
		<cfloop query="qryPages">
			<cfif qryPages.type eq "page">
				<cfset oPage = oPageProvider.load( getPageHREF(qryPages.name, false) )>
	
				<cfset st = structNew()>
				<cfset st.default = (qrySite.defaultPage eq qryPages.name)>
				<cfset st.href = qryPages.name>	
				<cfset st.title = oPage.getTitle()>
				<cfset st.linkPath = "">
	
				<cfset arrayAppend(aPages, st)>
			</cfif>
		</cfloop>
		
		<!--- add linked (external) pages, if any --->
		<cfif qrySite.recordCount gt 0>
			<cfset oDAO = getLinkedPagesDAO()>
			<cfset qryPages = oDAO.search(siteID = qrySite.siteID)>
			<cfloop query="qryPages">
				<cfset oPage = oPageProvider.load( qryPages.linkPath )>
	
				<cfset st = structNew()>
				<cfset st.default = (qrySite.defaultPage eq listLast(qryPages.linkPath,"/") )>
				<cfset st.href = qryPages.name>	
				<cfset st.title = oPage.getTitle()>
				<cfset st.linkPath = qryPages.linkPath>
	
				<cfset arrayAppend(aPages, st)>
			</cfloop>
		</cfif>
		
		<cfset variables.instance.aPages = aPages>
	</cffunction>
				
	<cffunction name="saveSite" access="private" hint="Saves the site xml">
		<cfset var oDAO = getSitesDAO()>
		<cfset var qrySite = 0>
		<cfset var qryAccountInfo = getAccountsService().getAccountByName( getOwner() )>

		<!--- check if there is a record for the site --->
		<cfset qrySite = oDAO.search(accountID = qryAccountInfo.accountID)>
		
		<!--- if not found, then index site --->
		<cfif qrySite.recordCount eq 0>
			<cfset loadSite()>
		<cfelse>
			<!--- update title and default page--->
			<cfset oDAO.save(ID = qrySite.siteID,
							 title = getSiteTitle(),
							 defaultPage = getDefaultPage())>
		</cfif>
	</cffunction>

	<cffunction name="getSitesDAO" access="private" returntype="homePortalsAccounts.components.lib.DAOFactory.DAO" hint="returns the sites DAO">
		<cfreturn getAccountsService().getDAO("sites")>
	</cffunction>	
	
	<cffunction name="getLinkedPagesDAO" access="private" returntype="homePortalsAccounts.components.lib.DAOFactory.DAO" hint="returns the linked pages DAO">
		<cfreturn getAccountsService().getDAO("linkedPages")>
	</cffunction>	

	
	<!---------------------------------------->
	<!--- U T I L I T Y     M E T H O D S  --->
	<!---------------------------------------->

	<cffunction name="throw" access="private" hint="Facade for cfthrow">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" required="false" default="homePortals.site.error">
		<cfthrow  message="#arguments.message#" type="#arguments.type#">
	</cffunction>
		
</cfcomponent>