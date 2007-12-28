<!---
/******************************************************/
/* controlPanel.cfc									  */
/*													  */
/* This component provides functionality to           */
/* manage all aspects of a HomePortals page.          */
/*													  */
/* (c) 2005 - Oscar Arevalo							  */
/* oarevalo@cfempire.com							  */
/*													  */
/******************************************************/
--->

<cfcomponent displayname="controlPanel" hint="This component provides functionality to manage all aspects of a HomePortals page.">

	<!--- constructor code --->
	<cfset init()>


	<!---****************************************************************--->
	<!---         G E T     V I E W S     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- getView                          --->
	<!---------------------------------------->	
	<cffunction name="getView" access="remote" output="true">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
	
		<cfset arguments.viewName = "vw" & arguments.viewName>

		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>			

	<!---------------------------------------->
	<!--- getLogin      	               --->
	<!---------------------------------------->	
	<cffunction name="getLogin" access="remote" output="true">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
		<cfset arguments.viewName = "vwLogin">
		<cfset arguments.ownerOnly = false>
		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>	
		
	<!---------------------------------------->
	<!--- getCreateAccount 	               --->
	<!---------------------------------------->	
	<cffunction name="getCreateAccount" access="remote" output="true">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
		<cfset arguments.viewName = "vwCreateAccount">
		<cfset arguments.ownerOnly = false>
		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>	
		
	<!---------------------------------------->
	<!--- getAccountWelcome	               --->
	<!---------------------------------------->	
	<cffunction name="getAccountWelcome" access="remote" output="true">
		<cfargument name="useLayout" type="boolean" default="true">
		<cfset var tmpHTML = "">
		<cfset arguments.viewName = "vwAccountWelcome">
		<cfset arguments.ownerOnly = false>
		<cfinvoke method="renderView" argumentcollection="#arguments#" returnvariable="tmpHTML">
		<cfif arguments.useLayout>
			<cfset renderPage(tmpHTML)>
		<cfelse>
			<cfset writeOutput(tmpHTML)>
		</cfif>
	</cffunction>	
	
	



		


	<!---****************************************************************--->
	<!---         D O     A C T I O N     M E T H O D S                  --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- addModule			               --->
	<!---------------------------------------->	
	<cffunction name="addModule" access="remote" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		<cfargument name="locationID" type="string" required="yes">
		<cfargument name="catalog" type="string" required="yes">

		<cftry>
			<cfscript>
				initContext();
				xmlDoc = xmlParse(expandPath(this.pageURL));
	
				// get node info from catalog				
				xmlCatalog = xmlParse(expandpath(arguments.catalog));
				aNode = XMLSearch(xmlCatalog,"//module[@id='#arguments.moduleID#']");
	
				// insert new node in document
				tmpNode = xmlDoc.Page.modules;
				nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
				tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"module");				
				
				// create an id for the new module based on the catalog id
				if(Not StructKeyExists(aNode[1].xmlAttributes, "name") ) aNode[1].xmlAttributes.name = "";
				aNodeID = xmlSearch(xmlDoc,"//module[@name='#aNode[1].xmlAttributes.name#']");
				newModuleID = arguments.moduleID & (ArrayLen(aNodeID)+1);
				
				// add properties
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["id"] = newModuleID;
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["location"] = arguments.locationID;
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["name"] = aNode[1].xmlAttributes.name;
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["title"] = newModuleID;
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["style"] = "";
				tmpNode.xmlChildren[nodeIndex].xmlAttributes["moduleHREF"] = arguments.catalog & "##" & moduleID;
				
				aAttr = XMLSearch(xmlCatalog,"//module[@id='#arguments.moduleID#']/attributes/attribute");
				for(i=1; i lte ArrayLen(aAttr); i=i+1) {
					thisAttr = aAttr[i].xmlAttributes; 
					def = "";
					if(isDefined("thisAttr.xmlAttributes.default")) def = thisAttr.xmlAttributes.default;
					tmpNode.xmlChildren[nodeIndex].xmlAttributes[thisAttr.name] = def;
				}
				
				// add resources
				aRes = XMLSearch(xmlCatalog,"//module[@id='#arguments.moduleID#']/resources/resource");
				for(i=1; i lte ArrayLen(aRes); i=i+1) {
					thisRes = aRes[i].xmlAttributes; 
					if(thisRes.type eq "script") {
						aChk = XMLSearch(xmlDoc,"/Page/script[@src='#thisRes.href#']");
						if(ArrayLen(aChk) eq 0) {
							// add script resource
							tmpNode = xmlDoc.Page;
							nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
							tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"script");
							tmpNode.xmlChildren[nodeIndex].xmlAttributes["src"] = thisRes.href;
						}
					}
	
					if(thisRes.type eq "stylesheet") {
						aChk = XMLSearch(xmlDoc,"/Page/stylesheet[@href='#thisRes.href#']");
						if(ArrayLen(aChk) eq 0) {
							// add stylesheet resource
							tmpNode = xmlDoc.Page;
							nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
							tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"stylesheet");
							tmpNode.xmlChildren[nodeIndex].xmlAttributes["href"] = thisRes.href;
						}
					}
				}
				
				// add event handlers
				aEvs = XMLSearch(xmlCatalog,"//module[@id='#arguments.moduleID#']/eventListeners/event");
				for(i=1; i lte ArrayLen(aEvs); i=i+1) {
					thisEv = aEvs[i].xmlAttributes; 
					aChk = XMLSearch(xmlDoc,"/Page/eventListeners");
					// add eventlisteners section (in case it doesnt exist)
					if(ArrayLen(aChk) eq 0) {
						tmpNode = xmlDoc.Page;
						nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
						tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"eventListeners");
					}
					
					// add event listener
					tmpNode = xmlDoc.Page.eventListeners;
					nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
					tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"event");
					tmpNode.xmlChildren[nodeIndex].xmlAttributes["eventHandler"] = ReplaceNoCase(thisEv.eventHandler,"$ID$",newModuleID);
					tmpNode.xmlChildren[nodeIndex].xmlAttributes["eventName"] = thisEv.eventName;
					tmpNode.xmlChildren[nodeIndex].xmlAttributes["objectName"] = thisEv.objectName;
				}
				
				savePage(this.pageURL, xmlDoc);				
			</cfscript>
			
			<script>
				controlPanel.getView('Modules');
			</script>
			
			<cfcatch type="any">
				#cfcatch.Message#
			</cfcatch>		
		</cftry>
	</cffunction>	

	<!---------------------------------------->
	<!--- saveModule                       --->
	<!---------------------------------------->
	<cffunction name="saveModule" access="remote" output="true">
		<cfset var tmpHTML = "">
		<cfset var stForm = Duplicate(Arguments)>
		<cfset var _instanceName = "">
		<cfset var _attribs = "">

		<cftry>
			<cfscript>
				initContext();
				
				// get homeportals page
				xmlDoc = xmlParse(expandPath(this.pageURL));
			
				_attribs = stForm._attribs;
			
				// Remove the arguments for this method from the arguments scope, so that we
				// can recreate the original form
				StructDelete(stForm,"GUID");
				StructDelete(stForm,"SECTION");
				StructDelete(stForm,"btnSaveProperties");
				StructDelete(stForm,"_attribs");
	
				// make sure boolean params exist
				if (Not IsDefined("stForm.container")) stForm.container = false;
				if (Not IsDefined("stForm.output")) stForm.output = false;
				if (Not IsDefined("stForm.showPrint")) stForm.showPrint = false;
	
				// update selected node
				aNodes = xmlSearch(xmlDoc,"//modules/module[@id='#stForm.id#']");
				
				// if node found, then this is an update, else insert node
				if(ArrayLen(aNodes) gt 0) {
					for(i=1;i lte ListLen(_attribs);i=i+1) {
						fld = ListGetAt(_attribs,i);
						if(fld neq "") aNodes[1].xmlAttributes[fld] = stForm[fld];
					}
				} else {
					tmpNode = xmlDoc.Page.modules;
					nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
					tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"module");
					for(i=1;i lte ListLen(_attribs);i=i+1) {
						fld = ListGetAt(_attribs,i);
						if(fld neq "") tmpNode.xmlChildren[nodeIndex].xmlAttributes[fld] = stForm[fld];
					}
				}
				
				savePage(this.pageURL, xmlDoc);
			</cfscript>

			<script>
				controlPanel.setStatusMessage("Module saved.");
				//controlPanel.closeEditWindow();
				//window.location.replace("index.cfm?currentHome=#this.pageURL#&refresh=true&#RandRange(1,100)#");
			</script>

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage("#cfcatch.Message#");
				</script>
			</cfcatch>
		</cftry>
	</cffunction>		
	
	<!---------------------------------------->
	<!--- deleteModule                     --->
	<!---------------------------------------->
	<cffunction name="deleteModule" access="remote" output="true">
		<cfargument name="moduleID" type="string" required="yes">
		
		<cftry>
			<cfscript>
				initContext();
				
				// get homeportals page
				xmlDoc = xmlParse(expandPath(this.pageURL));
				
				// delete the module from the page
				tmpNode = xmlDoc.Page.modules;
				for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
					if(tmpNode.xmlChildren[i].xmlAttributes.id eq arguments.moduleID)
						ArrayClear(tmpNode.xmlChildren[i]);
				}
				
				// delete eventhandlers that refer to the instance of the module
				if(structKeyExists(xmlDoc.Page, "eventListeners")) {
					tmpNode = xmlDoc.Page.eventListeners;
					for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
						if(findNoCase(arguments.moduleID & ".", tmpNode.xmlChildren[i].xmlAttributes.eventHandler) ) {
							ArrayClear(tmpNode.xmlChildren[i]);
						}
					}
				} 
				
				savePage(this.pageURL, xmlDoc);
			</cfscript>
	
			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#this.PageURL#&refresh=true&#RandRange(1,100)#");
			</script>
			
			<cfcatch type="any">
				#cfcatch.Message#
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- saveProperty	                   --->
	<!---------------------------------------->		
	<cffunction name="saveProperty" access="remote" output="true">
		<cftry>
			<cfset initContext()>
			<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>

			<cfparam name="arguments.property_type" default="">
			<cfparam name="arguments.property_index" default="0">
		
			<cfswitch expression="#arguments.property_type#">
				<cfcase value="stylesheet">
					<cfset aNodes = xmlSearch(xmlDoc,"//stylesheet")>
					<cfset tmpNode = xmlDoc.Page>
					<cfset tmpNodeName = "stylesheet">
					<cfset lstAttribs = "href">
				</cfcase>
	
				<cfcase value="script">
					<cfset aNodes = xmlSearch(xmlDoc,"//script")>
					<cfset tmpNode = xmlDoc.Page>
					<cfset tmpNodeName = "script">
					<cfset lstAttribs = "src">
				</cfcase>
	
				<cfcase value="layout">
					<cfset aNodes = xmlSearch(xmlDoc,"//layout/location")>
					<cfset tmpNode = xmlDoc.Page.layout>
					<cfset tmpNodeName = "location">
					<cfset lstAttribs = "name,type,class">
				</cfcase>
	
				<cfcase value="listener">
					<cfset aNodes = xmlSearch(xmlDoc,"//eventListeners/event")>
					<cfset tmpNode = xmlDoc.Page.eventListeners>
					<cfset tmpNodeName = "event">
					<cfset lstAttribs = "objectName,eventName,eventHandler">
				</cfcase>
				
				<cfdefaultcase>
					<cfthrow message="Property type (#arguments.property_type#) not recognized.">
				</cfdefaultcase>
			</cfswitch>
	
			<cfscript>
				if(ArrayLen(aNodes) gt 0 and arguments.property_index gt 0) {
					for(i=1;i lte ListLen(lstAttribs);i=i+1) {
						fld = ListGetAt(lstAttribs,i);
						if(fld neq "") aNodes[arguments.property_index].xmlAttributes[fld] = arguments[fld];
					}
				} else {			
					nodeIndex = ArrayLen(tmpNode.xmlChildren)+1;
					tmpNode.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,tmpNodeName);
					for(i=1;i lte ListLen(lstAttribs);i=i+1) {
						fld = ListGetAt(lstAttribs,i);
						if(fld neq "") tmpNode.xmlChildren[nodeIndex].xmlAttributes[fld] = arguments[fld];
					}
				}
				
				savePage(this.pageURL, xmlDoc);
			</cfscript>
	
			<script>
				controlPanel.setStatusMessage("#arguments.property_type# saved.");
			</script>
			
			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage("#cfcatch.Message#. #cfcatch.detail#");
				</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- deleteProperty	               --->
	<!---------------------------------------->		
	<cffunction name="deleteProperty" access="remote" output="true">
		<cfparam name="arguments.property_type" default="">
		<cfparam name="arguments.property_index" default="0">
		
		<cftry>
			<cfset initContext()>
	
			<cfscript>
				tmpPath = ReplaceList(arguments.property_type,
									"stylesheet,script,layout,listener",
									"//stylesheet,//script,//layout/location,//eventListeners/event");
	
				// get homeportals page
				xmlDoc = xmlParse(expandPath(this.pageURL));
	
				aNodes =  xmlSearch(xmlDoc,tmpPath);
				if(arrayLen(aNodes) gte arguments.property_index)
					ArrayClear(aNodes[arguments.property_index]);
					
				savePage(this.pageURL, xmlDoc);	
			</cfscript>
			
			<script>
				controlPanel.setStatusMessage("#arguments.property_type# deleted.");
			</script>

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage("#cfcatch.Message#. #cfcatch.detail#");
				</script>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- addPage			               --->
	<!---------------------------------------->	
	<cffunction name="addPage" access="remote" output="true">
		<cfargument name="pageName" default="" type="string">
		<cfargument name="pageHREF" default="" type="string">

		<cfset var tmpHTML = "add">
		<cfset var pname = Arguments.pageName>
		<cfset var newPageURL = "">
		<cfset var stUser = structNew()>
		<cfset var stHPSettings = structNew()>
		
		<cftry>
			<cfset initContext()>
			
			<!--- get user info --->
			<cfset stUser = getUserInfo()>
			
			<!--- read site definition --->
			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtSiteDoc">

			
			<cfif arguments.pageHREF eq "">
				<!--- no pageHREF is given, so we add a blank page --->
				<cfif arguments.pageName eq "">
					<cfthrow message="Please enter a name for the new page.">
				</cfif>
	
				<!--- get HomePortals settings --->
				<cfset stHPSettings = duplicate(application.HomeSettings)>
				
				<!--- check that a template for new pages has been defined, if empty, users cannot add pages --->
				<cfif objAccounts.stConfig.newPageTemplate eq "">
					<cfthrow message="A template for new user pages has not been defined. Please contact system administrator.">
				</cfif>
			<cfelse>
				<!--- we have a pageHREF, so we are copying an existing page  --->
				<cfset tmpPageURL = this.accountsRoot & "/" & stUser.username & "/layouts/" & arguments.pageHREF>
				
				<cfif FileExists(ExpandPath(tmpPageURL))>
					<cffile action="read" file="#expandpath(tmpPageURL)#" variable="txtSourcePageDoc">
				<cfelse>
					<cfthrow message="The page you wish to duplicate does not exist. Please select an existing page.">
				</cfif>
			
			</cfif>
			
	
			<cfscript>
				// get site definition as xml object
				xmlSite = xmlParse(txtSiteDoc);
			
				// get source for new page
				if(arguments.pageHREF eq "") {
					// get new page and process tokens
					txtDoc = objAccounts.processTemplate(stUser.username, objAccounts.stConfig.newPageTemplate, stHPSettings);
				} else {
					// make sure we are copying a page from the current user
					bFound = false;
					for(i=1;i lte arrayLen(xmlSite.xmlRoot.pages.xmlChildren);i=i+1) {
						if(xmlSite.xmlRoot.pages.xmlChildren[i].xmlAttributes.href eq arguments.pageHREF) {
							bFound = true;
							break;
						}
					}
			
					// set a default name for the new page
					if(pname eq "") {
						pName = Replace(arguments.pageHREF,".xml","");
						pName = "Copy of " & pName;
					}

	
					if(bFound) {
						txtDoc = txtSourcePageDoc;
					} else
						throw("You are trying to copy a page that does not belong to you.");
				}
				
			
				// convert into xml document
				xmlPage = xmlParse(txtDoc);
				
				// set page title
				xmlPage.page.title.xmlText = pname;
							
				// format the new page's name			
				if(Right(pname,4) neq ".xml") pname = pname & ".xml";
				
				// define location of new page
				newPageURL = this.baseDir & pname;
				
				// save page
				savePage(newPageURL, xmlPage);
	
				// append new page name to site definition
				ArrayAppend(xmlSite.site.pages.xmlChildren, xmlElemNew(xmlSite,"page"));
				newNode = xmlSite.site.pages.xmlChildren[ArrayLen(xmlSite.site.pages.xmlChildren)];
				newNode.xmlAttributes["title"] = Replace(pname,".xml","");
				newNode.xmlAttributes["href"] = pname;
			</cfscript>
			
			<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlSite)#">
	
			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#newPageURL#&refresh=true&#RandRange(1,100)#");
			</script>

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage("#cfcatch.Message#. #cfcatch.detail#");
				</script>
			</cfcatch>
		</cftry>			
	</cffunction>

	<!---------------------------------------->
	<!--- addPageFromCatalog               --->
	<!---------------------------------------->	
	<cffunction name="addPageFromCatalog" access="remote" output="true">
		<cfargument name="catalogHREF" default="" type="string">
		<cfargument name="pageHREF" default="" type="string">

		<cfset var tmpHTML = "add">
		<cfset var newPageURL = "">
		
		<cftry>
			<cfset initContext()>
	
			<!--- read site definition --->
			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtDoc">
			<cfset xmlSite = xmlParse(txtDoc)>
		
			<cfscript>
				pname = GetFileFromPath(arguments.pageHREF);
				newPageName = ListFirst(pname,".");
				newPageExt = ListLast(pname,".");
				newPageURL = this.baseDir & newPageName & "." & newPageExt;

				// check if there is a page on the site with the same name
				try {
					index = 1;
					while(1) {
						xmlDoc = xmlParse(expandPath(newPageURL));
						newPageURL = this.baseDir & newPageName & index & "." & newPageExt;
						index = index + 1;
					}
				} catch(any e) {
					// do nothing. File doesn't exist
				}
			
				// copy the file
				xmlDoc = xmlParse(expandPath(arguments.pageHREF));	
				savePage(newPageURL, xmlDoc);
			
				// append new page name to site definition
				pname = GetFileFromPath(newPageURL);
				ArrayAppend(xmlSite.site.pages.xmlChildren, xmlElemNew(xmlSite,"page"));
				newNode = xmlSite.site.pages.xmlChildren[ArrayLen(xmlSite.site.pages.xmlChildren)];
				newNode.xmlAttributes["title"] = ListFirst(pname,".");
				newNode.xmlAttributes["href"] = pname;
			</cfscript>
			
			<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlSite)#">
	
			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#newPageURL#&refresh=true&#RandRange(1,100)#");
			</script>
			
			<cfcatch type="any">
				#cfcatch.Message#
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- deletePage		               --->
	<!---------------------------------------->	
	<cffunction name="deletePage" access="remote" output="true">
		<cfargument name="pageHREF" type="string" required="true">
		<cftry>
			<cfset tmpPageURL = "">

			<cfset initContext()>
			<cfset stUser = getUserInfo()>

			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtDoc">
			<cfset xmlDoc = xmlParse(txtDoc)>
			<cfset tmpPages = xmlDoc.site.pages>
	
			<!--- check that user has at least one other page --->
			<cfif ArrayLen(tmpPages.xmlChildren) eq 1>
				<cfthrow message="You cannot delete all pages in your site. You must have at least one page.">
			</cfif>
	
			<cfloop from="1" to="#arrayLen(tmpPages.xmlChildren)#" index="i">
				<cfif tmpPages.xmlChildren[i].xmlAttributes.href eq arguments.pageHREF>
					<cfset tmpPageURL = this.accountsRoot & "/" & stUser.username & "/layouts/" & arguments.pageHREF>
					<cfbreak>
				</cfif>
			</cfloop>
	
			<cfif tmpPageURL neq "">
				<!--- delete page --->
				<cffile action="delete" file="#expandpath(tmpPageURL)#"> 
		
				<!--- delete from site --->
				<cfscript>
					for(i=1;i lte ArrayLen(tmpPages.xmlChildren);i=i+1) {
						if(tmpPages.xmlChildren[i].xmlAttributes.href eq arguments.pageHREF)
							ArrayClear(tmpPages.xmlChildren[i]);
					}
				</cfscript>
				<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlDoc)#">
					
				<!--- redirect to homepage --->
				<cflocation url="#this.accountsRoot#/#stUser.username#">
			</cfif>

			<cfcatch type="any">
				#cfcatch.Message#
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- changeTitle	                   --->
	<!---------------------------------------->		
	<cffunction name="changeTitle" access="remote" output="true">
		<cfargument name="title" type="string" required="yes">

		<cftry>
			<cfset initContext()>
			<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>
			<cfset xmlDoc.Page.title.xmlText = arguments.title>
			<cfset savePage(this.pageURL, xmlDoc)>
	
			<script>
				controlPanel.setStatusMessage("Title changed.");
			</script>

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage('#cfcatch.Message#');
				</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- renamePage	                      --->
	<!---------------------------------------->		
	<cffunction name="renamePage" access="remote" output="true">
		<cfargument name="pageName" type="string" required="true">
		<cftry>
			<cfset initContext()>

			<!--- get user info --->
			<cfset stUser = getUserInfo()>
			
			<!--- get the name with and without extension (in case user gave one) --->
			<cfset short_name = replaceNoCase(arguments.pageName,".xml","")>
			<cfset full_name = short_name & ".xml">

			<cfset tmpPagePath = expandPath(this.pageURL)>

			<cfset newPageURL = this.accountsRoot & "/" & stUser.username & "/layouts/" & full_name>
			<cfset newPagePath = expandPath(newPageURL)>

			<!--- update site definition --->
			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtSiteDoc">			

			<cfscript>
				// get site definition as xml object
				xmlSite = xmlParse(txtSiteDoc);
				
				pageIndex = 0;
				for(i=1;i lte arrayLen(xmlSite.xmlRoot.pages.xmlChildren);i=i+1) {
					if(xmlSite.xmlRoot.pages.xmlChildren[i].xmlAttributes.href eq this.pageName) {
						pageIndex = i;
						break;
					}
				}
				
				if(pageIndex gt 0) {
					xmlSite.xmlRoot.pages.xmlChildren[pageIndex].xmlAttributes.href = full_name;
					xmlSite.xmlRoot.pages.xmlChildren[pageIndex].xmlAttributes.title = short_name;
				}
				
				
				// change title in page
				xmlDoc = xmlParse(expandPath(this.pageURL));
				xmlDoc.Page.title.xmlText = "HomePortals / #stUser.username# / #short_name#";
				savePage(this.pageURL, xmlDoc);

			</cfscript>

			<!--- rename file --->
			<cffile action="rename" source="#tmpPagePath#" destination="#newPagePath#">

			<!--- write changes to site.xml --->
			<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlSite)#">

			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#newPageURL#&refresh=true&#RandRange(1,100)#");
			</script>

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage('#cfcatch.Message#. #cfcatch.detail#');
				</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- changePrivate	                   --->
	<!---------------------------------------->		
	<cffunction name="changePrivate" access="remote" output="true">
		<cfargument name="isPrivate" type="boolean" required="yes">

		<cftry>
			<cfset initContext()>
			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtDoc">
	
			<cfscript>
				xmlDoc = xmlParse(txtDoc);
				tmpNode = xmlDoc.site.pages;
				for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
					if(tmpNode.xmlChildren[i].xmlAttributes.href eq this.pageName)
						tmpNode.xmlChildren[i].xmlAttributes["private"] = arguments.isPrivate;
				}
			</cfscript>
	
			<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlDoc)#">
			
			<cfif isPrivate>
				<cfset tmpMsg = "Current page set to private.">
			<cfelse>
				<cfset tmpMsg = "Current page set to public.">
			</cfif>
			
			<script>
				controlPanel.setStatusMessage('#tmpMsg#');
			</script>
			
			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage('#cfcatch.Message#');
				</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- changeDefault	                   --->
	<!---------------------------------------->		
	<cffunction name="changeDefault" access="remote" output="true">
		<cfargument name="isDefault" type="boolean" required="yes">

		<cftry>
			<cfset initContext()>
			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtDoc">
	
			<cfscript>
				xmlDoc = xmlParse(txtDoc);
				tmpNode = xmlDoc.site.pages;
				for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
					if(tmpNode.xmlChildren[i].xmlAttributes.href eq this.pageName)
						tmpNode.xmlChildren[i].xmlAttributes["default"] = arguments.isDefault;
					else {
						// if setting a default page, make sure no other page is set as default too
						if(arguments.isDefault) tmpNode.xmlChildren[i].xmlAttributes["default"] = false;
					}
				}
			</cfscript>
	
			<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlDoc)#">

			<cfif isDefault>
				<cfset tmpMsg = "Current page is now the default page.">
			<cfelse>
				<cfset tmpMsg = "Current page is no longer the default page.">
			</cfif>
						
			<script>
				controlPanel.setStatusMessage('#tmpMsg#');
			</script>
			
			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage('#cfcatch.Message#');
				</script>
			</cfcatch>
		</cftry>
	</cffunction>
	
	<!---------------------------------------->
	<!--- addCatalog	                   --->
	<!---------------------------------------->		
	<cffunction name="addCatalog" access="remote" output="true">
		<cfargument name="href" default="" type="string">

		<cfset var tmpHTML = "add">
		<cfset var xmlSite = "">
		
		<cftry>
			<cfset initContext()>
			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtDoc">
			
			<!--- check that requested catalog exists --->
			<cfif Not FileExists(expandpath(arguments.href))>
				<cfthrow message="The requested catalog (#arguments.href#) cannot be found.">
			</cfif>
	
			<cfscript>
				xmlSite = xmlParse(txtDoc);
				
				// append new page name to site definition
				if(Not StructKeyExists(xmlSite.site, "catalogs"))
					ArrayAppend(xmlSite.site.xmlChildren, xmlElemNew(xmlSite,"catalogs"));
				
				ArrayAppend(xmlSite.site.catalogs.xmlChildren, xmlElemNew(xmlSite,"catalog"));
				newNode = xmlSite.site.catalogs.xmlChildren[ArrayLen(xmlSite.site.catalogs.xmlChildren)];
				newNode.xmlAttributes["name"] = Replace(GetFileFromPath(arguments.href),".xml","");
				newNode.xmlAttributes["href"] = arguments.href;
			</cfscript>
			
			<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlSite)#">
	
			<script>
				controlPanel.setStatusMessage('Catalog added.');
			</script>	

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage('#cfcatch.Message#');
				</script>
			</cfcatch>
		</cftry>

	</cffunction>		
	
	<!---------------------------------------->
	<!--- removeCatalog		               --->
	<!---------------------------------------->	
	<cffunction name="removeCatalog" access="remote" output="true">
		<cfargument name="href" default="" type="string">
		
		<cftry>
			<cfset initContext()>
	
			<cffile action="read" file="#expandpath(this.siteURL)#" variable="txtDoc">
			<cfscript>
				xmlDoc = xmlParse(txtDoc);
				tmpNode = xmlDoc.site.catalogs;
				for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
					if(tmpNode.xmlChildren[i].xmlAttributes.href eq arguments.href)
						ArrayClear(tmpNode.xmlChildren[i]);
				}
			</cfscript>
			<cffile action="write" file="#expandpath(this.siteURL)#" output="#toString(xmlDoc)#">
				
			<script>
				controlPanel.setStatusMessage('Catalog removed.');
			</script>	

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage('#cfcatch.Message#');
				</script>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- publishPage   	               --->
	<!---------------------------------------->	
	<cffunction name="publishPage" access="remote" output="true">
		<cfargument name="catalog" default="" type="string">
		<cfargument name="description" default="" type="string">
		<cfargument name="pageHREF" default="" type="string">

		<cfset var tmpHTML = "add">
		<cfset var xmlDoc = "">
		<cfset var aCatalogs = arrayNew(1)>
		<cfset var catalogHREF = "">
		<cfset var aCheck = ArrayNew(1)>
		<cfset var stUser = structNew()>
		
		<cftry>
			<cfset initContext()>
			<cfset aCatalogs = getCatalogs()>

			<!--- get user info --->
			<cfset stUser = getUserInfo()>
			
			<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
				<cfif aCatalogs[i].href eq arguments.catalog>
					<cfset catalogHREF = aCatalogs[i].href>
				</cfif>
			</cfloop>

			<cfif catalogHREF eq "">
				<cfthrow message="The requested catalog is not one of your registered catalogs.">
			</cfif>
			
			<cffile action="read" file="#expandpath(catalogHREF)#" variable="txtDoc">
	
	
			<!--- check that the page to publish exists --->
			<cfset tmpPageURL = this.accountsRoot & "/" & stUser.username & "/layouts/" & arguments.pageHREF>
			
			<cfif FileExists(ExpandPath(tmpPageURL))>
				<cffile action="read" file="#expandpath(tmpPageURL)#" variable="txtSourcePageDoc">
			<cfelse>
				<cfthrow message="The page you wish to publish does not exist. Please select an existing page.">
			</cfif>
				
	
			<cfscript>
				xmlDoc = xmlParse(txtDoc);
				
				// check that page is not already in this catalog
				aCheck = xmlSearch(xmlDoc,"//page[@href='#tmpPageURL#']");
	
				if(ArrayLen(aCheck) eq 0) { 
					// get info on current page
					xmlPageDoc = xmlParse(expandPath(tmpPageURL));
					if(structKeyExists(xmlPageDoc.xmlRoot,"title"))
						tmpTitle = xmlPageDoc.xmlRoot.title.xmlText;
					else
						tmpTitle = arguments.pageHREF;

					// append new page name to site definition
					if(Not StructKeyExists(xmlDoc.xmlroot, "pages"))
						ArrayAppend(xmlDoc.xmlroot.xmlChildren, xmlElemNew(xmlDoc,"pages"));
					
					ArrayAppend(xmlDoc.xmlroot.pages.xmlChildren, xmlElemNew(xmlDoc,"page"));
					newNode = xmlDoc.xmlroot.pages.xmlChildren[ArrayLen(xmlDoc.xmlroot.pages.xmlChildren)];
					newNode.xmlAttributes["name"] = ReplaceNoCase(arguments.pageHREF,".xml","");
					newNode.xmlAttributes["href"] = tmpPageURL;
					newNode.xmlAttributes["title"] = tmpTitle;
					newNode.xmlAttributes["createdOn"] = now();
					newNode.xmlAttributes["id"] = createUUID(); 
					newNode.xmlText = arguments.description;
				}
			</cfscript>
			
			<cfif ArrayLen(aCheck) eq 0>
				<cffile action="write" file="#expandpath(catalogHREF)#" output="#toString(xmlDoc)#">
			</cfif>
	
			<script>
				controlPanel.getView('Site');
			</script>

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage('#cfcatch.Message#');
				</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doLogin        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogin" access="remote" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="password" type="string" required="yes">
		<cfargument name="rememberMe" default="false" type="boolean" required="no">

		<cfset var qryUser = QueryNew("")>
		
		<cftry>
			<!--- check login --->
			<cfset qryUser = objAccounts.checkLogin(arguments.username, Arguments.password)>
			
			<cfif qryUser.RecordCount eq 0>
				<cfthrow message="Invalid username/password.">
			<cfelse>
				<cfset session.User = StructNew()>
				<cfset session.User.ID = qryUser.UserID>
				<cfset session.User.LocalKey = Hash(qryUser.email & "-" & qryUser.username)>
				<cfset session.User.qry = qryUser>
			</cfif>

			<cfif arguments.rememberMe eq 1>
				<cfcookie name="homeportals_username" value="#qryUser.username#" expires="never">			
				<cfcookie name="homeportals_userKey" value="#session.User.LocalKey#" expires="never">			
			</cfif>
			
			<span style="color:##006600;">Welcome Back!</span>
					
			<cflocation url="#this.accountsRoot#/#qryUser.username#">
					
			<cfcatch type="any">
				<span style="color:##990000;">#cfcatch.Message#</span>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doCookieLogin        	           --->
	<!---------------------------------------->	
	<cffunction name="doCookieLogin" access="remote" output="true">
		<cfargument name="username" type="string" required="yes">
		<cfargument name="userkey" type="string" required="yes">

		<cfset var realKey = "">
		<cfset var qry = "">

		<cftry>
			<!--- get info on requested user --->
			<cfset qry = objAccounts.getAccountByUsername(arguments.username)>

			<!--- if user found, then authenticate user --->
			<cfif qry.RecordCount gt 0>
				<!--- build the real key that the user needs to authenticate --->
				<cfset realKey = Hash(qry.email & "-" & qry.username)>
				
				<!--- if provided key is the same as the real key, then user is authenticated --->
				<cfif arguments.userkey eq realkey>
					<cfset session.User = StructNew()>
					<cfset session.User.ID = qry.UserID>
					<cfset session.User.LocalKey = Hash(qry.email & "-" & qry.username)>
					<cfset session.User.qry = qry>
				</cfif>
			</cfif>

			<cfcatch type="any">
				<span style="color:##990000;">#cfcatch.Message#<br>#cfcatch.Detail#</span>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doLogoff        	               --->
	<!---------------------------------------->	
	<cffunction name="doLogoff" access="remote" output="true">
		<cfset var username = "">
		
		<cftry>
			<cfif IsDefined("session.user") and IsDefined("Session.user.qry")>
				<cfset username = session.user.qry.username>
				
				<!--- clear user from session --->
				<cfset session.user = "">
				
				<!--- delete cookies (in case autologin was enabled) --->
				<cfcookie name="homeportals_username" value="" expires="never">			
				<cfcookie name="homeportals_userKey" value="" expires="never">	
	
				<!--- redirect to user public homepage --->
				<cflocation url="#this.accountsRoot#/#username#">
			</cfif>
			
			<cfcatch type="any">
				<!--- redirect to user public homepage --->
				<cflocation url="#this.accountsRoot#/#username#">
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- doCreateAccount     	           --->
	<!---------------------------------------->	
	<cffunction name="doCreateAccount" access="remote" hint="Creates an account and sets up the account environment">
		<cfargument name="username" required="yes" type="string">
		<cfargument name="password" required="yes" type="string">
		<cfargument name="password2" required="yes" type="string">
		<cfargument name="email" required="no" type="string">
		
		<cfset var errMsg = "">
		
		<cftry>
			<!--- check that public account creation is enabled --->
			<cflock scope="application" type="readonly" timeout="10">
				<cfset allowRegister = application.HomePortalsAccountsConfig.allowRegisterAccount>
			</cflock>
			
			<cfif Not allowRegister>
				<cfthrow message="Public account creation in this site is not allowed. To create an account please contact the site administrator.">
			</cfif>

			<!--- validate arguments --->
			<cfscript>
				lstFlds = "Email,Password2,Password,Username";
				for(i=1;i lte ListLen(lstFlds);i=i+1) 
					if(Evaluate("arguments." & ListGetAt(lstFlds,i)) eq "") errMsg = ListGetAt(lstFlds,i) & " is required";
	
				if(Arguments.Password neq Arguments.Password2) errMsg = "Both passwords must match.";
			</cfscript>
			<cfif errMsg neq "">
				<cfthrow message="#errMsg#">
			</cfif>
	
			<!--- create account --->
			<cfset objAccounts.createAccount(arguments.username, arguments.password, arguments.email)>			

			<!--- login user --->
			<cfset doLogin(Arguments.Username, Arguments.Password)>

			<cfcatch type="any">
				<cfdump var="#cfcatch.tagContext#">
				<cfset tmpHTML = "<h3>An error ocurred while creating the account.</h3> <br>#cfcatch.Message#<br>#cfcatch.detail#">
				<cfoutput>#tmpHTML#</cfoutput>
			</cfcatch>
		</cftry>

	</cffunction>

	<!---------------------------------------->
	<!--- addPageToCurrentUser             --->
	<!---------------------------------------->	
	<cffunction name="addPageToCurrentUser" access="remote" output="true">
		<cfargument name="catalog" default="" type="string">
		<cfargument name="page" default="" type="string">

		<cfset var tmpHTML = "add">
		<cfset var newPageURL = "">
		<cfset var stUser = this.getUserInfo()>
		<cfset var userSiteURL = "">
		<cfset var userBaseDir = "">

		<cftry>
			<cfif stUser.username eq "">
				<cfthrow message="You must sign-in to your HomePortals account to add a page.">
			</cfif>
			
			<cfset userBaseDir = "#this.accountsRoot#/" & stUser.username & "/layouts/">
			<cfset userSiteURL =  "#this.accountsRoot#/" & stUser.username & "/site.xml">

			<!--- read site definition --->
			<cffile action="read" file="#expandpath(userSiteURL)#" variable="txtDoc">
			<cfset xmlSite = xmlParse(txtDoc)>
		
			<cfscript>
				pname = GetFileFromPath(arguments.page);
				newPageName = ListFirst(pname,".");
				newPageExt = ListLast(pname,".");
				newPageURL = userBaseDir & newPageName & "." & newPageExt;

				// check if there is a page on the site with the same name
				try {
					index = 1;
					while(1) {
						xmlDoc = xmlParse(expandPath(newPageURL));
						newPageURL = userBaseDir & newPageName & index & "." & newPageExt;
						index = index + 1;
					}
				} catch(any e) {
					// do nothing. File doesn't exist
				}
			
				// copy the file
				xmlDoc = xmlParse(expandPath(arguments.page));	
				savePage(newPageURL, xmlDoc);
			
				// append new page name to site definition
				pname = GetFileFromPath(newPageURL);
				ArrayAppend(xmlSite.site.pages.xmlChildren, xmlElemNew(xmlSite,"page"));
				newNode = xmlSite.site.pages.xmlChildren[ArrayLen(xmlSite.site.pages.xmlChildren)];
				newNode.xmlAttributes["title"] = ListFirst(pname,".");
				newNode.xmlAttributes["href"] = pname;
			</cfscript>
			
			<cffile action="write" file="#expandpath(userSiteURL)#" output="#toString(xmlSite)#">
	
			<script>
				closeEditWindow();
				window.location.replace("index.cfm?currentHome=#newPageURL#&refresh=true&#RandRange(1,100)#");
			</script>
			
			<cfcatch type="any">
				#renderPage(cfcatch.Message,"",false)#
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- selectSkin                       --->
	<!---------------------------------------->	
	<cffunction name="selectSkin" access="remote" output="true">
		<cfargument name="skinHREF" default="" type="string">

		<cfset var newPageURL = "">
		<cfset var stUser = this.getUserInfo()>
		<cfset var hasLocalStyle = false>
		<cfset var localStyleHREF = "">
		<cftry>
			<cfscript>
				initContext();
			
				// read page
				xmlDoc = xmlParse(expandPath(this.pageURL));
			
				// local style
				localStyleHREF = this.accountsRoot 
								& "/" & stUser.username 
								& "/styles/" 
								& getFileFromPath(this.pageURL) & ".css";
			
				// remove all stylesheets
				for(i=1;i lte ArrayLen(xmlDoc.Page.xmlChildren);i=i+1) {
					tmpNode = xmlDoc.Page.xmlChildren[i];
					if(tmpNode.xmlName eq "stylesheet") {
						if(tmpNode.xmlAttributes.href eq localStyleHREF) hasLocalStyle = true;
						ArrayDeleteAt(xmlDoc.Page.xmlChildren,i);
						i=i-1;
					}
				}
			
				// add new stylesheet
				if(arguments.skinHREF neq "") {
					nodeIndex = ArrayLen(xmlDoc.Page.xmlChildren)+1;
					xmlDoc.Page.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"stylesheet");
					xmlDoc.Page.xmlChildren[nodeIndex].xmlAttributes["href"] = arguments.skinHREF;
				}
				
				// add local style (if it had any)
				if(hasLocalStyle) {
					nodeIndex = ArrayLen(xmlDoc.Page.xmlChildren)+1;
					xmlDoc.Page.xmlChildren[nodeIndex] = xmlElemNew(xmlDoc,"stylesheet");
					xmlDoc.Page.xmlChildren[nodeIndex].xmlAttributes["href"] = localStyleHREF;
				}
				
				// save page
				savePage(this.pageURL, xmlDoc);
			</cfscript>

			<script>
				controlPanel.closeEditWindow();
				window.location.replace("index.cfm?currentHome=#this.pageURL#&refresh=true&#RandRange(1,100)#");
			</script>
											
			<cfcatch type="any">
				#cfcatch.Message#
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- sendFeedback     	               --->
	<!---------------------------------------->	
	<cffunction name="sendFeedback" access="remote" output="true">
		<cfargument name="comments" default="" type="string">
		
		<cftry>
			<!--- get info on current user --->
			<cfset stUser = getUserInfo()>
			
			<!--- get mail info --->
			<cflock scope="application" type="readonly" timeout="10">
				<cfset stAccountsConfig = application.HomePortalsAccountsConfig>
			</cflock>
		
			<!--- build contents --->
			<cfsavecontent variable="tmpHTML">
				<cfoutput>
					On #GetHTTPTimeString(now())# 
						<cfif stUser.username neq "">
							<strong>#stUser.username#</strong>
						<cfelse>
							<b>a visitor</b>
						</cfif>
						 wrote:<br>
					<p style="margin:10px;">#arguments.comments#</p>
				</cfoutput>
			</cfsavecontent>
		
			<!--- send email --->
			<cfif stAccountsConfig.emailAddress neq "">
				<cfif stAccountsConfig.mailServer neq "">
					<cfmail server="#stAccountsConfig.mailServer#"
							 to="#stAccountsConfig.emailAddress#"
							 from="#stAccountsConfig.emailAddress#"
							 subject="HomePortals: User Feedback"
							 type="html"><cfoutput>#tmpHTML#</cfoutput></cfmail>
				<cfelse>
					<cfmail to="#stAccountsConfig.emailAddress#"
							 from="#stAccountsConfig.emailAddress#"
							 subject="HomePortals: User Feedback"
							 type="html"><cfoutput>#tmpHTML#</cfoutput></cfmail>
				</cfif>
			<cfelse>
				<cfthrow message="Recipient email address has not been set. Please notify system administrator.">
			</cfif>

			<div class="cp_sectionTitle" style="padding:0px;width:340px;">
				<div style="margin:2px;">We Want To Hear From You</div>
			</div>
			
			<div class="cp_sectionBox" style="margin-top:0px;height:300px;width:340px;padding:0px;">					 
				<p align="center"><b>Thank you for your support!</b></p>
			</div>
			
			<cfcatch type="any">
				<!--- something happened --->
				<cfset renderPage("<p>An error ocurred while attempting to send the email.<br><br>#cfcatch.Message#<br>#cfcatch.Detail#</p>")>
			</cfcatch>
		</cftry>
		
	</cffunction>	

	<!---------------------------------------->
	<!--- updateModuleOrder                --->
	<!---------------------------------------->	
	<cffunction name="updateModuleOrder" access="remote" output="true">
		<cfargument name="layout" type="string" required="true" hint="New layout in serialized form">
		
		<cftry>
			<cfscript>
				initContext();
			
				// read page
				xmlDoc = xmlParse(expandPath(this.pageURL));
				
				// make copy of page
				xmlNewDoc = duplicate(xmlDoc);

				// clear all modules from page
				arrayClear(xmlNewDoc.xmlRoot.modules.xmlChildren);

				// get all locations into an array
				aLocations = listToArray(arguments.layout,":");
				
				// append modules to new page in the new order
				for(i=1;i lte arrayLen(aLocations);i=i+1) {
					if(listLen(aLocations[i],"|") gt 1) {
						thisLocation = ListGetAt(aLocations[i],1,"|");
						lstModules = ListGetAt(aLocations[i],2,"|");
						aModules = listToArray(lstModules);
					
						for(j=1;j lte arrayLen(aModules);j=j+1) {
							
							// find module node in original page
							tmpModuleNode = xmlSearch(xmlDoc,"//modules/module[@id='#aModules[j]#']");

							// create new module node
							xmlNewModuleNode = xmlElemNew(xmlNewDoc,"module");

							if(arrayLen(tmpModuleNode) gt 0) {
								stAttributes = tmpModuleNode[1].xmlAttributes;
								for(attr in stAttributes) {
									xmlNewModuleNode.xmlAttributes[attr] = stAttributes[attr];
								}
								xmlNewModuleNode.xmlAttributes["location"] = '#thisLocation#';
								
								// append new module
								arrayAppend(xmlNewDoc.xmlRoot.modules.xmlChildren, xmlNewModuleNode);
							}
						}
					}
				}

				// save page
				savePage(this.pageURL, xmlNewDoc);
			</cfscript>

			<script>
				controlPanel.setStatusMessage("Layout changed.");
			</script>

			<cfcatch type="any">
				<script>
					controlPanel.setStatusMessage("#cfcatch.Message#");
				</script>
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- savePageCSS			           --->
	<!---------------------------------------->	
	<cffunction name="savePageCSS" access="remote" output="true">
		<cfargument name="content" default="" type="string">

		<cfset var stUser = this.getUserInfo()>
		<cfset var localStyleHREF = "">
		<cfset var stylesPath = "">
		<cfset var xmlDoc = 0>
		<cfset var aStyleNode = 0>
		<cfset var i = 0>
		<cfset var tmpNode = 0>
		<cfset var tmpCSS = "">

		<cftry>
			<cfset initContext()>
			<cfif stUser.username eq "">
				<cfthrow message="You must sign-in to your HomePortals account to change the page stylesheet.">
			</cfif>
			
			<cfset stylesPath = this.accountsRoot & "/" 
									& stUser.username 
									& "/styles/">
			<cfset localStyleHREF = stylesPath & getFileFromPath(this.pageURL) & ".css">
	
			<cfif trim(arguments.content) neq ""> 
				<cfif Not DirectoryExists(expandPath(stylesPath))>
					<cfdirectory action="create" directory="#expandPath(stylesPath)#">
				</cfif>
	
				<!--- clean the css a bit --->
				<cfset tmpCSS = trim(arguments.content)>
				<cfset tmpCSS = replaceNoCase(tmpCSS,"javascript","","ALL")>
				<cfset tmpCSS = replaceNoCase(tmpCSS,"script","","ALL")>
				<cfset tmpCSS = replaceNoCase(tmpCSS,"eval","","ALL")>
				<cfset tmpCSS = REReplaceNoCase(tmpCSS, "j.*a.*v.*a.*s.*c.*r.*i.*p.*t", "","ALL")>
				
				<cffile action="write" file="#expandpath(localStyleHREF)#" output="#tmpCSS#">
	
				<cfscript>
					xmlDoc = xmlParse(expandPath(this.pageURL));
					aStyleNode = xmlSearch(xmlDoc,"//stylesheet[@href='#localStyleHREF#']");
					
					if(ArrayLen(aStyleNode) eq 0 ) {
						tmpNode = xmlElemNew(xmlDoc,"stylesheet");
						tmpNode.xmlAttributes["href"] = localStyleHREF;
						ArrayAppend(xmlDoc.xmlRoot.xmlChildren, tmpNode);
					}
					savePage(this.pageURL, xmlDoc);
				</cfscript>
				<cfoutput>Local stylesheet saved.</cfoutput>	
			</cfif>
			
			<cfcatch type="any">
				#cfcatch.Message#
			</cfcatch>
		</cftry>
	</cffunction>


	<!---****************************************************************--->
	<!---                P R I V A T E   M E T H O D S                   --->
	<!---****************************************************************--->

	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->	
	<cffunction name="init" access="private" hint="Initializes component.">
		<cfset var stSettings = structNew()>
		<cfset var stAccountSettings = structNew()>
		<cfset var bIsAccountsConfigLoaded = false>
		<cfset var tmpHomePortalsCFCPath = "">
		<cfset var hpRoot = application.homePortalsRoot>

		<!--- variables used by all methods --->
		<cfset this.baseDir = "">
		<cfset this.pageName = "">
		<cfset this.pageURL = "">
		<cfset this.siteURL = "">
		<cfset this.currentView = "">

		<!--- initialze HomePortals CFC --->
		<cfset tmpHomePortalsCFCPath = listAppend(hpRoot, "Components/homePortals", "/")>
		<cfset objHomePortals = CreateObject("component", tmpHomePortalsCFCPath)>
		

		<!--- initialize Accounts CFC --->
		<cfset objAccounts = CreateObject("component","accounts")>

		<!--- check if account config has been loaded into application scope --->
		<cflock scope="application" type="readonly" timeout="10">
			<cfset bIsAccountsConfigLoaded = StructKeyExists(application,"HomePortalsAccountsConfig")>
		</cflock>

		<cfif bIsAccountsConfigLoaded and Not StructKeyExists(URL, "refreshAccountInfo")>
			<!--- account config already loaded --->
			<cflock scope="application" type="readonly" timeout="10">
				<cfset stAccountSettings = application.HomePortalsAccountsConfig>
			</cflock>

			<!--- set config info in instance of accounts cfc --->
			<cfset objAccounts.setConfig(stAccountSettings)>			
		<cfelse>
			<!--- load account config --->
			<cfset objAccounts.loadConfig()>
			<cfset stAccountSettings = objAccounts.getConfig()>
			
			<!--- set accounts config in application scope --->
			<cflock scope="application" type="exclusive" timeout="10">
				<cfset application.HomePortalsAccountsConfig = stAccountSettings>
			</cflock>
		</cfif>

		<!--- set variable pointing to the directory where accounts are stored --->
		<cfset this.accountsRoot = stAccountSettings.accountsRoot>
	</cffunction>


	<!---------------------------------------->
	<!--- initContext                      --->
	<!---------------------------------------->	
	<cffunction name="initContext" access="public" hint="Returns the context for the current HomePortals page">
		<cfscript>
			if(structKeyExists(session, "homeConfig")) {
				this.pageURL = session.homeconfig.href;
				this.baseDir = GetDirectoryFromPath(this.pageURL);
				this.pageName = GetFileFromPath(this.pageURL);
				this.siteURL = this.baseDir & "/../site.xml";
			} else {
				throw("Your session has timed out. Please refresh the page");
			}
		</cfscript>		
	</cffunction>


	<!-------------------------------------->
	<!--- getUserInfo                    --->
	<!-------------------------------------->
	<cffunction name="getUserInfo" returntype="struct" hint="returns info about the current logged in user" access="public">
		<cfset var stRet = StructNew()>
		<cfset stRet.username = "">
		<cfset stRet.isOwner = false>
		
		<cfif structKeyExists(session, "homeConfig") and structKeyExists(session, "User")>
			<cfif isStruct(session.user) and structKeyExists(session.user, "qry")>
				<cfset stRet.username = session.user.qry.username>
				<cfset stRet.isOwner = (session.user.qry.username eq ListGetAt(session.homeConfig.href, 2, "/"))>
			</cfif>
		</cfif>
		
		<cfreturn stRet>
	</cffunction>	


	<!---------------------------------------->
	<!--- renderView                       --->
	<!---------------------------------------->		
	<cffunction name="renderView" access="private" returntype="string">
		<cfargument name="viewName" type="string" required="yes">
		<cfargument name="ownerOnly" type="boolean" required="no" default="true"
					hint="Flag that tells that only the page owner can access this page">
		
		<cfset var tmpHTML = "">
		<cfset var viewHREF = "views/" & arguments.viewName & ".cfm">
		<cfset var stUser = structNew()>
		<cfset var bRenderView = true>
		<cfset var publicViews = "vwFeedback,vwLogin,vwCreateAccount,vwError,vwNotAuthorized">
		
		<cfparam name="arguments.standAlone" default="true" type="boolean">

		<cftry>
			<cfset this.currentView = arguments.viewName>
	
			<cfif not ListFindNoCase(publicViews, arguments.viewName)>
				<!--- get main settings --->
				<cfset initContext()>
				
				<!--- get info on whether a user is logged in --->
				<cfset stUser = getUserInfo()>
				
				<cfif Not IsDefined("Session.homeConfig") or stUser.username eq "">
					<cfsavecontent variable="tmpHTML">
						<cfset arguments.standAlone = false>
						<cfinclude template="views/vwLogin.cfm">				
					</cfsavecontent>
					
				<cfelseif Not stUser.isOwner>
					<cfsavecontent variable="tmpHTML">
						<cfinclude template="views/vwNotAuthorized.cfm">				
					</cfsavecontent>
				</cfif>
			</cfif>
			
			<cfif tmpHTML eq "">
				<cfsavecontent variable="tmpHTML">
					<cfinclude template="#viewHREF#">				
				</cfsavecontent>
			</cfif>
		

			<cfcatch type="any">
				<cfset tmpHTML = cfcatch.Message & "<br>" & cfcatch.Detail>
			</cfcatch>
		</cftry>
		
		<cfreturn tmpHTML>
	</cffunction>


	<!---------------------------------------->
	<!--- renderPage                       --->
	<!---------------------------------------->
	<cffunction name="renderPage" access="private">
		<cfargument name="html" default="" hint="contents">
		
		<cfset var stUser = structNew()>
		<cfset var imgRoot = this.accountsRoot & "/default">
		<cfset var stAccountsConfig = structNew()>
		
		<cftry>
			<!--- get main settings --->
			<cfset initContext()>
			
			<!--- get info on whether a user is logged in --->
			<cfset stUser = getUserInfo()>

			<!--- get mail info --->
			<cflock scope="application" type="readonly" timeout="10">
				<cfset stAccountsConfig = application.HomePortalsAccountsConfig>
			</cflock>
						
			<cfcatch type="any">
				<cfset args = structNew()>
				<cfset args.viewName = "vwError">
				<cfset args.errMessage = cfcatch.Message>
				<cfinvoke method="renderView" 
							argumentcollection="#args#" 
							returnvariable="tmpHTML">
				<cfset arguments.html = tmpHTML>
			</cfcatch>
		</cftry>
		
		<Cfinclude template="layouts/controlPanelPage.cfm">
	</cffunction>
	
	
	<!---------------------------------------->
	<!--- getCatalogs                      --->
	<!---------------------------------------->
	<cffunction name="getCatalogs" access="private" 
				hint="returns an array with all catalogs for the current site" 
				returntype="array">
		
		<cfset var txtDoc = "">
		<cfset var xmlCatalog = "">
		<cfset var aCatalogNodes = ArrayNew(1)>
		<cfset var aCatalogs = ArrayNew(1)>
		<cfset var i = 0>
		<cfset var st = StructNew()>
	
		<cffile action="read" file="#expandpath(this.SiteURL)#" variable="txtDoc">
		<cfset xmlCatalog = xmlParse(txtDoc)>
		<cfset aCatalogNodes = xmlSearch(xmlCatalog,"//catalogs/catalog")>		
		
		<cfloop from="1" to="#ArrayLen(aCatalogNodes)#" index="i">
			<cfif aCatalogNodes[i].xmlName eq "catalog">
				<cfset attr = aCatalogNodes[i].xmlAttributes>
				<cfif structKeyExists(attr, "name") and structKeyExists(attr, "href")>
					<cfset st.name = aCatalogNodes[i].xmlAttributes.name>
					<cfset st.href = aCatalogNodes[i].xmlAttributes.href>
					<cfset ArrayAppend(aCatalogs, duplicate(st))>
				</cfif>
			</cfif>
		</cfloop>

		<cfreturn aCatalogs>
	</cffunction>	
	
	
	<!---------------------------------------->
	<!--- throw                            --->
	<!---------------------------------------->
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string" required="yes">
		<cfthrow message="#arguments.message#">
	</cffunction>


	<!---------------------------------------->
	<!--- dump                             --->
	<!---------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="data" type="any" required="yes">
		<cfdump var="#arguments.data#">
	</cffunction>	


	<!---------------------------------------->
	<!--- getSkins                         --->
	<!---------------------------------------->
	<cffunction name="getSkins" access="private" 
				hint="returns a query with with all skins from catalogs for the current site" 
				returntype="query">
		<cfset var qry = QueryNew("catalogHREF,catalogName,id,href")>
		<cfset var aCatalogs = getCatalogs()>
		
		<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
			<!--- get skins in this catalog --->
			<cfset selCatalog = aCatalogs[i]>
			<cfset txtDoc = "">
			
			<cfif left(selCatalog.href,4) neq "http">
				<!--- read catalog from local filesystem --->
				<cfif FileExists(expandPath(selCatalog.href))>
					<cffile action="read" file="#expandPath(selCatalog.href)#" variable="txtDoc">
				</cfif>
			<cfelse>
				<!--- read catalog from remote server --->
				<cfhttp url="#selCatalog.href#" resolveurl="yes">
				</cfhttp>
				<cfset txtDoc = cfhttp.FileContent>
			</cfif>
			
			<!--- only display skins when catalog has been read --->
			<cfif txtDoc neq "" and isXML(txtDoc)>
				<cfset xmlCatalog = xmlParse(txtDoc)>
				<cfset aSkins = xmlSearch(xmlCatalog,"//skin")>
				
				<cfloop from="1" to="#ArrayLen(aSkins)#" index="i">
					<cfset tmpNode = aSkins[i].xmlAttributes>
					<cfset QueryAddRow(qry)>
					<cfset QuerySetCell(qry,"catalogHREF",selCatalog.href)>
					<cfset QuerySetCell(qry,"catalogName",selCatalog.name)> 
					<cfset QuerySetCell(qry,"id",tmpNode.id)>
					<cfset QuerySetCell(qry,"href",tmpNode.href)>
				</cfloop>			
			</cfif>			
		</cfloop>		

		<cfreturn qry>
	</cffunction>

	<cffunction name="savePage" access="private" hint="Stores a HomePortals page">
		<cfargument name="pageURL" type="string" hint="Path for the page as a relative URL">
		<cfargument name="pageXML" type="any" hint="xml object representing the page">

		<!--- check that is a valid xml file --->
		<cfif Not IsXML(arguments.pageXML)>
			<cfset throw("The given HomePortals page is not a valid XML document.")>
		</cfif>		

		<!--- store page --->
		<cffile action="write" file="#expandpath(arguments.pageURL)#" output="#toString(arguments.pageXML)#">
	</cffunction>
</cfcomponent>