<cfcomponent hint="This component is used to manipulate a user site">

	<cfscript>
		variables.instance = structNew();
		variables.instance.oAccountsService = 0;
		variables.instance.owner = "";
		variables.instance.siteTitle = "";
		variables.instance.aPages = arrayNew(1);
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

			try {
				loadSite();
				
			} catch(homePortals.site.missingSiteXML e) {
				indexSite();
			}

			return this;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- indexSite				           --->
	<!---------------------------------------->	
	<cffunction name="indexSite" access="public" returntype="void" hint="Builds the site index by examining all pages in the current account">
		<cfset var xmlDoc = "">
		<cfset var qryPages = "">
		<cfset var st = "">
		<cfset var aPages = arrayNew(1)>
		<cfset var oPage = 0>
		
		<cfset var accountHREF = getDirectoryFromPath( getSiteHREF() )>
		<cfset var layoutsHREF = accountHREF & "/layouts">
		
		<!--- set site title --->
		<cfset setSiteTitle( getOwner() )>

		<!--- get list of pages --->
		<cfdirectory action="list" directory="#expandPath(layoutsHREF)#" name="qryPages" filter="*.xml">
		
		<cfloop query="qryPages">
			<cfset xmlDoc = xmlParse(expandPath(layoutsHREF & "/" & qryPages.name))>

			<cfset oPage = createObject("component","Home.Components.pageBean").init(xmlDoc)>

			<cfset st = structNew()>
			<cfset st.default = false>
			<cfset st.href = qryPages.name>	
			<cfset st.title = oPage.getTitle()>

			<cfset arrayAppend(aPages, st)>
		</cfloop>
		
		<cfset variables.instance.aPages = aPages>
		
		<!--- save site --->
		<cfset saveSite()>
	</cffunction>
	
	<!---------------------------------------->
	<!--- toXML					           --->
	<!---------------------------------------->	
	<cffunction name="toXML" access="public" returnType="xml" hint="Returns the site information as an XML document">
		<cfscript>
			var xmlDoc = 0;
			var xmlNode = 0;
			var tmpPage = structNew();
			var i = 0;
			var aPages = getPages();

			// create a blank xml document and add the root node
			xmlDoc = xmlNew();
			xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "site");	
			
			// add title node
			xmlNode = xmlElemNew(xmlDoc, "title");
			xmlNode.xmlText = xmlFormat(getSiteTitle());
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);	
			
			// add pages node
			xmlNode = xmlElemNew(xmlDoc, "pages");
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);	
			
			// add page nodes
			for(i=1;i lte arrayLen(aPages);i=i+1) {
			
				tmpPage = aPages[i];
			
				xmlNode = xmlElemNew(xmlDoc, "page");
				xmlNode.xmlAttributes["title"] = xmlFormat(tmpPage.title);
				xmlNode.xmlAttributes["href"] = xmlFormat(tmpPage.href);
				xmlNode.xmlAttributes["default"] = xmlFormat(tmpPage.default);
			
				arrayAppend(xmlDoc.xmlRoot.pages.xmlChildren, xmlNode);	
			
			}
			
			return xmlDoc;
		</cfscript>
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
			
			// get the location of the page (this will also check for existence)
			href = getPageHREF(arguments.oldPageName);

			// get index of page in pages array
			pageIndex = getPageIndex(arguments.oldPageName);
			
			// construct new file name
			newHref = replaceNoCase(href, arguments.oldPageName, arguments.newPageName);
			
			// rename file
			renameFile(href, newHref);
			
			// update site info
			variables.instance.aPages[pageIndex].href = getFileFromPath(newHref);
			saveSite();
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
			saveSite();
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

			// find page in site
			pageIndex = getPageIndex(arguments.pageName);
			
			if(pageIndex gt 0) {
				
				// get location of file
				tmpPageHREF = getPageHREF(aPages[pageIndex].href,false);

				// delete file				
				if(fileExists(expandpath(tmpPageHREF))) 
					deleteFile(expandpath(tmpPageHREF));

				// delete from site
				arrayDeleteAt(variables.instance.aPages, pageIndex);
				
				// save site
				saveSite();
			}
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- addPage			               --->
	<!---------------------------------------->	
	<cffunction name="addPage" access="public" output="false" returntype="string" hint="This method creates a new page and adds it to the site. The new page can be completely new or can be an existing page">
		<cfargument name="pageName" required="true" type="string" hint="the name of the new page. If no extension is given, then .xml will be appended.">
		<cfargument name="pageHREF" required="false" default="" type="string" hint="Optional. The page to copy, if pageHREF is only the document name (without path), then assumes it is a local page on the current account">
		<cfscript>
			var originalName = "";
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

			// remove extension from page name
			originalName = replaceNoCase(arguments.pageName,".xml","","ALL");		


			// get the new page
			if(arguments.pageHREF eq "") {
				// get a new page for this account
				oPage = getAccountsService().getNewPage( getOwner() );

			} else {
				// we have a pageHREF, so we are copying an existing page 
				if(left(arguments.pageHREF,1) neq "/")
					arguments.pageHREF = getPageHREF(arguments.pageHREF);

				// load page
				xmlPage = xmlParse(expandPath(arguments.pageHREF));
				oPage = createObject("component","Home.Components.pageBean").init(xmlPage);
			}
			
		
			// make sure the page has a unique name within the account
			pName = originalName;
			while(bFound) {
				bFound = false;
				for(i=1;i lte arrayLen(aPages);i=i+1) {
					if(replaceNoCase(aPages[i].href,".xml","","ALL") eq pName) {
						currIndex = currIndex + 1;
						pName = originalName & currIndex;
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
			writeFile(expandPath(newPageHREF), toString(xmlPage));

			// append new page name to site definition
			newNode = structNew();
			newNode.title = oPage.getTitle();
			newNode.href = getFileFromPath(newPageHREF);
			newNode.default = false;
			ArrayAppend(variables.instance.aPages, newNode);
			
			// save changes to site
			saveSite();
			
			return newPageHREF;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getPage			               --->
	<!---------------------------------------->	
	<cffunction name="getPage" access="public" returntype="Home.Components.pageBean" output="false" hint="Returns a pageBean object representing a site page">
		<cfargument name="pageName" type="string" required="true" hint="The name of the page document">
		<cfscript>
			var href = "";
			var xmlDoc = 0;
			var oPage = 0;
	
			// find and load page 
			href = getPageHREF(arguments.pageName);
			xmlDoc = xmlParse(expandPath(href));
			
			// create page object
			oPage = createObject("component","Home.Components.pageBean").init(xmlDoc);
			
			return oPage;	
		</cfscript>		
	</cffunction>

	<!---------------------------------------->
	<!--- savePage				           --->
	<!---------------------------------------->	
	<cffunction name="savePage" access="public" hint="Updates a site page" returntype="void">
		<cfargument name="pageName" type="string" required="true" hint="The name of the page document">
		<cfargument name="page" type="Home.Components.pageBean" required="true" hint="The page object">
		<!--- get page in xml format --->
		<cfset var xmlDoc = arguments.page.toXML()>
		<!--- get page location --->
		<cfset var href =  getPageHREF(arguments.pageName)>	
		<!--- store page --->
		<cfset writeFile(expandpath(href), toString(xmlDoc))>
		<!--- update page title in site --->
		<cfset updatePageTitle(href, arguments.page.getTitle())>
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
	</cffunction>
	
	<cffunction name="getPages" access="public" returntype="array">
		<cfreturn variables.instance.aPages>
	</cffunction>	
	
	
	<!---------------------------------------->
	<!--- P R I V A T E     M E T H O D S  --->
	<!---------------------------------------->

	<cffunction name="getSiteHREF" access="public" returntype="string" hint="Returns the path to the file where the site information is stored">
		<cfreturn getAccountsService().getConfig().getAccountsRoot() & "/" & getOwner() & "/site.xml">
	</cffunction>
	
	<cffunction name="getPageIndex" access="private" returntype="numeric" hint="Returns the index of the requested page in the local pages array. Returns 0 if page is not found">
		<cfargument name="pageName" type="string" required="true">
		<cfscript>
			var i = 1;
			
			// make sure the pagename contains the .xml extension
			if(right(arguments.pageName,4) neq ".xml")
				arguments.pageName = arguments.pageName & ".xml";
			
			for(i=1;i lte arrayLen(variables.instance.aPages);i=i+1) {
				if(variables.instance.aPages[i].href eq arguments.pageName) {
					return i;
				}
			}
			return 0;
		</cfscript>
	</cffunction>	

	<cffunction name="getPageHREF" access="public" returntype="string" hint="Returns the path to a page document contained in the current site">
		<cfargument name="pageName" type="string" required="true" hint="The page name, with or without the .xml extension">
		<cfargument name="checkIfExists" type="boolean" required="false" default="true" hint="Flag to indicate whether to check that the file exists on the site">
		<cfscript>
			var pageIndex = 0;
			var layoutsHREF = getDirectoryFromPath(getSiteHREF()) & "/layouts";
			var href = "";
			
			// make sure the pagename contains the .xml extension
			if(right(arguments.pageName,4) neq ".xml")
				arguments.pageName = arguments.pageName & ".xml";
	
			// build file location
			href = layoutsHREF & "/" & arguments.pageName;
	
			if(arguments.checkIfExists) {
				// check if page exists on site
				pageIndex = getPageIndex(arguments.pageName);
				if(pageIndex eq 0) throw("Page not found in site.","homePortals.site.pageNotFound");

				// check if page exists on file system
				if(not fileExists(expandPath(href))) 
					throw("Page not found in file system.","homePortals.site.pageNotFound");
			}

			// create page location
			return href;	
		</cfscript>		
	</cffunction>
	
	<cffunction name="loadSite" access="private" returntype="void" hint="Reads the site information from a file">
		<cfscript>
			var xmlDoc = 0;
			var st = structNew(); 
			var xmlNode = 0;
			var i = 0;
			var siteDocPath = expandPath(getSiteHREF());
				
			// read configuration file
			if(Not fileExists(siteDocPath))
				throw("Site descriptor file not found [#siteDocPath#]","homePortals.site.missingSiteXML");
			else
				xmlDoc = xmlParse(siteDocPath);

			// set initial values
			setSiteTitle("");
			variables.instance.aPages = arrayNew(1);

			// get site title
			if(structKeyExists(xmlDoc.site,"title")) 
				setSiteTitle(xmlDoc.xmlRoot.title.xmlText);
			
			// read pages
			if(structKeyExists(xmlDoc.xmlRoot,"pages")) {
			
				for(i=1;i lte arrayLen(xmlDoc.xmlRoot.pages.xmlChildren); i=i+1) {
				
					xmlNode = xmlDoc.xmlRoot.pages.xmlChildren[i]; 
					
					// build default page struct
					st = structNew();
					st.default = false;
					st.href = "";
					st.title = "";
									
					if(structKeyExists(xmlNode.xmlAttributes, "default") and isBoolean(xmlNode.xmlAttributes.default)) st.default = xmlNode.xmlAttributes.default;
					if(structKeyExists(xmlNode.xmlAttributes, "href")) st.href = xmlNode.xmlAttributes.href;
					if(structKeyExists(xmlNode.xmlAttributes, "title")) st.title = xmlNode.xmlAttributes.title;
					
					// append to pages array
					arrayAppend(variables.instance.aPages, st);
					
				}
			}
		</cfscript>
	</cffunction>
				
	<cffunction name="saveSite" access="private" hint="Saves the site xml">
		<cfset var xmlDoc = toXML()>
		<cfset var siteHREF = getSiteHREF()>
		<cffile action="write" file="#expandpath(siteHREF)#" output="#toString(xmlDoc)#">
	</cffunction>


	<!---------------------------------------->
	<!--- U T I L I T Y     M E T H O D S  --->
	<!---------------------------------------->

	<cffunction name="throw" access="private" hint="Facade for cfthrow">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" required="false" default="homePortals.site.error">
		<cfthrow  message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
	<cffunction name="writeFile" access="private" hint="Facade for cffile write">
		<cfargument name="path" type="string" required="true">
		<cfargument name="content" type="string" required="true">
		<cffile action="write" file="#arguments.path#" 	output="#arguments.content#">
	</cffunction>

	<cffunction name="deleteFile" access="private" hint="Facade for cffile delete">
		<cfargument name="path" type="string" required="true">
		<cffile action="delete" file="#arguments.path#">
	</cffunction>
	
	<cffunction name="renameFile" access="private" hint="Facade for cffile rename">
		<cfargument name="source" type="string" required="true">
		<cfargument name="destination" type="string" required="true">
		<cffile action="rename" source="#arguments.source#" destination="#arguments.destination#">
	</cffunction>

	
</cfcomponent>