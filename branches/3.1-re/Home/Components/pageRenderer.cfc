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
		variables.pageURI = "";		// path to the current page
		variables.oHomePortals = 0;		// homeportals instance
		variables.oPage = 0;			// the page to render
		variables.stTimers = structNew();
		
		variables.HTTP_GET_TIMEOUT = 30;	// timeout for HTTP requests in content modules
	</cfscript>

	<!--------------------------------------->
	<!----  init						----->
	<!--------------------------------------->	
	<cffunction name="init" access="public" returntype="pageRenderer" hint="This is the constructor">
		<cfargument name="pageURI" type="string" required="true" hint="The identifier for the page">
		<cfargument name="page" type="pageBean" required="true" hint="The page to render">
		<cfargument name="homePortals" type="homePortals" required="true" hint="HomePortals application instance">
		<cfset var start = getTickCount()>

		<cfset variables.pageURI = arguments.pageURI>
		<cfset variables.oPage = arguments.page>
		<cfset variables.oHomePortals = arguments.homePortals>
		
		<cfset loadPage()>
		
		<cfset variables.stTimers.init = getTickCount()-start>
		<cfreturn this>
	</cffunction>

	<!--------------------------------------->
	<!----  processModules				----->
	<!--------------------------------------->
	<cffunction name="processModules" access="public" output="false" hint="processes all modules rendering its content. Generated content is saved for later.">
		<cfscript>
			var stModules = variables.stPage.page.modules;
			var aModules = arrayNew(1);
			var stModuleNode = structNew();
			var i = 1;
			var j = 1;
			var k = 1;
			var location = "";
			var aLayoutSectionTypes = listToArray( getHomePortals().getConfig().getLayoutSections() );
			var sectionType = "";
			var aSections = 0;
			var start = getTickCount();
			
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

							switch(stModuleNode.moduleType) {
								case "module":	// render normal modules
									processModule(stModuleNode);
									variables.lstModulesRender = listAppend(variables.lstModulesRender, stModuleNode.id);
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
	<cffunction name="renderPage" access="public" output="false" hint="Renders the entire page using the render template." returntype="string">
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
			renderTemplateBody = getHomePortals().getConfig().getRenderTemplateBody("page");

			// replace simple values
			renderTemplateBody = replace(renderTemplateBody, "$PAGE_TITLE$", getPage().getTitle(), "ALL");
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
	<cffunction name="renderLayoutSection" access="public" output="false" returntype="string" hint="Renders all modules in a given layout section. Optionally, the caller can pass the html tag to use to for the layout section.">
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
		<cfset aResourceType = getHomePortals().getConfig().getBaseResourcesByType(arguments.resourceType)>

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
		<cfset var tmpHTML2 = "">
		<cfset var appRoot = getHomePortals().getConfig().getAppRoot()>
		<cfset var resRoot = getHomePortals().getConfig().getResourceLibraryPath()>
		
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
				h_appRoot = "#jsStringFormat(appRoot)#";
				h_pageURI = "#jsStringFormat(variables.pageURI)#";
				
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
	<!----  getBodyOnLoad				----->
	<!--------------------------------------->
	<cffunction name="getBodyOnLoad" access="public" returntype="string" output="false" hint="Returns the javascript statement to run on the onLoad attribute of the body tag">
		<cfreturn getHomePortals().getConfig().getBodyOnLoad()>
	</cffunction>	
	
	<!--------------------------------------->
	<!----  getPageURI					----->
	<!--------------------------------------->
	<cffunction name="getPageURI" access="public" returntype="string" output="false" hint="Returns the location of the page">
		<cfreturn variables.pageURI>
	</cffunction>	

	<!--------------------------------------->
	<!----  getPageHREF					----->
	<!--------------------------------------->
	<cffunction name="getPageHREF" access="public" returntype="string" output="false" hint="Returns the location of the page">
		<cfreturn getPageURI()>
	</cffunction>	
		
	<!--------------------------------------->
	<!----  getPage					----->
	<!--------------------------------------->
	<cffunction name="getPage" access="public" returntype="pageBean" output="false" hint="Returns the current page">
		<cfreturn variables.oPage>
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
			var i = 0;
			var tmrStart = getTickCount();
			var tmp = "";
			var oHPConfig = getHomePortals().getConfig();
			
			var aScriptResources = oHPConfig.getBaseResourcesByType("script");
			var aStyleResources = oHPConfig.getBaseResourcesByType("style");
			var lstLayoutSections = oHPConfig.getLayoutSections();
			
			var oResourceBean = 0;
		
		
			// ****** Parse homePortals page contents ******

			// Structure to hold the page info
			variables.stPage = StructNew();
			variables.stPage.page = StructNew();
			variables.stPage.page.uri = variables.pageURI;			// address of the page
			variables.stPage.page.title = getPage().getTitle();		// page title
			variables.stPage.page.owner = getPage().getOwner();		// the account to which the current page belongs to
			variables.stPage.page.access = getPage().getAccess();	// page access level
			variables.stPage.page.eventListeners = getPage().getEventListeners();
			variables.stPage.page.meta = getPage().getMetaTags();			// holds html meta tags

			variables.stPage.page.stylesheets = ArrayNew(1);	// holds locations of css files
			variables.stPage.page.scripts = ArrayNew(1);		// holds locations of javascript files
			variables.stPage.page.layout = StructNew();			// holds properties for layout sections
			variables.stPage.page.modules = StructNew();		// holds modules
			variables.stPage.page.skinHREF = "";				// holds the location of the page skin
		
		
			// scripts
			for(i=1;i lte ArrayLen(aScriptResources);i=i+1) {
				ArrayAppend(variables.stPage.page.scripts, aScriptResources[i]);
			}
			tmp = getPage().getScripts();
			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				ArrayAppend(variables.stPage.page.scripts, tmp[i]);
			}
			
			
			// styles
			for(i=1;i lte ArrayLen(aStyleResources);i=i+1) {
				ArrayAppend(variables.stPage.page.stylesheets, aStyleResources[i]);
			}
			tmp = getPage().getStylesheets();
			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				ArrayAppend(variables.stPage.page.stylesheets, tmp[i]);
			}


			// layout sections
			for(i=1;i lte ListLen(lstLayoutSections);i=i+1) {
				thisSection = ListGetAt(lstLayoutSections,i);
				variables.stPage.page.layout[thisSection] = ArrayNew(1);
			}
			
			tmp = getPage().getLayoutRegions();

			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				if(listFindNoCase(lstLayoutSections, tmp[i].type))
					ArrayAppend(variables.stPage.page.layout[tmp[i].type], tmp[i] );
			}

			
			// skin
			if(getPage().getSkinID() neq "") {
				oResourceBean = getHomePortals().getCatalog().getResourceNode("skin", getPage().getSkinID());
				variables.stPage.page.skinHREF = oResourceBean.getHref();
			}

			
			
			// modules and content
			tmp = getPage().getModules();
			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				// create structure for modules that belong to the same location
				if(Not StructKeyExists(variables.stPage.page.modules, tmp[i].location) )
					variables.stPage.page.modules[tmp[i].location] = ArrayNew(1);
				
				ArrayAppend(variables.stPage.page.modules[tmp[i].location], tmp[i] );
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
			var start = getTickCount();

			try {
				moduleName = getHomePortals().getConfig().getResourceLibraryPath() & "/Modules/" & moduleName;

				// convert the moduleName into a dot notation path
				moduleName = replace(moduleName,"/",".","ALL");
				moduleName = replace(moduleName,"..",".","ALL");
				if(left(moduleName,1) eq ".") moduleName = right(moduleName, len(moduleName)-1);

				// check if this module is the first of its class to be rendered on the page
				bIsFirstInClass = (Not listFind(variables.loadedModuleClasses, moduleName));
				
				// add information about the page to moduleNode
				arguments.moduleNode["_page"] = structNew();
				arguments.moduleNode["_page"].owner =  variables.stPage.page.owner;
				arguments.moduleNode["_page"].href =  variables.stPage.page.uri;
				
				// instantiate module controller and call constructor
				oModuleController = createObject("component","moduleController");
				oModuleController.init(variables.stPage.page.uri, moduleID, moduleName, arguments.moduleNode, bIsFirstInClass, "local", variables.oHomePortals);

				// render html content
				appendpageBuffer("_htmlHead", moduleID, oModuleController.renderClientInit() );
				appendpageBuffer("_htmlHead", moduleID, oModuleController.renderHTMLHead() );
				appendpageBuffer("_htmlModule", moduleID, oModuleController.renderView() );
				
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
	<!----  processContent				----->
	<!--------------------------------------->
	<cffunction name="processContent" access="private" hint="Retrieves content to display in the page">
		<cfargument name="moduleNode" type="any" required="true">
		<cfscript>
			var moduleID = arguments.moduleNode.id;
			var start = getTickCount();
			var tmpHTML = "";
			var cacheKey = "";
			var oCache = 0;
			
			try {
				if(isBoolean(arguments.moduleNode.cache) and arguments.moduleNode.cache) {
					// get the content cache (this will initialize it, if needed)
					oCache = getContentCache();

					// generate a key for the cache entry
					cacheKey = arguments.moduleNode.resourceID & "/" 
								& arguments.moduleNode.resourceType & "/" 
								& arguments.moduleNode.href;
					
					try {
						// read from cache
						tmpHTML = oCache.retrieve(cacheKey);
					
					} catch(homePortals.cacheService.itemNotFound e) {
						// read from source
						tmpHTML = retrieveContent( arguments.moduleNode );
						
						// update cache
						if(arguments.moduleNode.cacheTTL neq "" and val(arguments.moduleNode.cacheTTL) gte 0)
							oCache.store(cacheKey, tmpHTML, val(arguments.moduleNode.cacheTTL));
						else
							oCache.store(cacheKey, tmpHTML);
					}
					
				} else {
					// retrieve from source
					tmpHTML = retrieveContent( arguments.moduleNode );
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
				renderTemplateBody = getHomePortals().getConfig().getRenderTemplateBody("module");
			else
				renderTemplateBody = getHomePortals().getConfig().getRenderTemplateBody("moduleNoContainer");
				
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

	<!---------------------------------------->
	<!--- getContentCache                  --->
	<!---------------------------------------->		
	<cffunction name="getContentCache" access="private" returntype="cacheService" hint="Retrieves a cacheService instance used for caching content for content modules">
		<cfset var oCacheRegistry = createObject("component","cacheRegistry").init()>
		<cfset var cacheName = "contentCacheService">
		<cfset var oCacheService = 0>
		<cfset var cacheSize = getHomePortals().getConfig().getContentCacheSize()>
		<cfset var cacheTTL = getHomePortals().getConfig().getContentCacheTTL()>

		<cflock type="exclusive" name="contentCacheLock" timeout="30">
			<cfif not oCacheRegistry.isRegistered(cacheName)>
				<!--- crate cache instance --->
				<cfset oCacheService = createObject("component","cacheService").init(cacheSize, cacheTTL)>

				<!--- add cache to registry --->
				<cfset oCacheRegistry.register(cacheName, oCacheService)>
			</cfif>
		</cflock>
		
		<cfreturn oCacheRegistry.getCache(cacheName)>
	</cffunction>
	
	<!---------------------------------------->
	<!--- retrieveContent                  --->
	<!---------------------------------------->		
	<cffunction name="retrieveContent" access="private" returntype="string" hint="retrieves content from source for a content module">
		<cfargument name="moduleNode" type="any" required="true">
		<cfscript>
			var oResourceBean = 0;
			var contentSrc = "";
			var tmpHTML = "";
			var st = structNew();
			var oCatalog = getHomePortals().getCatalog();
			var oHPConfig = getHomePortals().getConfig();
			
			// define source of content (resource or external)
			if(arguments.moduleNode.resourceID neq "") {
				oResourceBean = oCatalog.getResourceNode(arguments.moduleNode.resourceType, arguments.moduleNode.resourceID);
				contentSrc = oHPConfig.getResourceLibraryPath() & "/" & oResourceBean.getHref();
			
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
		</cfscript>
		<cfreturn tmpHTML>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getHomePortals                   --->
	<!---------------------------------------->		
	<cffunction name="getHomePortals" access="private" returntype="homePortals">
		<cfreturn variables.oHomePortals>
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
	
	<cffunction name="readFile" access="private" returntype="string" hint="Reads a file from disk and returns the contents.">
		<cfargument name="filePath" type="string" required="true">
		<cfset var txtDoc = "">
		<cffile action="read" file="#filePath#" variable="txtDoc">
		<cfreturn txtDoc>
	</cffunction>		

</cfcomponent>