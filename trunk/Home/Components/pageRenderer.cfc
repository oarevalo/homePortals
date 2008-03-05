<cfcomponent displayname="pageRenderer" hint="This component renders the output of a page">
	
	<cfscript>
		variables.stPage = StructNew();
		variables.pageBuffer = structNew();
		variables.pageBuffer["_htmlHead"] = structNew();
		variables.pageBuffer["_htmlModule"] = structNew();
		variables.lstModulesRender = ""; 		// list with the order in which the modules are rendered
		variables.loadedModuleClasses = "";		// this is a list of all module classes loaded in the current page
		variables.homePortalsEngineDir = "/Home/";		// path to location of HomePortals engine
		variables.errorTemplate = variables.homePortalsEngineDir & "/Common/Templates/error.cfm";	// template to display when errors occur while rendering page components
		variables.pageHREF = "";		// path to the current page
		variables.oHomePortalsConfigBean = 0;		// homeportals config
		variables.stTimers = structNew();
		variables.oCatalog = 0;			// reference to the current catalog
		
		variables.HTTP_GET_TIMEOUT = 15;	// timeout for HTTP requests in content modules
		variables.DEFAULT_CONTENT_CACHE_TTL = 30;	// default TTL for content items on the content cache
	</cfscript>

	<!--------------------------------------->
	<!----  init						----->
	<!--------------------------------------->	
	<cffunction name="init" access="public" returntype="pageRenderer">
		<cfargument name="pageHREF" type="string" required="true" hint="The url of the page to load">
		<cfargument name="configBean" type="homePortalsConfigBean" required="true" hint="HomePortals application settings">
		<cfargument name="catalog" type="catalog" required="true" hint="Current resource catalog">
		<cfset var start = getTickCount()>
		
		<cfif trim(arguments.pageHREF) eq "">
			<cfthrow message="Page address cannot be empty" type="homePortals.pageRenderer.missingPageURL">
		</cfif>

		<cfset variables.pageHREF = arguments.pageHREF>
		<cfset variables.oHomePortalsConfigBean = arguments.configBean>
		<cfset variables.oCatalog = arguments.catalog>
		
		<cfset loadPage()>
		
		<cfset variables.stTimers.init = getTickCount()-start>
		<cfreturn this>
	</cffunction>

	<!--------------------------------------->
	<!----  processModules				----->
	<!--------------------------------------->
	<cffunction name="processModules" access="public" output="false" 
				hint="processes all modules rendering its content. Generated content is saved for later.">
		<cfscript>
			var stModules = variables.stPage.page.modules;
			var aModules = arrayNew(1);
			var stModuleNode = structNew();
			var i = 1;
			var j = 1;
			var k = 1;
			var location = "";
			var aLayoutSectionTypes = listToArray( variables.oHomePortalsConfigBean.getLayoutSections() );
			var sectionType = "";
			var aSections = 0;
			var start = getTickCount();
			var moduleType = "";
			
			// reset the buffer
			resetPageBuffer();
			
			// loop through the section types in render order
			for(i=1;i lte ArrayLen(aLayoutSectionTypes);i=i+1) {
				sectionType = aLayoutSectionTypes[i];
				aSections = variables.stPage.page.layout[sectionType];
				
				// loop through all locations in this section type
				for(j=1;j lte ArrayLen(aSections);j=j+1) {
					location = aSections[j].name;

					if(structKeyExists(stModules,location)) {
						aModules = stModules[location];
						
						// loop through all modules in this location
						for(k=1;k lte arrayLen(aModules);k=k+1) {
							stModuleNode = stModules[location][k];
							moduleType = stModuleNode["_moduleType"];
							
							switch(moduleType) {
								
								case "module":	// render normal modules
									if(stModuleNode.name neq "") {
										if(left(stModuleNode.name,4) neq "http")
											processModule(stModuleNode);
										else
											processRemoteModule(stModuleNode);
										variables.lstModulesRender = listAppend(variables.lstModulesRender, stModuleNode.id);
									}
									break;
									
								case "content": // render content modules
									processContent(stModuleNode);
									break;
							}
							
						}
					}
				}
			}
			
			variables.stTimers.processModules = getTickCount()-start;
		</cfscript>
	</cffunction>



	<!--------------------------------------->
	<!----  renderPage					----->
	<!--------------------------------------->
	<cffunction name="renderPage" access="public" output="false" hint="Renders the entire page using the render template.">

		<cfscript>
			var renderTemplateBody = "";
			var index = 1;
			var finished = false;
			var stResult = structNew();
			var token = "";
			var arg1 = "";
			var arg2 = "";
			var rendered = "";
			var start = getTickCount();
			
			// get the render template for the full page
			renderTemplateBody = variables.oHomePortalsConfigBean.getRenderTemplateBody("page");

			// replace simple values
			renderTemplateBody = replace(renderTemplateBody, "$PAGE_TITLE$", getPageTitle(), "ALL");
			renderTemplateBody = replace(renderTemplateBody, "$PAGE_HTMLHEAD$", renderHTMLHeadCode(), "ALL");
			renderTemplateBody = replace(renderTemplateBody, "$PAGE_ONLOAD$", getBodyOnLoad(), "ALL");

			// search and replace "Custom Sections"
			index = 1;
			finished = false;
			while(Not finished) {
				stResult = reFindNoCase("\$PAGE_CUSTOMSECTION\[""([A-Z]*)""]\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					rendered = renderCustomSection(arg1);
					
					renderTemplateBody = replace(renderTemplateBody, token, rendered, "ALL");
					
					index = stResult.pos[1] + stResult.len[1];
				} else {
					finished = true;
				}
			}
			
			// search and replace "Layout Sections"
			index = 1;
			finished = false;
			while(Not finished) {
				stResult = reFindNoCase("\$PAGE_LAYOUTSECTION\[""([A-Z]*)""]\[""([A-Z]*)""]\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					arg2 = mid(renderTemplateBody,stResult.pos[3],stResult.len[3]);
					rendered = renderLayoutSection(arg1, arg2);
						
					renderTemplateBody = replace(renderTemplateBody, token, rendered, "ALL");
					
					index = stResult.pos[1] + stResult.len[1];
				} else {
					finished = true;
				}
			}

			variables.stTimers.renderPage = getTickCount()-start;
			
			return renderTemplateBody;	
		</cfscript>
	
	</cffunction>
	
	<!--------------------------------------->
	<!----  renderLayoutSection			----->
	<!--------------------------------------->
	<cffunction name="renderLayoutSection" access="public" output="false" hint="Renders all modules in a given layout section. Optionally, the caller can pass the html tag to use to for the layout section.">
		<cfargument name="layoutSection" type="string" required="yes">
		<cfargument name="tagName" type="string" required="no" default="div">

		<cfset var i = 0>
		<cfset var j = 0>
		<cfset var aModules = ArrayNew(1)>
		<cfset var aLocations = variables.stPage.page.layout[arguments.layoutSection]>
		<cfset var stModuleNode = structNew()>
		
		<cfset var tmpHTML = "">

		<!--- Loop through each section --->
		<cfloop from="1" to="#ArrayLen(aLocations)#" index="i">
			<cfset tmpHTML = tmpHTML & "<#arguments.TagName# class=""#aLocations[i].Class#"" style=""#aLocations[i].Style#"" id=""#aLocations[i].ID#"" valign=""top"">">
			
			<cfif StructKeyExists(variables.stPage.page.modules, aLocations[i].name)>
				<!--- Display all modules within this section --->
				<cfset aModules = variables.stPage.page.modules[aLocations[i].name]>
				<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
					<cfset stModuleNode = variables.stPage.page.modules[aLocations[i].name][j]>
					<cfif stModuleNode.output>
						<cfset tmpHTML = tmpHTML & renderModule(stModuleNode)>
					</cfif>
				</cfloop>
			</cfif>
			
			<cfset tmpHTML = tmpHTML & "</#arguments.TagName#>">
		</cfloop>
		
		<cfreturn tmpHTML>
	</cffunction>

	<!--------------------------------------->
	<!----  renderCustomSection			----->
	<!--------------------------------------->
	<cffunction name="renderCustomSection" access="public" hint="Renders template-based resources such as headers and footers." returntype="string" output="false">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var aResourceType = ArrayNew(1)>
		<cfset var i = 0>
		<cfset var tmpHTML = "">

		<!--- get an array with the resources of the give type --->
		<cfset aResourceType = variables.oHomePortalsConfigBean.getBaseResourcesByType(arguments.resourceType)>

		<!--- render each resource --->
		<cfsavecontent variable="tmpHTML">
			<cfloop from="1" to="#ArrayLen(aResourceType)#" index="i">
				<cftry>
					<cfinclude template="#aResourceType[i]#">
					<cfcatch type="any">
						<cfinclude template="#variables.errorTemplate#">
					</cfcatch>
				</cftry>
			</cfloop>	
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>

	<!--------------------------------------->
	<!----  renderHTMLHeadCode			----->
	<!--------------------------------------->
	<cffunction name="renderHTMLHeadCode" access="public" returntype="string" output="false">
		<cfset var i = 0>
		<cfset var aStylesheets = variables.stPage.page.stylesheets>
		<cfset var aScripts = variables.stPage.page.scripts>
		<cfset var aEventListeners = variables.stPage.page.eventListeners>
		<cfset var aMeta = variables.stPage.page.meta>
		<cfset var stPageHeadContent = getpageBufferByType("_htmlHead")>
		<cfset var moduleID = "">
		<cfset var tmpHTML = "">
		<cfset var appRoot = variables.oHomePortalsConfigBean.getAppRoot()>
		<cfset var resRoot = variables.oHomePortalsConfigBean.getResourceLibraryPath()>
		
		<!--- Add user-defined meta tags --->
		<cfloop from="1" to="#ArrayLen(aMeta)#" index="i">
			<cfset tmpHTML = tmpHTML & "<meta name=""#aMeta[i].name#"" content=""#aMeta[i].content#"" />">
		</cfloop>
			
		<!--- Include basic and user-defined CSS styles --->
		<cfloop from="1" to="#ArrayLen(aStylesheets)#" index="i">
			<cfset tmpHTML = tmpHTML & "<link rel=""stylesheet"" type=""text/css"" href=""#aStylesheets[i]#""/>">
		</cfloop>
		
		<!--- Add page skin --->
		<cfif variables.stPage.page.skinHREF neq "">
			<cfset tmpHTML = tmpHTML & "<link rel=""stylesheet"" type=""text/css"" href=""#resRoot#/#variables.stPage.page.skinHREF#""/>">
		</cfif>
		
		<!--- Include required and user-defined Javascript files --->
		<cfloop from="1" to="#ArrayLen(aScripts)#" index="i">
			<cfset tmpHTML = tmpHTML & "<script src=""#aScripts[i]#"" type=""text/javascript""></script>">
		</cfloop>
		
		<!--- Process event listeners --->
		<cfsavecontent variable="tmpHTML2">
			<cfoutput>
			<script type="text/javascript">
				/*********** Set app root **********/
				h_appRoot = "#appRoot#";
				
				/*********** Raise events by modules *************/
				function h_raiseEvent(objectName, eventName, args) {
					<cfloop from="1" to="#ArrayLen(aEventListeners)#" index="i">
						if(objectName=="#aEventListeners[i].objectName#" && eventName=="#aEventListeners[i].eventName#") {
							try {#aEventListeners[i].eventHandler#(args);} catch(e) {alert(e);}
						}
					</cfloop>
				}
			</script>
			</cfoutput>
		</cfsavecontent>
		<cfset tmpHTML = tmpHTML & tmpHTML2>
		
		<!--- Add html head code rendered by modules --->
		<cfloop list="#variables.lstModulesRender#" index="moduleID">
			<cfif structKeyExists(stPageHeadContent, moduleID)>
				<cfset tmpHTML = tmpHTML & trim(stPageHeadContent[moduleID])>
			</cfif>
		</cfloop>

		 <!--- 
		 	Remove all whitespace from HEAD code
		 	(for now is commented out because this can create problems with some JavaScript files)
		 	<cfset tmpHTML = REReplace(tmpHTML, "[[:space:]]{2,}","","ALL")> 
		 --->
		 
		<cfreturn tmpHTML>
	</cffunction>
	
	<!--------------------------------------->
	<!----  getPageTitle				----->
	<!--------------------------------------->
	<cffunction name="getPageTitle" access="public" returntype="string" output="false" hint="Returns the title of the page">
		<cfreturn variables.stPage.page.title>
	</cffunction>
	
	<!--------------------------------------->
	<!----  getBodyOnLoad				----->
	<!--------------------------------------->
	<cffunction name="getBodyOnLoad" access="public" returntype="string" output="false" hint="Returns the javascript statement to run on the onLoad attribute of the body tag">
		<cfreturn variables.oHomePortalsConfigBean.getBodyOnLoad()>
	</cffunction>	
	
	<!--------------------------------------->
	<!----  getPageHREF					----->
	<!--------------------------------------->
	<cffunction name="getPageHREF" access="public" returntype="string" output="false" hint="Returns the location of the page">
		<cfreturn variables.pageHREF>
	</cffunction>	
	
	<!--------------------------------------->
	<!----  getOwner					----->
	<!--------------------------------------->
	<cffunction name="getOwner" access="public" returntype="string" output="false" hint="Returns the owner of the page">
		<cfreturn variables.stPage.page.owner>
	</cffunction>
	
	<!--------------------------------------->
	<!----  getAccess					----->
	<!--------------------------------------->
	<cffunction name="getAccess" access="public" returntype="string" output="false" hint="Returns the access level of the page">
		<cfreturn variables.stPage.page.access>
	</cffunction>		
	
	<!---------------------------------------->
	<!--- getTimers						   --->
	<!---------------------------------------->	
	<cffunction name="getTimers" access="public" returntype="any" hint="Returns the timers for this object">
		<cfreturn variables.stTimers>
	</cffunction>	
	
	
	<!----------  P R I V A T E    M E T H O D S    ----------------->
	
	<!--------------------------------------->
	<!----  loadPage					----->
	<!--------------------------------------->
	<cffunction name="loadPage" access="private" returntype="void" hint="loads and parses a homeportals page">
		<cfscript>
			var tmpXML = "";
			var xmlDoc = "";
			var i = 0;
			var j = 0;
			var xmlNode = 0;
			var xmlThisNode = 0;
			var tmrStart = getTickCount();
			var isHTTPS = (structKeyExists(cgi,"HTTPS") and cgi.https eq "ON");
			var item = "";
			
			var aScriptResources = variables.oHomePortalsConfigBean.getBaseResourcesByType("script");
			var aStyleResources = variables.oHomePortalsConfigBean.getBaseResourcesByType("style");
			var lstLayoutSections = variables.oHomePortalsConfigBean.getLayoutSections();
			
			var oResourceBean = 0;
			var args = structNew();
		
			// check if we are on HTTPS and if we need to modify the root
			if(isHTTPS and left(variables.pageHREF,1) eq "/")
				variables.href = variables.oHomePortalsConfigBean.getSSLRoot() & variables.pageHREF;
		
			// ****** Read homePortals page ******
			if(fileExists(expandPath(variables.pageHREF)))
				xmlDoc = xmlParse(expandPath(variables.pageHREF));
			else
				throw("The requested page [#variables.pageHREF#] does not exist.","","homePortals.engine.pageNotFound");
		
			// ****** Parse homePortals page contents ******
			// Structure to hold the page info
			variables.stPage = StructNew();
			variables.stPage.xml = toString(xmlDoc);		
			variables.stPage.page = StructNew();
			variables.stPage.page.title = "";
			variables.stPage.page.basePath = "";
			variables.stPage.page.href = variables.pageHREF;	// address of the page
			variables.stPage.page.owner = "";					// the account to which the current page belongs to
			variables.stPage.page.stylesheets = ArrayNew(1);
			variables.stPage.page.scripts = ArrayNew(1);
			variables.stPage.page.eventListeners = ArrayNew(1);
			variables.stPage.page.layout = StructNew();			// holds properties for layout sections
			variables.stPage.page.modules = StructNew();		// holds modules
			variables.stPage.page.meta = arrayNew(1);			// holds html meta tags
			variables.stPage.page.skinHREF = "";				// holds the location of the page skin
		
			// set page owner
			if(structKeyExists(xmlDoc.xmlRoot.xmlAttributes, "owner"))
				variables.stPage.page.owner = xmlDoc.xmlRoot.xmlAttributes.owner;

			// set page access level
			if(structKeyExists(xmlDoc.xmlRoot.xmlAttributes, "access"))
				variables.stPage.page.access = xmlDoc.xmlRoot.xmlAttributes.access;
			else
				variables.stPage.page.access = "general";
		
			// add base resources
			for(i=1;i lte ArrayLen(aScriptResources);i=i+1) {
				ArrayAppend(variables.stPage.page.scripts, aScriptResources[i]);
			}
			for(i=1;i lte ArrayLen(aStyleResources);i=i+1) {
				ArrayAppend(variables.stPage.page.stylesheets, aStyleResources[i]);
			}
	
			// set placeholders for layout sections
			for(i=1;i lte ListLen(lstLayoutSections);i=i+1) {
				thisSection = ListGetAt(lstLayoutSections,i);
				variables.stPage.page.layout[thisSection] = ArrayNew(1);
			}
			
			// process top level nodes
			for(i=1;i lte ArrayLen(xmlDoc.xmlRoot.xmlChildren);i=i+1) {
				
				// get poiner to current node
				xmlNode = xmlDoc.xmlRoot.xmlChildren[i];
				
				switch(xmlNode.xmlName) {
				
					// title node
					case "title":
						variables.stPage.page.title = xmlNode.xmlText;
						break;
						
					// stylesheets
					case "stylesheet":
						ArrayAppend(variables.stPage.page.stylesheets, xmlNode.xmlAttributes.Href);
						break;
						
					// script
					case "script":
						ArrayAppend(variables.stPage.page.scripts, xmlNode.xmlAttributes.src);
						break;
				
					// layout
					case "layout":
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {
							if(xmlNode.xmlChildren[j].xmlName eq "location") {
								xmlThisNode = xmlNode.xmlChildren[j];
				
								if(Not structKeyExists(xmlThisNode.xmlAttributes, "name")) 
									throw("Invalid HomePortals xml. Location node does not have a Name.","","homePortals.engine.invalidPage");
								if(Not structKeyExists(xmlThisNode.xmlAttributes, "type")) 
									throw("Invalid HomePortals xml. Location node does not have a Type.","","homePortals.engine.invalidPage");
								if(Not structKeyExists(xmlThisNode.xmlAttributes, "class")) xmlThisNode.xmlAttributes.class = ""; 
								if(Not structKeyExists(xmlThisNode.xmlAttributes, "style")) xmlThisNode.xmlAttributes.style = ""; 
								if(Not structKeyExists(xmlThisNode.xmlAttributes, "id")) xmlThisNode.xmlAttributes.id = "h_location_#xmlThisNode.xmlAttributes.type#_#j#"; 
				
								ArrayAppend(variables.stPage.page.layout[xmlThisNode.xmlAttributes.type], duplicate(xmlThisNode.xmlAttributes) );
							}
						}
						break;	
									
					// modules
					case "modules":
						if(structKeyExists(xmlNode.xmlAttributes, "basePath"))
							variables.stPage.page.basePath = xmlNode.xmlAttributes.basePath;
	
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {

							xmlThisNode = xmlNode.xmlChildren[j];

							args = structNew();	// this structure is used to hold the module attributes
							args["_moduleType"] = xmlThisNode.xmlName;	// store the "type" of module

							// copy all attributes from the node into another struct
							// (modified for Railo2 compatibility)
							for(item in xmlThisNode.xmlAttributes) {
								args[item] = xmlThisNode.xmlAttributes[item];
							}
							

							// define common attributes for module tags
							if(Not structKeyExists(args, "id")) args.id = ""; 
							if(Not structKeyExists(args, "location")) throw("Invalid HomePortals page. Module node does not have a Location.","","homePortals.engine.invalidPage");
							if(Not structKeyExists(args, "container")) args.container = true; 
							if(Not structKeyExists(args, "title")) args.title = ""; 
							if(Not structKeyExists(args, "icon")) args.icon = ""; 
							if(Not structKeyExists(args, "style")) args.style = ""; 
							if(Not structKeyExists(args, "output")) args.output = true; 

							// Provide a unique ID for each module 
							if(args.id eq "") args.id = "h_#xmlThisNode.xmlName#_#args.location#_#j#";


							// handle child tags
							switch(xmlThisNode.xmlName) {
							
								case "module":		// handle <module> tag

									if(Not structKeyExists(args, "name")) args.name = "";
									if(args.title eq "") args.title = args.name; 
									break;

							
								case "content":		// handle <content> tag
								
									if(Not structKeyExists(args, "resourceID")) args.resourceID = ""; 
									if(Not structKeyExists(args, "resourceType")) args.resourceType = "content"; 
									if(Not structKeyExists(args, "href")) args.href = ""; 
									if(Not structKeyExists(args, "cache")) args.cache = true; 
									if(Not structKeyExists(args, "cacheTTL")) args.cacheTTL = variables.DEFAULT_CONTENT_CACHE_TTL; 
									break;
							}
							
							// create structure for modules that belong to the same location
							if(Not StructKeyExists(variables.stPage.page.modules, args.location) )
								variables.stPage.page.modules[args.location] = ArrayNew(1);
							
							ArrayAppend(variables.stPage.page.modules[args.location], duplicate(args) );
						}
	
						break;
							
					// event handlers
					case "eventListeners":
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {
							if(xmlNode.xmlChildren[j].xmlName eq "event") {
								xmlThisNode = xmlNode.xmlChildren[j];
								if(Not StructKeyExists(xmlThisNode.xmlAttributes,"objectName")) xmlThisNode.xmlAttributes.objectName = ""; 
								if(Not StructKeyExists(xmlThisNode.xmlAttributes,"eventName")) xmlThisNode.xmlAttributes.eventName = ""; 
								if(Not StructKeyExists(xmlThisNode.xmlAttributes,"eventHandler")) xmlThisNode.xmlAttributes.eventHandler= ""; 
								
								ArrayAppend(variables.stPage.page.eventListeners, duplicate(xmlNode.xmlChildren[j].xmlAttributes));
							}
						}
						break;	

					// meta tags
					case "meta":
						if(Not StructKeyExists(xmlNode.xmlAttributes,"name")) xmlNode.xmlAttributes.name = ""; 
						if(Not StructKeyExists(xmlNode.xmlAttributes,"content")) xmlNode.xmlAttributes.content = ""; 
						
						ArrayAppend(variables.stPage.page.meta, duplicate(xmlNode.xmlAttributes));
						break;	

					// skin	
					case "skin":
						if(Not StructKeyExists(xmlNode.xmlAttributes,"id")) xmlNode.xmlAttributes.id = ""; 
						
						// get skin location from catalog 
						oResourceBean = variables.oCatalog.getResourceNode("skin", xmlNode.xmlAttributes.id);
						variables.stPage.page.skinHREF = oResourceBean.getHref();
						
						break;	
				}
			}		
			
		</cfscript>	
	</cffunction>
		
	
	<!--------------------------------------->
	<!----  processModule				----->
	<!--------------------------------------->
	<cffunction name="processModule" access="private" hint="Executes a module">
		<cfargument name="moduleNode" type="any" required="true">
		<cfscript>
			var bIsFirstInClass = false;
			var oModuleController = 0;
			var moduleID = arguments.moduleNode.id;
			var moduleName = arguments.moduleNode.name;
			var tmpMsg = "";
			var isHTTPS = (structKeyExists(cgi,"HTTPS") and cgi.https eq "ON");
			var start = getTickCount();

			// if we are on HTTPS then prefix the module with the SSL root
			if(isHTTPS) moduleName = variables.oHomePortalsConfigBean.getSSLRoot() & moduleName;

			try {
				// if there is a base path then prepend it to the module name
				// otherwise prepend the module library path
				if(variables.stPage.page.basePath neq "")
					moduleName = variables.stPage.page.basePath & moduleName;
				else
					moduleName = variables.oHomePortalsConfigBean.getResourceLibraryPath() & "/Modules/" & moduleName;

				// convert the moduleName into a dot notation path
				moduleName = replace(moduleName,"/",".","ALL");
				moduleName = replace(moduleName,"..",".","ALL");
				if(left(moduleName,1) eq ".") moduleName = right(moduleName, len(moduleName)-1);

				// check if this module is the first of its class to be rendered on the page
				bIsFirstInClass = (Not listFind(variables.loadedModuleClasses, moduleName));
				
				// add information about the page to moduleNode
				arguments.moduleNode["_page"] = structNew();
				arguments.moduleNode["_page"].owner =  variables.stPage.page.owner;
				arguments.moduleNode["_page"].href =  variables.stPage.page.href;
				
				// instantiate module controller and call constructor
				oModuleController = createObject("component","moduleController");
				oModuleController.init(moduleID, moduleName, arguments.moduleNode, bIsFirstInClass, "local", variables.oHomePortalsConfigBean);

				// render html content
				appendpageBuffer("_htmlHead", moduleID, oModuleController.renderClientInit() );
				appendpageBuffer("_htmlHead", moduleID, oModuleController.renderHTMLHead() );
				appendpageBuffer("_htmlModule", moduleID, oModuleController.render() );
				
				if(bIsFirstInClass) {
					// append module name to list of loaded module classes to avoid initializing the same class twice
					variables.loadedModuleClasses = listAppend(variables.loadedModuleClasses, moduleName);
				}

			} catch(any e) {
				tmpMsg = "<b>An unexpected error ocurred while initializing module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				appendpageBuffer("_htmlModule", moduleID, tmpMsg );
			}
			
			variables.stTimers["processModule_#moduleID#"] = getTickCount()-start;
		</cfscript>		
	</cffunction>	
	
	<!--------------------------------------->
	<!----  processRemoteModule			----->
	<!--------------------------------------->
	<cffunction name="processRemoteModule" access="private" hint="processes modules that are located on a different server.">
		<cfargument name="moduleNode" type="any" required="true">

		<cfset var moduleID = arguments.moduleNode.id>
		<cfset var moduleName = arguments.moduleNode.name>
		<cfset var tmpHTML = "">
		<cfset var arg = "">

		<cftry>
			<cfhttp method="get" url="#moduleName#" 
					timeout="10" resolveurl="true" 
					redirect="true" throwonerror="true">
				<cfloop collection="#arguments.moduleNode#" item="arg">
					<cfif IsSimpleValue(arguments.moduleNode[arg])>
						<cfhttpparam type="url" name="#arg#" value="#arguments.moduleNode[arg]#">
					</cfif>
				</cfloop>
			</cfhttp>
			<cfset appendpageBuffer("_htmlModule", moduleID, cfhttp.FileContent )>

			<cfcatch type="any">
				<cfsavecontent variable="tmpHTML">
					<cfinclude template="#variables.errorTemplate#">
				</cfsavecontent>
				<cfset appendpageBuffer("_htmlModule", moduleID, tmpHTML )>
			</cfcatch>
		</cftry>
	</cffunction>	
	
	<!--------------------------------------->
	<!----  processContent				----->
	<!--------------------------------------->
	<cffunction name="processContent" access="private" hint="Retrieves content to display in the page">
		<cfargument name="moduleNode" type="any" required="true">
		<cfscript>
			var moduleID = arguments.moduleNode.id;
			var start = getTickCount();
			var tmpHTML = "";
			var contentSrc = "";
			
			try {

				// define source of content (resource or external)
				if(arguments.moduleNode.resourceID neq "") {
					oResourceBean = variables.oCatalog.getResourceNode(arguments.moduleNode.resourceType, arguments.moduleNode.resourceID);
					contentSrc = variables.oHomePortalsConfigBean.getResourceLibraryPath() & "/" & oResourceBean.getHref();
				
				} else if(arguments.moduleNode.href neq "") {
					contentSrc = arguments.moduleNode.href;
				}

				// retrieve content
				if(contentSrc neq "") {
					if(left(contentSrc,4) eq "http") {
						st = httpget(contentSrc);
						tmpHTML = st.fileContent;
					} else {
						tmpHTML = readFile( expandPath( contentSrc) );
					}
				}

				// add rendered content to buffer
				appendpageBuffer("_htmlModule", moduleID, tmpHTML );

			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while retrieving content for content module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				appendpageBuffer("_htmlModule", moduleID, tmpHTML );
			}

			variables.stTimers["processContent_#moduleID#"] = getTickCount()-start;
		</cfscript>
	</cffunction>



	<!--------------------------------------->
	<!----  renderModule				----->
	<!--------------------------------------->
	<cffunction name="renderModule" access="private" returntype="string" hint="Initializes and renders a HomePortals module instance." output="false">
		<cfargument name="moduleNode" type="struct" required="true">

		<cfscript>
			var moduleID = arguments.moduleNode.id;
			var renderTemplateBody = "";
			var tmpIconURL = "";

			if(arguments.moduleNode.icon neq "") 
				tmpIconURL = "<img src='#arguments.moduleNode.icon#' width='16' height='16' align='absmiddle'>";
			
			if(arguments.moduleNode.Container)
				renderTemplateBody = variables.oHomePortalsConfigBean.getRenderTemplateBody("module");
			else
				renderTemplateBody = variables.oHomePortalsConfigBean.getRenderTemplateBody("moduleNoContainer");
				
			renderTemplateBody = replace(renderTemplateBody, "$MODULE_ID$", moduleID, "ALL");
			renderTemplateBody = replace(renderTemplateBody, "$MODULE_TITLE$", arguments.moduleNode.title, "ALL");
			renderTemplateBody = replace(renderTemplateBody, "$MODULE_STYLE$", arguments.moduleNode.style, "ALL");
			renderTemplateBody = replace(renderTemplateBody, "$MODULE_CONTENT$", getpageBuffer("_htmlModule", moduleID),  "ALL");	
			renderTemplateBody = replace(renderTemplateBody, "$MODULE_ICON$", tmpIconURL, "ALL");
		</cfscript>
		<cfreturn renderTemplateBody>
	</cffunction>

	
	<!--------------------------------------->
	<!----  resetPageBuffer				----->
	<!--------------------------------------->
	<cffunction name="resetPageBuffer" access="private" returntype="void" hint="This function resets the generated page contents in the buffer">
		<cfscript>
			variables.pageBuffer = structNew();
			variables.pageBuffer["_htmlHead"] = structNew();
			variables.pageBuffer["_htmlModule"] = structNew();
			variables.lstModulesRender = ""; 		
			variables.loadedModuleClasses = "";		
		</cfscript>
	</cffunction>	
	
	<!--------------------------------------->
	<!----  appendPageBuffer			----->
	<!--------------------------------------->
	<cffunction name="appendPageBuffer" access="private">
		<cfargument name="contentType" required="true">
		<cfargument name="contentKey" required="true" default="">
		<cfargument name="content" required="true">

		<cfset var stTemp = structNew()>
		
		<cfif not structKeyExists(variables.pageBuffer, arguments.contentType)>
			<cfset variables.pageBuffer[arguments.contentType] = structNew()>
		</cfif>
		
		<cfif not structKeyExists(variables.pageBuffer[arguments.contentType], arguments.contentKey)>
			<cfset variables.pageBuffer[arguments.contentType][arguments.contentKey] = arguments.content>
		<cfelse>
			<cfset variables.pageBuffer[arguments.contentType][arguments.contentKey] = variables.pageBuffer[arguments.contentType][arguments.contentKey] & arguments.content>
		</cfif>		
		
	</cffunction>
	
	<!--------------------------------------->
	<!----  getPageBuffer				----->
	<!--------------------------------------->
	<cffunction name="getPageBuffer" access="private" returntype="string">
		<cfargument name="contentType" required="true">
		<cfargument name="contentKey" required="true">
		<cfset var tmpHTML = "">
		<cfif structKeyExists(variables.pageBuffer[arguments.contentType], arguments.contentKey)>
			<cfset tmpHTML = variables.pageBuffer[arguments.contentType][arguments.contentKey]>
		</cfif>
		<cfset tmpHTML = REReplace(tmpHTML, "[[:space:]]{2,}"," ","ALL")>
		<cfreturn tmpHTML>
	</cffunction>

	<!--------------------------------------->
	<!----  getPageBufferByType			----->
	<!--------------------------------------->
	<cffunction name="getPageBufferByType" access="private" returntype="any">
		<cfargument name="contentType" required="true">
		<cfreturn variables.pageBuffer[arguments.contentType]>
	</cffunction>

	<!--------------------------------------->
	<!----  Facades for cf tags			----->
	<!--------------------------------------->
	<cffunction name="include" access="private">
		<cfargument name="template" type="any">
		<cfinclude template="#arguments.template#">
	</cffunction>
					
	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
	</cffunction>

	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>
		
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

	<cffunction name="httpget" access="private" returntype="struct">
		<cfargument name="href" type="string">
		<cfhttp url="#arguments.href#" method="get" throwonerror="true" 
				resolveurl="true" redirect="true" 
				timeout="#variables.HTTP_GET_TIMEOUT#">
		<cfreturn cfhttp>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- readFile		                   --->
	<!---------------------------------------->		
	<cffunction name="readFile" access="private" returntype="string" hint="Reads a file from disk and returns the contents.">
		<cfargument name="filePath" type="string" required="true">
		<cfset var txtDoc = "">
		<cffile action="read" file="#filePath#" variable="txtDoc">
		<cfreturn txtDoc>
	</cffunction>		
	
</cfcomponent>