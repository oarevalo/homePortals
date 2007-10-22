<cfcomponent hint="This component is used to manipulate a user site">

	<cfscript>
		variables.userID = "";
		variables.accounts = 0;
		variables.siteURL = "";
		variables.xmlDoc = 0;
		variables.owner = 0;
		
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
			var oAccountsConfigBean = arguments.accounts.getConfig();
			var accountsRoot = oAccountsConfigBean.getAccountsRoot();
			
			variables.accounts = arguments.accounts;
			variables.owner = arguments.owner;

			variables.siteURL = accountsRoot & "/" & arguments.owner & "/site.xml";
			load(expandPath(variables.siteURL));
		</cfscript>
		<cfreturn this>
	</cffunction>
	

	<!---------------------------------------->
	<!--- load					           --->
	<!---------------------------------------->		
	<cffunction name="load" access="private" returntype="void" hint="load and parse xml file">
		<cfargument name="siteDocPath" type="string" required="yes" hint="The full path to the site descriptor document">
		
		<cfscript>
			var xmlDoc = 0;
			var st = structNew(); var xmlNode = 0;
			var i = 0;
				
			// read configuration file
			if(Not fileExists(arguments.siteDocPath))
				throw("Site descriptor file not found [#siteDocPath#]","","homePortals.site.missingSiteXML");
			else
				xmlDoc = xmlParse(arguments.siteDocPath);

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
									
					if(structKeyExists(xmlNode.xmlAttributes, "default")) st.default = xmlNode.xmlAttributes.default;
					if(structKeyExists(xmlNode.xmlAttributes, "href")) st.href = xmlNode.xmlAttributes.href;
					if(structKeyExists(xmlNode.xmlAttributes, "title")) st.title = xmlNode.xmlAttributes.title;
					
					// append to pages array
					arrayAppend(variables.aPages, st);
					
				}
			
			
			}
			
		</cfscript>
		
	</cffunction>
	

	<cffunction name="toXML" access="public" returnType="xml" hint="Returns the site information as an XML document">
		<cfscript>
			var xmlDoc = 0;
			var xmlNode = 0;
			var tmpPage = structNew();
			var i = 0;

			// create a blank xml document and add the root node
			xmlDoc = xmlNew();
			xmlDoc.xmlRoot = xmlElemNew(xmlDoc, "site");	
			
			// add title node
			xmlNode = xmlElemNew(xmlDoc, "title");
			xmlNode.xmlText = xmlFormat(variables.siteTitle);
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);	
			
			// add pages node
			xmlNode = xmlElemNew(xmlDoc, "pages");
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);	
			
			// add page nodes
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
			
				var tmpPage = variables.aPages[i];
			
				xmlNode = xmlElemNew(xmlDoc, "page");
				xmlNode.xmlAttributes["title"] = xmlFormat(tmpPage.title);
				xmlNode.xmlAttributes["href"] = xmlFormat(tmpPage.href);
				xmlNode.xmlAttributes["default"] = xmlFormat(tmpPage.default);
			
				arrayAppend(xmlDoc.xmlRoot.pages.xmlChildren, xmlNode);	
			
			}
			
		</cfscript>
		<cfreturn xmlDoc>
	</cffunction>
	
	

	<!---------------------------------------->
	<!--- setSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setSiteTitle" access="public" output="false" returntype="void">
		<cfargument name="title" type="string" required="true" hint="The new title for the site">
		<cfset variables.siteTitle = arguments.title>
		<cfset save()>
	</cffunction>


	<!---------------------------------------->
	<!--- getSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="getSiteTitle" access="public" returntype="string">
		<cfreturn variables.siteTitle>
	</cffunction>


	<!---------------------------------------->
	<!--- getPages				           --->
	<!---------------------------------------->	
	<cffunction name="getPages" access="public" returntype="array">
		<cfreturn variables.aPages>
	</cffunction>

	<!---------------------------------------->
	<!--- getUserID				           --->
	<!---------------------------------------->	
	<cffunction name="getUserID" access="public" returntype="string">
		<cfset var qryUser = 0>
		<cfset qryUser = variables.accounts.getAccountByUserName(variables.owner)>
		<cfreturn qryUser.userID>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getAccount			           --->
	<!---------------------------------------->	
	<cffunction name="getAccount" access="public" returntype="accounts">
		<cfreturn variables.accounts>
	</cffunction>

	<!---------------------------------------->
	<!--- getOwner				           --->
	<!---------------------------------------->	
	<cffunction name="getOwner" access="public" returntype="any">
		<cfreturn variables.owner>
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
	<!--- setDefaultPage	               --->
	<!---------------------------------------->	
	<cffunction name="setDefaultPage" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to set as default">
		<cfscript>
			var i = 1;
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				variables.aPages[i].default = (variables.aPages[i].href eq arguments.pageHREF);
			}
			save();
		</cfscript>
	</cffunction>


	<!---------------------------------------->
	<!--- movePageUp		               --->
	<!---------------------------------------->	
	<cffunction name="movePageUp" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to move">
		<cfscript>
			var targetIndex = 0;
			var originalIndex = 0;
			var i = 1;
	
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				if(variables.aPages[i].href eq arguments.pageHREF) {
					originalIndex = i;
					break;
				}
			}
			if(originalIndex eq 0) throw("page not found.");
			
			targetIndex = originalIndex - 1;
			if(targetIndex gt 0) {
				arraySwap(variables.aPages,originalIndex,targetIndex);
				save();
			} else {
				throw("Page could not be moved.");
			}
		</cfscript>
	</cffunction>


	<!---------------------------------------->
	<!--- movePageDown		               --->
	<!---------------------------------------->	
	<cffunction name="movePageDown" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to move">
		<cfscript>
			var targetIndex = 0;
			var originalIndex = 0;
			var i = 1;
	
			for(i=1;i lte arrayLen(variables.aPages);i=i+1) {
				if(variables.aPages[i].xmlAttributes.href eq arguments.pageHREF) {
					originalIndex = i;
					break;
				}
			}
			
			targetIndex = originalIndex + 1;
			if(targetIndex lte arrayLen(variables.aPages)) {
				arraySwap(variables.aPages,originalIndex,targetIndex);
				save();
			} else {
				throw("Page could not be moved.");
			}
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
		<cfargument name="pageName" required="true" type="string">
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
	<!--- P R I V A T E     M E T H O D S  --->
	<!---------------------------------------->	
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
	
</cfcomponent>