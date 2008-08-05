<cfcomponent hint="This component is used to manipulate a user site">

	<cfscript>
		variables.accounts = 0;
		variables.siteURL = "";
		variables.xmlDoc = 0;
		variables.owner = 0;
		variables.accountID = 0;
		
		variables.aPages = arrayNew(1);
		variables.siteTitle = "";
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="site">
		<cfargument name="owner" type="string" required="true" hint="The owner of the site to load. this is the username of a homeportals account">
		<cfargument name="accounts" type="accounts" required="true" hint="This is a reference to the Accounts object">
		<cfscript>
			// set properties
			setAccountsService( arguments.accounts );
			setOwner( arguments.owner );

			// get the accountID for this account (will speedup future lookups)
			qry = getAccountsService().getAccountByName(getOwner());
			variables.accountID = qry.accountID;

			// load pages			
			load();
			
			return this;
		</cfscript>
	</cffunction>
	
	<cffunction name="indexPages" access="public" returntype="void" hint="Builds the site index by examining all pages in the current account">
		<cfset var xmlDoc = "">
		<cfset var qryPages = "">
		<cfset var st = "">
		
		<cfset var accountHREF = getDirectoryFromPath(variables.siteURL)>
		<cfset var layoutsHREF = accountHREF & "/layouts">
		
		<!--- set site title --->
		<cfset variables.siteTitle = variables.owner>

		<!--- initialize pages array --->
		<cfset variables.aPages = arrayNew(1)>
		
		<!--- get list of pages --->
		<cfdirectory action="list" directory="#expandPath(layoutsHREF)#" name="qryPages" filter="*.xml">
		
		<cfloop query="qryPages">
			<cfset xmlDoc = xmlParse(expandPath(layoutsHREF & "/" & qryPages.name))>

			<cfset st = structNew()>
			<cfset st.default = false>
			<cfset st.href = qryPages.name>	

			<cfif structKeyExists(xmlDoc.xmlRoot,"title")>
				<cfset st.title = xmlDoc.xmlRoot.title.xmlText>
			<cfelse>
				<cfset st.title = replaceNoCase(qryPages.name,".xml","")>
			</cfif>
			
			<cfset arrayAppend(variables.aPages, st)>
		</cfloop>
		
		<!--- save site --->
		<cfset save()>
	</cffunction>
	
	
	

	<!---------------------------------------->
	<!--- setSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setSiteTitle" access="public" output="false" returntype="void">
		<cfargument name="title" type="string" required="true" hint="The new title for the site">
		<cfset var oDAO = getAccountsService().getDAO("Accounts")>
		<cfset oDAO.save(accountID = variables.accountID,
							siteTitle = arguments.title)
	</cffunction>


	<!---------------------------------------->
	<!--- getSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="getSiteTitle" access="public" returntype="string">
		<cfreturn getAccountsService().getAccountByID(variables.accountID).siteTitle>
	</cffunction>


	<!---------------------------------------->
	<!--- getPages				           --->
	<!---------------------------------------->	
	<cffunction name="getPages" access="public" returntype="array">
		<cfset var oDAO = getAccountsService().getDAO("Accounts")>
		<cfreturn variables.aPages>
	</cffunction>


	<!---------------------------------------->
	<!--- setPageHREF			           --->
	<!---------------------------------------->	
	<cffunction name="setPageHREF" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true" hint="The location of the page">
		<cfargument name="newPageHREF" type="string" required="true" hint="The new location of the page.">
		<cfscript>
			var i = 1;
			var tmpTitle = "";
			var xmlPageDoc = 0;
			var bFoundOnSite = false;
			
			// check that the new page exists
			if(fileExists(expandPath(arguments.newPageHREF))) {
				xmlPageDoc = xmlParse(expandPath(arguments.newPageHREF));
				if(structKeyExists(xmlPageDoc.xmlRoot,"title"))
					tmpTitle = xmlPageDoc.xmlRoot.title.xmlText;
				else
					tmpTitle = replaceNoCase(getFileFromPath(arguments.newPageHREF),".xml","");
			} else {
				throw("The new page does not exist!");
			}
			
			// rename the page
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				if(variables.aPages[i].href eq getFileFromPath(arguments.pageHREF)) {
					variables.aPages[i].href = getFileFromPath(arguments.newPageHREF);
					variables.aPages[i].title = tmpTitle;
					bFoundOnSite = true;
					break;
				}
			}
			if(Not bFoundOnSite) throw("The page [#arguments.pageHREF#] does not exist on this site.");
			save();
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- setPageTitle		 		       --->
	<!---------------------------------------->	
	<cffunction name="setPageTitle" access="public" output="false" returntype="void" hint="Updates the title of a page">
		<cfargument name="pageHREF" type="string" required="true" hint="The location of the page">
		<cfargument name="pageTitle" type="string" required="false" default="" hint="The title of the page. This title is only used for the Site object and may be different than the actual page title">
		<cfscript>
			var i = 1;
			var tmpTitle = "";
			var xmlPageDoc = 0;
			var bFoundOnSite = false;
			
			// if not page title is given then get the actual title from the page
			// this allows to have a different title on the site than on the page
			if(arguments.pageTitle eq "") {
				if(fileExists(expandPath(arguments.pageHREF))) {
					xmlPageDoc = xmlParse(expandPath(arguments.pageHREF));
					if(structKeyExists(xmlPageDoc.xmlRoot,"title"))
						tmpTitle = xmlPageDoc.xmlRoot.title.xmlText;
					else
						tmpTitle = replaceNoCase(getFileFromPath(arguments.pageHREF),".xml","");
				} else {
					throw("The page [#arguments.pageHREF#] was not found");
				}
			} else {
				tmpTitle = arguments.pageTitle;
			}
			
			// rename the page
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				if(variables.aPages[i].href eq getFileFromPath(arguments.pageHREF)) {
					variables.aPages[i].title = tmpTitle;
					bFoundOnSite = true;
					break;
				}
			}
			if(Not bFoundOnSite) throw("The page [#arguments.pageHREF#] does not exist on this site.");
			save();
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- setDefaultPage	               --->
	<!---------------------------------------->	
	<cffunction name="setDefaultPage" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to set as default">
		<cfscript>
			var i = 1;
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				variables.aPages[i]["default"] = (variables.aPages[i].href eq arguments.pageHREF);
			}
			save();
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- getDefaultPage	               --->
	<!---------------------------------------->	
	<cffunction name="getDefaultPage" access="public" output="false" returntype="string" hint="Returns the name of the default page">
		<cfscript>
			var i = 1;
			
			// make sure we have at least one page on the site
			if(not arrayLen(variables.aPages)) return;
			
			// get the page marked as the default page
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				if(variables.aPages[i]["default"]) {
					return variables.aPages[i].href;
				}
			}
			
			// if no page is default then return the first one on the site
			return variables.aPages[1].href;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- deletePage		               --->
	<!---------------------------------------->	
	<cffunction name="deletePage" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true">

		<cfscript>
			var tmpPageURL = "";
			var oAccountsConfigBean = variables.accounts.getConfig();
			var accountsRoot = oAccountsConfigBean.getAccountsRoot();

			// check that user has at least one other page
			if(ArrayLen(variables.aPages) eq 1)
				throw("You cannot delete all pages in a site. A site must have at least one page.");
				
			// get page url
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				if(variables.aPages[i].href eq arguments.pageHREF) {
					tmpPageURL = accountsRoot & "/" & variables.owner & "/layouts/" & arguments.pageHREF;
					break;
				}
			}
		</cfscript>

		<cfif tmpPageURL neq "">
			<!--- delete page --->
			<cfif fileExists(expandpath(tmpPageURL))>
				<cffile action="delete" file="#expandpath(tmpPageURL)#"> 
			</cfif>
	
			<cfscript>
				// delete from site
				for(i=1;i lte ArrayLen(variables.aPages);i=i+1) {
					if(variables.aPages[i].href eq arguments.pageHREF) {
						ArrayDeleteAt(variables.aPages,i);
					}
				}
				
				// save site
				save();
			</cfscript>
		</cfif>
	</cffunction>

	<!---------------------------------------->
	<!--- addPage			               --->
	<!---------------------------------------->	
	<cffunction name="addPage" access="public" output="false" returntype="string">
		<cfargument name="pageName" required="true" type="string" hint="the name of the new page. If no extension is given, then .xml will be appended. The name is ignored if a pageHREF is given">
		<cfargument name="pageHREF" required="false" default="" type="string" hint="Optional. The page to copy, if pageHREF is only the document name (without path), then assumes it is a local page on the current account">

		<cfscript>
			var tmpHTML = "add";
			var pname = Arguments.pageName;
			var newPageURL = "";
			var tmpPageURL = "";
			var stUser = structNew();
			var oAccountsConfigBean = 0;
			var xmlSite = 0;
			var	bFound = false;
			var txtDoc = "";
			var i = 1;
			var originalName = "";
			var currIndex = 0;
			var thisPageHREF = "";
			var accountsRoot = "";
			

			// get account info
			oAccountsConfigBean = variables.accounts.getConfig();
			accountsRoot = oAccountsConfigBean.getAccountsRoot();
			
			// get site definition as xml object
			xmlSite = variables.xmlDoc;

			if(arguments.pageHREF eq "") {
				// no pageHREF is given, so we add a blank page 
				if(arguments.pageName eq "") throw("Please enter a name for the new page.");
				
				// check that a template for new pages has been defined, if empty, users cannot add pages
				if(oAccountsConfigBean.getNewPageTemplate() eq "")
					throw("A template for new user pages has not been defined.");

				// get new page and process tokens
				txtDoc = variables.accounts.processTemplate(variables.owner, oAccountsConfigBean.getNewPageTemplate());

				// convert into xml document
				xmlPage = xmlParse(txtDoc);

			} else {
				// we have a pageHREF, so we are copying an existing page 
				if(left(arguments.pageHREF,1) neq "/")
					tmpPageURL = accountsRoot & "/" & variables.owner & "/layouts/" & arguments.pageHREF;
				else
					tmpPageURL = arguments.pageHREF;

				// check that page exists				
				if(Not FileExists(ExpandPath(tmpPageURL)))
					throw("The page you wish to duplicate does not exist. Please select an existing page.");

				// make sure we are copying a page from the current user
				/*
					for(i=1;i lte arrayLen(xmlSite.xmlRoot.pages.xmlChildren);i=i+1) {
						if(xmlSite.xmlRoot.pages.xmlChildren[i].xmlAttributes.href eq arguments.pageHREF) {
							bFound = true;
							break;
						}
					}
					if(Not bFound) throw("You are trying to copy a page that does not belong to you.");
				*/
				
				// set a default name for the new page
				if(pname eq "") {
					pName = replaceNoCase(getFileFromPath(arguments.pageHREF),".xml","");
					pName = "Copy of " & pName;
				}

				// get the page to copy
				xmlPage = xmlParse(expandpath(tmpPageURL));
			}
			
		
			// check if a page of the same name is already on the site
			originalName = pName;
			bFound = true;
			while(bFound) {
				bFound = false;
				for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
					thisPageHREF = variables.aPages[i].href; 
					if(replaceNoCase(thisPageHREF,".xml","") eq pName) {
						currIndex = currIndex + 1;
						pName = originalName & currIndex;
						bFound = true;
					}
				}
			}

			// set page title
			xmlPage.page.title.xmlText = pname;

			// set page owner
			xmlPage.xmlRoot.xmlAttributes["owner"] = variables.owner;
			
						
			// format the new page's name			
			if(Right(pname,4) neq ".xml") pname = pname & ".xml";
			
			// define location of new page
			newPageURL = accountsRoot & "/" & variables.owner & "/layouts/" & pname;
			
			// save page
			saveXML(newPageURL, xmlPage);

			// append new page name to site definition
			newNode = structNew();
			newNode.title = Replace(pname,".xml","");
			newNode.href = pname;
			newNode.default = false;
			ArrayAppend(variables.aPages, newNode);
			
			// save changes to site
			save();
		</cfscript>
		<cfreturn newPageURL>
	</cffunction>

	<!---------------------------------------->
	<!--- addPageResource	               --->
	<!---------------------------------------->	
	<cffunction name="addPageResource" access="public" output="false" returntype="string">
		<cfargument name="pageResourceBean" required="true" type="resourceBean" hint="resource bean">
		<cfargument name="resourceRoot" default="/Home/resourceLibrary/" type="string" required="true">
		<cfset var href = arguments.resourceRoot & "/" & arguments.pageResourceBean.getHREF()>	
		<cfset var newHREF = addPage(arguments.pageResourceBean.getName(), href)>
		<cfreturn newHREF>
	</cffunction>

	<!---------------------------------------->
	<!--- getPage			               --->
	<!---------------------------------------->	
	<cffunction name="getPage" access="public" returntype="pageBean" output="false" hint="Returns a pageBean object representing a site page">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to get">
		<cfscript>
			var pageIndex = 0;
			var layoutsHREF = getDirectoryFromPath(variables.siteURL) & "/layouts";
			var oPage = 0;
	
			// find page info
			pageIndex = getPageIndex(arguments.pageHREF);
			if(pageIndex eq 0) throw("Page not found in site.");

			// create page object
			oPage = createObject("component","pageBean").init(layoutsHREF & "/" & arguments.pageHREF);
			
			return oPage;	
		</cfscript>		
	</cffunction>

	<!---------------------------------------->
	<!--- savePage				           --->
	<!---------------------------------------->	
	<cffunction name="savePage" access="public" hint="Updates a site page" returntype="void">
		<cfargument name="page" type="pageBean" required="true">
		<!--- get page in xml format --->
		<cfset var xmlDoc = arguments.page.toXML()>
		<!--- get page location --->
		<cfset var href = arguments.page.getHREF()>	
		<!--- check that page exists in site --->
		<cfset var pageIndex = getPageIndex( getFileFromPath(href) )>
		<cfif pageIndex eq 0>
			<cfset throw("Page not found in site")>
		</cfif>
		<!--- store page --->
		<cffile action="write" file="#expandpath(href)#" output="#toString(xmlDoc)#">
		<!--- update page title in site --->
		<cfset setPageTitle(href, arguments.page.getTitle())>
	</cffunction>
	
	
	
	<!---------------------------------------->
	<!--- G E T T E R S  /  S E T T E R S  --->
	<!---------------------------------------->
	<cffunction name="getAccountsService" access="public" returntype="accounts">
		<cfreturn variables.accounts>
	</cffunction>

	<cffunction name="setAccountsService" access="public" returntype="void">
		<cfargument name="data" type="accounts" required="true">
		<cfset variables.accounts = arguments.data>
	</cffunction>

	<cffunction name="getOwner" access="public" returntype="string">
		<cfreturn variables.Owner>
	</cffunction>

	<cffunction name="setOwner" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.Owner = arguments.data>
	</cffunction>

	
	
	
	<!---------------------------------------->
	<!--- P R I V A T E     M E T H O D S  --->
	<!---------------------------------------->
	
	<!---------------------------------------->
	<!--- load					           --->
	<!---------------------------------------->		
	<cffunction name="load" access="private" returntype="void" hint="load and parse xml file">
		<cfscript>
			var xmlDoc = 0;
			var st = structNew(); 
			var xmlNode = 0;
			var i = 0;
			var siteDocPath = expandPath(variables.siteURL);
				
			// read configuration file
			if(Not fileExists(siteDocPath))
				throw("Site descriptor file not found [#siteDocPath#]","","homePortals.site.missingSiteXML");
			else
				xmlDoc = xmlParse(siteDocPath);

			// set initial values
			variables.siteTitle = "";
			variables.aPages = arrayNew(1);

			
			// get site title
			if(structKeyExists(xmlDoc.site,"title")) 
				variables.siteTitle = xmlDoc.xmlRoot.title.xmlText;
			
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
					arrayAppend(variables.aPages, st);
					
				}
			}
		</cfscript>
	</cffunction>
		
	<cffunction name="save" access="private" hint="Saves the site xml">
		<!--- get page in xml format --->
		<cfset var xmlDoc = toXML()>
	
		<!--- check that is a valid xml file --->
		<cfif Not IsXML(xmlDoc)>
			<cfset throw("The given site doc is not a valid XML document.")>
		</cfif>		
		<!--- store page --->
		<cffile action="write" file="#expandpath(variables.siteURL)#" output="#toString(xmlDoc)#">
	</cffunction>

	<cffunction name="saveXML" access="private" hint="Saves any xml file">
		<cfargument name="path" type="string" required="true">
		<cfargument name="xmlDoc" type="xml" required="true">
		<cffile action="write" 
				file="#expandpath(arguments.path)#" 
				output="#toString(arguments.xmlDoc)#">
	</cffunction>

	<cffunction name="throw" access="private" returntype="array">
		<cfargument name="message" type="string">
		<cfargument name="type" type="string" required="false" default="homePortals.site.error">
		<cfthrow  message="#arguments.message#" type="#arguments.type#">
	</cffunction>
	
	<cffunction name="getPageIndex" access="private" returntype="numeric" hint="Returns the index of the requested page in the local pages array. Returns 0 if page is not found">
		<cfargument name="pageHREF" type="string" required="true">
		<cfscript>
			var i = 1;
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				if(variables.aPages[i].href eq arguments.pageHREF) {
					return i;
				}
			}
			return 0;
		</cfscript>
	</cffunction>
	
</cfcomponent>