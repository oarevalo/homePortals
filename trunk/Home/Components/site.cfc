<cfcomponent hint="This component is used to manipulate a user site">

	<cfscript>
		variables.userID = "";
		variables.accounts = 0;
		variables.siteURL = "";
		variables.xmlDoc = 0;
		variables.owner = 0;
	</cfscript>
	
	<!---------------------------------------->
	<!--- init					           --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="site">
		<cfargument name="owner" type="string" required="true" hint="The owner of the site to load. this is the username of a homeportals account">
		<cfargument name="accounts" type="accounts" required="true" hint="This is a reference to the Accounts object">
		
		<cfscript>
			var oAccountsConfigBean = arguments.accounts.getConfig();
			var tmpSitePath = "";
			var accountsRoot = oAccountsConfigBean.getAccountsRoot();
			
			variables.accounts = arguments.accounts;
			variables.owner = arguments.owner;

			variables.siteURL = accountsRoot & "/" & arguments.owner & "/site.xml";
			tmpSitePath = ExpandPath(variables.siteURL);
			if(Not fileExists(tmpSitePath)) throw("Site information file does not exist for account #variables.owner#","homePortals.site.missingSiteXML");
			variables.xmlDoc = xmlParse(tmpSitePath);

		</cfscript>
		<cfreturn this>
	</cffunction>

	<!---------------------------------------->
	<!--- setSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="setSiteTitle" access="public" output="false" returntype="void">
		<cfargument name="title" type="string" required="true" hint="The new title for the site">
		<cfscript>
			var xmlNewNode = 0;
			
			if(structKeyExists(variables.xmlDoc.site,"title"))
				variables.xmlDoc.xmlRoot.title.xmlText = xmlFormat(arguments.title);
			else {
				xmlNewNode = xmlElemNew(variables.xmlDoc,"title");
				xmlNewNode.xmlText = xmlFormat(arguments.title);
				arrayAppend(variables.xmlDoc.xmlRoot.xmlChildren,xmlNewNode);
			}
			save();
		</cfscript>
	</cffunction>


	<!---------------------------------------->
	<!--- getSiteTitle			           --->
	<!---------------------------------------->	
	<cffunction name="getSiteTitle" access="public" returntype="string">
		<cfscript>
			var retVal = "";
			if(structKeyExists(variables.xmlDoc.site,"title")) {
				retVal = variables.xmlDoc.xmlRoot.title.xmlText;
			}
		</cfscript>
		<cfreturn retVal>
	</cffunction>


	<!---------------------------------------->
	<!--- getPages				           --->
	<!---------------------------------------->	
	<cffunction name="getPages" access="public" returntype="array">
		<cfscript>
			var aPageNodes = ArrayNew(1);
			var aPages = ArrayNew(1);
			var i = 0;
		
			aPageNodes = variables.xmlDoc.xmlRoot.pages.xmlChildren;
			for(i=1;i lte ArrayLen(aPageNodes);i=i+1) {
				ArrayAppend(aPages, duplicate(aPageNodes[i].xmlAttributes));
			}
		</cfscript>		
		<cfreturn aPages>
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
			var aPages = 0;
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
			aPages = variables.xmlDoc.xmlRoot.pages.xmlChildren;
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				if(aPages[i].xmlAttributes.href eq getFileFromPath(arguments.pageHREF)) {
					aPages[i].xmlAttributes["href"] = getFileFromPath(arguments.newPageHREF);
					aPages[i].xmlAttributes["title"] = tmpTitle;
					bFoundOnSite = true;
					break;
				}
			}
			if(Not bFoundOnSite) throw("The page [#arguments.pageHREF#] does not exist on this site.");
			save();
		</cfscript>
	</cffunction>


	<!---------------------------------------->
	<!--- setPageNavStatus		           --->
	<!---------------------------------------->	
	<cffunction name="setPageNavStatus" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to set whether it should appear on the nave map or not">
		<cfargument name="showInNav" type="boolean" required="true" hint="If true, then page shows in the nav bar.">
		<cfscript>
			var i = 1;
			var aPages = 0;
			
			aPages = variables.xmlDoc.xmlRoot.pages.xmlChildren;
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				if(aPages[i].xmlAttributes.href eq arguments.pageHREF) {
					aPages[i].xmlAttributes["showInNav"] = arguments.showInNav;
				}
			}
			save();
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- setPagePrivacyStatus	           --->
	<!---------------------------------------->	
	<cffunction name="setPagePrivacyStatus" access="public" output="false" returntype="void">
		<cfargument name="pageHREF" type="string" required="true" hint="The page to set its private status">
		<cfargument name="isPrivate" type="boolean" required="true" hint="private flag.">
		<cfscript>
			var i = 1;
			var aPages = 0;
			
			aPages = variables.xmlDoc.xmlRoot.pages.xmlChildren;
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				if(aPages[i].xmlAttributes.href eq arguments.pageHREF) {
					aPages[i].xmlAttributes["private"] = arguments.isPrivate;
				}
			}
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
			var aPages = 0;
			
			aPages = variables.xmlDoc.xmlRoot.pages.xmlChildren;
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				aPages[i].xmlAttributes["default"] = (aPages[i].xmlAttributes.href eq arguments.pageHREF);
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
			var aPages = 0;
	
			aPages = variables.xmlDoc.xmlRoot.pages.xmlChildren;
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				if(aPages[i].xmlAttributes.href eq arguments.pageHREF) {
					originalIndex = i;
					break;
				}
			}
			if(originalIndex eq 0) throw("page not found.");
			
			targetIndex = originalIndex - 1;
			if(targetIndex gt 0) {
				arraySwap(aPages,originalIndex,targetIndex);
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
			var aPages = 0;
	
			aPages = variables.xmlDoc.xmlRoot.pages.xmlChildren;
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				if(aPages[i].xmlAttributes.href eq arguments.pageHREF) {
					originalIndex = i;
					break;
				}
			}
			
			targetIndex = originalIndex + 1;
			if(targetIndex lte arrayLen(aPages)) {
				arraySwap(aPages,originalIndex,targetIndex);
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
			var aPages = variables.xmlDoc.site.pages.xmlChildren;
			var oAccountsConfigBean = variables.accounts.getConfig();
			var accountsRoot = oAccountsConfigBean.getAccountsRoot();

			// check that user has at least one other page
			if(ArrayLen(aPages) eq 1)
				throw("You cannot delete all pages in a site. A site must have at least one page.");
				
			// get page url
			for(i=1;i lte arrayLen(aPages);i=i+1) {
				if(aPages[i].xmlAttributes.href eq arguments.pageHREF) {
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
				for(i=1;i lte ArrayLen(aPages);i=i+1) {
					if(aPages[i].xmlAttributes.href eq arguments.pageHREF)
						ArrayDeleteAt(aPages,i);
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
				for(i=1;i lte arrayLen(xmlSite.xmlRoot.pages.xmlChildren);i=i+1) {
					thisPageHREF = xmlSite.xmlRoot.pages.xmlChildren[i].xmlAttributes.href; 
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
			newNode = xmlElemNew(xmlSite,"page");
			newNode.xmlAttributes["title"] = Replace(pname,".xml","");
			newNode.xmlAttributes["href"] = pname;
			ArrayAppend(xmlSite.site.pages.xmlChildren, newNode);
			
			// save changes to site
			save();
		</cfscript>
		<cfreturn newPageURL>
	</cffunction>



	<!---------------------------------------->
	<!--- P R I V A T E     M E T H O D S  --->
	<!---------------------------------------->	
	<cffunction name="save" access="private" hint="Saves the site xml">
		<!--- check that is a valid xml file --->
		<cfif Not IsXML(variables.xmlDoc)>
			<cfset throw("The given site doc is not a valid XML document.")>
		</cfif>		
		<!--- store page --->
		<cffile action="write" file="#expandpath(variables.siteURL)#" output="#toString(variables.xmlDoc)#">
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