<cfcomponent displayname="pageRenderer" hint="This component renders the output of a page">
	
	<cfscript>
		variables.stPage = StructNew();
		variables.lstRenderedContent = ""; 		// list with the order in which the content tags are rendered
		variables.homePortalsEngineDir = "/homePortals/";		// path to location of HomePortals engine
		variables.errorTemplate = variables.homePortalsEngineDir & "/includes/error.cfm";	// template to display when errors occur while rendering page components
		variables.pageHREF = "";		// path to the current page
		variables.oHomePortals = 0;		// homeportals instance
		variables.oPage = 0;			// the page to render
		variables.stTimers = structNew();

		variables.contentBuffer = structNew();	// the content buffers are used to temporarily store the generated output
		variables.contentBuffer.head = 0;
		variables.contentBuffer.body = 0;
		
		variables.context = {};		// the context is a key-value map of values to replace at rendering time on the body section
	</cfscript>

	<!--------------------------------------->
	<!----  init						----->
	<!--------------------------------------->	
	<cffunction name="init" access="public" returntype="pageRenderer" hint="This is the constructor">
		<cfargument name="pageHREF" type="string" required="true" hint="The identifier for the page">
		<cfargument name="page" type="pageBean" required="true" hint="The page to render">
		<cfargument name="homePortals" type="homePortals" required="true" hint="HomePortals application instance">
		<cfset var start = getTickCount()>

		<cfset variables.pageHREF = arguments.pageHREF>
		<cfset variables.oPage = arguments.page>
		<cfset variables.oHomePortals = arguments.homePortals>
		
		<cfset resetPageContentBuffer()>
		<cfset initPageStruct()>
		<cfset loadPage(arguments.pageHREF, arguments.page)>
		<cfset injectGlobalPageProperties()>
		
		<cfset variables.stTimers.init = getTickCount()-start>
		<cfreturn this>
	</cffunction>

	<!--------------------------------------->
	<!----  renderPage					----->
	<!--------------------------------------->
	<cffunction name="renderPage" access="public" output="false" hint="Renders the entire page using the render template." returntype="string">
		<cfargument name="context" type="struct" required="false" hint="The context object" default="#structNew()#">
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
			var pageTemplate = variables.stPage.page.pageTemplate;

			// store the context object
			if(not structIsEmpty(arguments.context)) {
				// make sure we cleanup the context for html sneakyness!!
				for(arg1 in arguments.context) {
					if(isSimpleValue(arguments.context[arg1])) {
						arguments.context[arg1] = reReplace(arguments.context[arg1],"<[^>]*>","","ALL");
					}
				}
				variables.context = arguments.context;
			}

			// pre-render output of all content tags on page		
			processContentTags();

			// get the render template for the full page
			renderTemplateBody = getHomePortals().getTemplateManager().getTemplateBody("page", pageTemplate);

			// replace page title
			tmp = htmlEditFormat(variables.stPage.page.title);
			renderTemplateBody = replace(renderTemplateBody, "$PAGE_TITLE$", resolveContextTokens(tmp), "ALL");

			// replace simple values
			renderTemplateBody = replace(renderTemplateBody, "$PAGE_HTMLHEAD$", renderHTMLHeadCode(), "ALL");

			// search and replace "Page Properties"
			index = 1;
			finished = false;
			while(Not finished) {
				stResult = reFindNoCase("\$PAGE_PROPERTY\[""([A-Za-z0-9_]*)""\]\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					rendered = resolveContextTokens("{" & arg1 & "}");;
					renderTemplateBody = replace(renderTemplateBody, token, rendered, "ALL");
					
					index = stResult.pos[1] + len(rendered);
				} else {
					finished = true;
				}
			}

			// search and replace "Custom Sections"
			index = 1;
			finished = false;
			while(Not finished) {
				stResult = reFindNoCase("\$PAGE_CUSTOMSECTION\[""([A-Za-z0-9_]*)""]\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					rendered = renderCustomSection(arg1);
					
					renderTemplateBody = replace(renderTemplateBody, token, rendered, "ALL");
					
					index = stResult.pos[1] + len(rendered);
				} else {
					finished = true;
				}
			}
			
			// search and replace "Layout Sections"
			index = 1;
			finished = false;
			while(Not finished) {
				stResult = reFindNoCase("\$PAGE_LAYOUTSECTION\[""([A-Za-z0-9_]*)""\]\[""([A-Za-z0-9_]*)""\]\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					arg2 = mid(renderTemplateBody,stResult.pos[3],stResult.len[3]);
					rendered = renderLayoutSection(arg1, arg2);
						
					renderTemplateBody = replace(renderTemplateBody, token, rendered, "ALL");
					
					index = stResult.pos[1] + len(rendered);
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
		<cfset var aLocations = ArrayNew(1)>
		<cfset var stModuleNode = structNew()>
		
		<cfset var tmpHTML = "">

		<cfif structKeyExists(variables.stPage.page.layout, arguments.layoutSection)>
			<cfset aLocations = variables.stPage.page.layout[arguments.layoutSection]>
		</cfif>

		<!--- Loop through each section --->
		<cfloop from="1" to="#ArrayLen(aLocations)#" index="i">
			<cfif arguments.TagName neq "">
				<cfset tmpHTML = tmpHTML & "<#arguments.TagName#">
				<cfif aLocations[i].Class neq "">
					<cfset tmpHTML = tmpHTML & " class=""#aLocations[i].class#""">
				</cfif>
				<cfif aLocations[i].Style neq "">
					<cfset tmpHTML = tmpHTML & " style=""#aLocations[i].style#""">
				</cfif>
				<cfif aLocations[i].id neq "">
					<cfset tmpHTML = tmpHTML & " id=""#aLocations[i].id#""">
				</cfif>
				<cfset tmpHTML = tmpHTML & ">">
			</cfif>
			
			<cfif StructKeyExists(variables.stPage.page.modules, aLocations[i].name)>
				<!--- Display all modules within this section --->
				<cfset aModules = variables.stPage.page.modules[aLocations[i].name]>
				<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
					<cfset stModuleNode = variables.stPage.page.modules[aLocations[i].name][j]>
					<cfif stModuleNode.getOutput()>
						<cfset tmpHTML = tmpHTML & renderContentTag(stModuleNode)>
					</cfif>
				</cfloop>
			</cfif>
			
			<cfif arguments.TagName neq "">
				<cfset tmpHTML = tmpHTML & "</#arguments.TagName#>">
			</cfif>
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
					<cfinclude template="#normalizePath(aResourceType[i])#">
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
	<cffunction name="renderHTMLHeadCode" access="public" returntype="string" output="false" hint="Returns the HTML code that should go in the head section of the document">
		<cfset var i = 0>
		<cfset var aStylesheets = variables.stPage.page.stylesheets>
		<cfset var aScripts = variables.stPage.page.scripts>
		<cfset var aMeta = variables.stPage.page.meta>
		<cfset var moduleID = "">
		<cfset var tmpHTML = "">
		
		<!--- Add user-defined meta tags --->
		<cfloop from="1" to="#ArrayLen(aMeta)#" index="i">
			<cfif aMeta[i].name eq "RSS">
				<cfif listLen(aMeta[i].content,"|") eq 2>
					<cfset tmpHTML = tmpHTML & "<link rel=""alternate"" type=""application/rss+xml"" title=""#listFirst(aMeta[i].content,"|")#"" href=""#listLast(aMeta[i].content,"|")#"" />">
				<cfelse>
					<cfset tmpHTML = tmpHTML & "<link rel=""alternate"" type=""application/rss+xml"" href=""#aMeta[i].content#"" />">
				</cfif>
			<cfelse>
				<cfset tmpHTML = tmpHTML & "<meta name=""#aMeta[i].name#"" content=""#htmlEditFormat(aMeta[i].content)#"" />">
			</cfif>
		</cfloop>
			
		<!--- Include basic and user-defined CSS styles --->
		<cfloop from="1" to="#ArrayLen(aStylesheets)#" index="i">
			<cfif structKeyExists(variables.stPage.page.stylesheetBlocks, aStylesheets[i])>
				<cfset tmpHTML = tmpHTML & "<style type=""text/css"">" & variables.stPage.page.stylesheetBlocks[aStylesheets[i]] & "</style>">">
			<cfelse>
				<cfset tmpHTML = tmpHTML & "<link rel=""stylesheet"" type=""text/css"" href=""#normalizePath(aStylesheets[i])#""/>">
			</cfif>
		</cfloop>
				
		<!--- Include required and user-defined Javascript files --->
		<cfloop from="1" to="#ArrayLen(aScripts)#" index="i">
			<cfif structKeyExists(variables.stPage.page.scriptBlocks, aScripts[i])>
				<cfset tmpHTML = tmpHTML & "<script type=""text/javascript"">" & variables.stPage.page.scriptBlocks[aScripts[i]] & "</script>">">
			<cfelse>
				<cfset tmpHTML = tmpHTML & "<script src=""#normalizePath(aScripts[i])#"" type=""text/javascript""></script>">
			</cfif>
		</cfloop>
		
		<!--- Add html head code rendered by content tags --->
		<cfloop list="#variables.lstRenderedContent#" index="moduleID">
			<cfif variables.contentBuffer.head.containsID(moduleID)>
				<cfset tmpHTML = tmpHTML & trim(variables.contentBuffer.head.get(moduleID))>
			</cfif>
		</cfloop>

		<!--- Render pre-defined custom section for HTML Head code --->
		<cfset tmpHTML = tmpHTML & renderCustomSection("HTMLHEAD")>

		 <!--- 
		 	Remove all whitespace from HEAD code
		 	(for now is commented out because this can create problems with some JavaScript files)
		 	<cfset tmpHTML = REReplace(tmpHTML, "[[:space:]]{2,}","","ALL")> 
		 --->
		 
		<cfreturn tmpHTML>
	</cffunction>
		
	<!--------------------------------------->
	<!----  getPageHREF					----->
	<!--------------------------------------->
	<cffunction name="getPageHREF" access="public" returntype="string" output="false" hint="Returns the location of the page">
		<cfreturn variables.pageHREF>
	</cffunction>	
		
	<!--------------------------------------->
	<!----  getPage					----->
	<!--------------------------------------->
	<cffunction name="getPage" access="public" returntype="pageBean" output="false" hint="Returns the current page">
		<cfreturn variables.oPage>
	</cffunction>
	
	<!---------------------------------------->
	<!--- getHomePortals                   --->
	<!---------------------------------------->		
	<cffunction name="getHomePortals" access="public" returntype="homePortals">
		<cfreturn variables.oHomePortals>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- getTimers						   --->
	<!---------------------------------------->	
	<cffunction name="getTimers" access="public" returntype="any" hint="Returns the timers for this object">
		<cfreturn variables.stTimers>
	</cffunction>	

	<!---------------------------------------->
	<!--- getParsedPageData				   --->
	<!---------------------------------------->	
	<cffunction name="getParsedPageData" access="public" returntype="struct" hint="This function returns the page contents after the page bean has been parsed. This allows clients to do low level modifications to the page structure without affecting the original page bean">
		<cfreturn variables.stPage.page>
	</cffunction>	

	<!---------------------------------------->
	<!--- getContext					   --->
	<!---------------------------------------->	
	<cffunction name="getContext" access="public" returntype="struct" hint="This function returns the context object for this renderer">
		<cfreturn variables.context>
	</cffunction>	

	<!---------------------------------------->
	<!--- setContext					   --->
	<!---------------------------------------->	
	<cffunction name="setContext" access="public" returntype="void" hint="This function sets the context object for this renderer">
		<cfargument name="pageContext" type="struct" required="true">
		<cfset variables.context = pageContext>
	</cffunction>	
		
	
	<!----------  P R I V A T E    M E T H O D S    ----------------->

	<!--------------------------------------->
	<!----  initPageStruct				----->
	<!--------------------------------------->
	<cffunction name="initPageStruct" access="private" returntype="void" hint="initializes the struct where we will collect the page data">
		<cfscript>
			variables.stPage = StructNew();
			variables.stPage.page = StructNew();
			variables.stPage.page.href = "";			// address of the page
			variables.stPage.page.title = "";		// page title
			variables.stPage.page.pageTemplate = "";		// page title
			variables.stPage.page.meta = arrayNew(1);			// holds html meta tags

			variables.stPage.page.stylesheets = ArrayNew(1);	// holds locations of css files
			variables.stPage.page.stylesheetBlocks = StructNew();	// holds locations of css code blocks
			variables.stPage.page.scripts = ArrayNew(1);		// holds locations of javascript files
			variables.stPage.page.scriptBlocks = StructNew();	// holds locations of js code blocks
			variables.stPage.page.layout = StructNew();			// holds properties for layout sections
			variables.stPage.page.modules = StructNew();		// holds modules
		</cfscript>
	</cffunction>
	
	<!--------------------------------------->
	<!----  loadPage					----->
	<!--------------------------------------->
	<cffunction name="loadPage" access="private" returntype="void" hint="loads and parses a homeportals page">
		<cfargument name="pageHREF" type="string" required="true" hint="The identifier for the page">
		<cfargument name="page" type="pageBean" required="true" hint="The page to render">
		<cfargument name="isParent" type="boolean" required="false" default="false">
		<cfscript>
			var i = 0;
			var tmrStart = getTickCount();
			var tmp = ""; var tmpLoc = "";
			var oHPConfig = getHomePortals().getConfig();
			
			var aScriptResources = oHPConfig.getBaseResourcesByType("script");
			var aStyleResources = oHPConfig.getBaseResourcesByType("style");
			
			var oResourceBean = 0;
			var parentPageHREF = "";
		
		
			// ****** Parse homePortals page contents ******

			// if this page extends another, then parse the parent first
			if(arguments.page.hasProperty("extends")) {
				parentPageHREF = arguments.page.getProperty("extends");
				if(parentPageHREF neq "" and parentPageHREF neq arguments.pageHREF) {
					loadPage(parentPageHREF,
							getHomePortals().getPageLoader().load(parentPageHREF),
							true);
				}
			} 

			// Structure to hold the page info
			variables.stPage.page.href = arguments.pageHREF;			// address of the page
			if(arguments.page.getTitle() neq "")
				variables.stPage.page.title = arguments.page.getTitle();		// page title
			if(arguments.page.getPageTemplate() neq "")
				variables.stPage.page.pageTemplate = arguments.page.getPageTemplate();		// page template

			variables.stPage.page.meta.addAll(arguments.page.getMetaTags());			// holds html meta tags

			// scripts
			for(i=1;i lte ArrayLen(aScriptResources);i=i+1) {
				if(not variables.stPage.page.scripts.contains( aScriptResources[i] )) {
					ArrayAppend(variables.stPage.page.scripts, aScriptResources[i]);
				}
			}
			tmp = arguments.page.getScripts();
			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				if(arguments.page.getScriptBlock(tmp[i]) neq "") {
					ArrayAppend(variables.stPage.page.scripts, tmp[i]);
					variables.stPage.page.scriptBlocks[tmp[i]] = arguments.page.getScriptBlock(tmp[i]);
				} else if(not variables.stPage.page.scripts.contains( tmp[i] )) {
					ArrayAppend(variables.stPage.page.scripts, tmp[i]);
				}
			}
			
			
			// styles
			for(i=1;i lte ArrayLen(aStyleResources);i=i+1) {
				if(not variables.stPage.page.stylesheets.contains( aStyleResources[i] )) {
					ArrayAppend(variables.stPage.page.stylesheets, aStyleResources[i]);
				}
			}
			tmp = arguments.page.getStylesheets();
			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				if(arguments.page.getStylesheetBlock(tmp[i]) neq "") {
					ArrayAppend(variables.stPage.page.stylesheets, tmp[i]);
					variables.stPage.page.stylesheetBlocks[tmp[i]] = arguments.page.getStylesheetBlock(tmp[i]);
				} else if(not variables.stPage.page.stylesheets.contains( tmp[i] )) {
					ArrayAppend(variables.stPage.page.stylesheets, tmp[i]);
				}
			}


			// layout sections
			tmp = arguments.page.getLayoutRegions();
			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				if(not structKeyExists(variables.stPage.page.layout, tmp[i].type))
					variables.stPage.page.layout[tmp[i].type] = ArrayNew(1);
				ArrayAppend(variables.stPage.page.layout[tmp[i].type], tmp[i] );
			}

						
			// modules and content
			tmp = arguments.page.getModules();
			for(i=1;i lte ArrayLen(tmp);i=i+1) {
				// create structure for modules that belong to the same location
				tmpLoc = tmp[i].getLocation();
				
				// if location is empty, default to first available
				if(tmpLoc eq "") {
					tmp2 = arguments.page.getLayoutRegions();
					if(arrayLen(tmp2) gt 0)
						tmpLoc = tmp2[1].name;
					else {
						tmp2 = getHomePortals().getTemplateManager().getLayoutSections( variables.stPage.page.pageTemplate );
						tmpLoc = listFirst(tmp2);
					}
				}
				
				if(Not StructKeyExists(variables.stPage.page.modules, tmpLoc) )
					variables.stPage.page.modules[tmpLoc] = ArrayNew(1);
				
				ArrayAppend(variables.stPage.page.modules[tmpLoc], tmp[i] );
			}
			
			
			// if no explicit layout is given, then create a layout based on the page template
			if(!arguments.isParent and structIsEmpty(variables.stPage.page.layout)) {
				tmp = getHomePortals().getTemplateManager().getLayoutSections( variables.stPage.page.pageTemplate );
				tmp = listToArray(tmp);
				for(i=1;i lte ArrayLen(tmp);i=i+1) {
					st = {
						type = tmp[i],
						id = tmp[i],
						class = "",
						style = "",
						name = tmp[i]
					};
					if(not structKeyExists(variables.stPage.page.layout, st.type))
						variables.stPage.page.layout[st.type] = ArrayNew(1);
					ArrayAppend(variables.stPage.page.layout[st.type], st );
				}
			}
		</cfscript>	
	</cffunction>
	
	<!--------------------------------------->
	<!----  processContentTags			----->
	<!--------------------------------------->
	<cffunction name="processContentTags" access="private" output="false" hint="processes all content tags rendering its content. Generated content is saved for later.">
		<cfscript>
			var stTags = variables.stPage.page.modules;
			var aTags = arrayNew(1);
			var stTageNode = structNew();
			var i = 1;
			var j = 1;
			var k = 1;
			var location = "";
			var aLayoutSectionTypes = listToArray( structKeyList(variables.stPage.page.layout) );
			var sectionType = "";
			var aSections = 0;
			var start = getTickCount();
			var startTag = 0;
			var props = structNew();
			var prop = "";
			var token = "";
			var stResult = "";
			var errorContentBuffer = 0;
			var errorHandlerClass = getHomePortals().getConfig().getErrorHandlerClass();
			
			// reset the content output buffer
			resetPageContentBuffer();

			// loop through the section types in render order
			for(i=1;i lte ArrayLen(aLayoutSectionTypes);i=i+1) {
				sectionType = aLayoutSectionTypes[i];
				aSections = variables.stPage.page.layout[sectionType];
				
				// loop through all locations in this section type
				for(j=1;j lte ArrayLen(aSections);j=j+1) {
					location = aSections[j].name;

					if(structKeyExists(stTags,location)) {
						aTags = stTags[location];
						
						// loop through all modules in this location
						for(k=1;k lte arrayLen(aTags);k=k+1) {
							oModBean = stTags[location][k];
							stTagNode = oModBean.getMemento();
							startTag = getTickCount();

							try {
								// do dynamic replacement of properties from the context object
								props = oModBean.getProperties();
								for(prop in props) {
									tmp = resolveContextTokens( props[prop] );
									if(tmp eq "")
										oModBean.removeProperty(prop);
									else
										oModBean.setProperty(prop, tmp);
								}

								// apply context to title
								oModBean.setTitle( resolveContextTokens( oModBean.getTitle() ) );
								 
								// process module content
								oContentTagRenderer = getContentTagRenderer(stTagNode.moduleType, oModBean);
								oContentTagRenderer.renderContent(createObject("component","singleContentBuffer").init(stTagNode.id, variables.contentBuffer.head),
																	createObject("component","singleContentBuffer").init(stTagNode.id, variables.contentBuffer.body)
																);
							} catch(any e) {
								// handle error
								errorContentBuffer = createObject("component","singleContentBuffer").init(stTagNode.id, variables.contentBuffer.body);
								
								if(errorHandlerClass neq "")
									createObject("component",errorHandlerClass).onContentRendererError(getHomePortals(), this, oModBean, errorContentBuffer, e);
								else
									errorContentBuffer.set(e.message & e.detail);
							}

							// keep an ordered list with all content tags rendered
							variables.lstRenderedContent = listAppend(variables.lstRenderedContent, stTagNode.id);
							
							// record time
							variables.stTimers[stTagNode.moduleType & "_" & stTagNode.id] = getTickCount()-startTag;
						}
					}
				}
			}
			
			variables.stTimers.processModules = getTickCount()-start;
		</cfscript>
	</cffunction>	
	
	<!--------------------------------------->
	<!----  renderContentTag			----->
	<!--------------------------------------->
	<cffunction name="renderContentTag" access="private" returntype="string" hint="Initializes and renders a content tag instance." output="false">
		<cfargument name="contentTagNode" type="moduleBean" required="true">
		<cfscript>
			var id = arguments.contentTagNode.getID();
			var stNodeData = arguments.contentTagNode.getMemento();
			var renderTemplateBody = "";
			var renderTemplate = "";
			var tmpIconURL = "";
			var tm = getHomePortals().getTemplateManager();
			var index = 1;
			var finished = false;
			var stResult = 0;
			var token = "";
			var arg1 = "";
			var rendered = "";

			if(stNodeData.icon neq "") 
				tmpIconURL = "<img src='#stNodeData.icon#' width='16' height='16' align='absmiddle'>";

			// if moduleTemplate is defined, then use that for the name of the render template,
			// otherwise fall into the container property
			if(stNodeData.moduleTemplate neq "") {
				renderTemplate = stNodeData.moduleTemplate;
			} else {
				if(stNodeData.Container)
					renderTemplate = "";	// this will force the template manager to use the default template
				else
					renderTemplate = "moduleNoContainer";
			}
				
			// get template source
			renderTemplateBody = tm.getTemplateBody("module",renderTemplate);	

			// replace module icon token
			renderTemplateBody = replace(renderTemplateBody, "$MODULE_ICON$", tmpIconURL, "ALL");

			// search and replace generic module attributes
			index = 1;
			finished = false;
			while(Not finished) {
				stResult = reFindNoCase("\$MODULE_([A-Za-z0-9_]*)\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					rendered = "";
					
					if(arg1 neq "CONTENT") {
						if(structKeyExists(stNodeData,arg1) and isSimpleValue(stNodeData[arg1])) {
							rendered = stNodeData[arg1];
						
						} else if(arguments.contentTagNode.hasProperty(arg1)) {
							rendered = arguments.contentTagNode.getProperty(arg1);
						}
							
						renderTemplateBody = replace(renderTemplateBody, token, rendered, "ALL");
						index = stResult.pos[1] + len(rendered);
					} else {
						index = stResult.pos[1] + stResult.len[1];
					}
					
				} else {
					finished = true;
				}
			}
			
			// search and replace "Page Properties"
			index = 1;
			finished = false;
			while(Not finished) {
				stResult = reFindNoCase("\$PAGE_PROPERTY\[""([A-Za-z0-9_]*)""\]\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					rendered = "";
					
					if(getPage().hasProperty(arg1)) {
						rendered = getPage().getProperty(arg1);
					}
						
					renderTemplateBody = replace(renderTemplateBody, token, rendered, "ALL");
					
					index = stResult.pos[1] + len(rendered);
				} else {
					finished = true;
				}
			}
			
			// replace content token
			renderTemplateBody = replace(renderTemplateBody, "$MODULE_CONTENT$", variables.contentBuffer.body.get(id),  "ALL");	
		</cfscript>
		<cfreturn renderTemplateBody>
	</cffunction>
	
	<!--------------------------------------->
	<!----  resetPageContentBuffer		----->
	<!--------------------------------------->
	<cffunction name="resetPageContentBuffer" access="private" returntype="void" hint="This function resets the generated page contents in the buffer">
		<cfscript>
			variables.contentBuffer.head = createObject("component","contentBuffer").init();
			variables.contentBuffer.body = createObject("component","contentBuffer").init();
			variables.lstRenderedContent = ""; 		
		</cfscript>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- getContentTagRenderer            --->
	<!---------------------------------------->		
	<cffunction name="getContentTagRenderer" access="private" returntype="contentTagRenderer">
		<cfargument name="contentTagType" type="string" required="true">
		<cfargument name="moduleBean" type="moduleBean" required="true">
		<cfscript>
			var oContentTag = createObject("component", "contentTag").init(arguments.moduleBean);
			var contentTagRendererClassName = getHomePortals().getConfig().getContentRenderer( arguments.contentTagType );
			var oContentTagRenderer = createObject("component", normalizeContentTagRendererPath(contentTagRendererClassName) ).init(this, oContentTag);
			return oContentTagRenderer;
		</cfscript>
	</cffunction>

	<!---------------------------------------->
	<!--- injectGlobalPageProperties       --->
	<!---------------------------------------->		
	<cffunction name="injectGlobalPageProperties" access="private" returntype="void">
		<cfscript>
			var stGlobalProps = getHomePortals().getConfig().getPageProperties();
			var p = "";
			
			for(p in stGlobalProps) {
				if(not variables.oPage.hasProperty(p)) {
					variables.oPage.setProperty(p, stGlobalProps[p], true);
				}
			}
		</cfscript>
	</cffunction>
	
	<!---------------------------------------->
	<!--- resolveContextTokens		       --->
	<!---------------------------------------->		
	<cffunction name="resolveContextTokens" access="private" returntype="string">
		<cfargument name="text" type="string" required="true">
		<cfscript>
			var token = "";
			var arg1 = "";
			var stResult = {};
			var rtn = arguments.text;
			var index = 1;
			var finished = false;
			var rendered = "";

			while(Not finished) {
				stResult = reFindNoCase("\$?{([A-Za-z0-9_]*)}",rtn,index,true);
	
				if(stResult.len[1] gt 0) {
					token = mid(rtn,stResult.pos[1],stResult.len[1]);
					arg1 = mid(rtn,stResult.pos[2],stResult.len[2]);
					rendered = "";

					if(left(token,1) neq "$" and structKeyExists(variables.context,arg1)) {
						rendered = variables.context[arg1];
					} else if(getPage().hasProperty(arg1)) {
						rendered = getPage().getProperty(arg1);
					}

					rtn = replace(rtn, token, rendered, "ALL");
					
					index = stResult.pos[1] + len(rendered);
				} else {
					finished = true;
				}
			}

			return rtn;
		</cfscript>
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

	<cffunction name="normalizeContentTagRendererPath" access="private">
		<cfargument name="path" type="string" required="true">
		<cfif left(arguments.path,1) eq ".">
			<cfset arguments.path = getHomePortals().getConfig().getAppRoot() & arguments.path>
			<cfset arguments.path = replace(arguments.path,"/",".","ALL")>
			<cfset arguments.path = replace(arguments.path,"..",".","ALL")>
			<cfif left(arguments.path,1) eq "/" or left(arguments.path,1) eq ".">
				<cfset arguments.path = right(arguments.path,len(arguments.path)-1)>
			</cfif>
		</cfif>
		<cfreturn arguments.path />
	</cffunction>

	<cffunction name="normalizePath" access="private">
		<cfargument name="path" type="string" required="true">
		<cfif left(arguments.path,1) neq "/" and not find("://",arguments.path)>
			<cfreturn getHomePortals().getConfig().getAppRoot() & arguments.path>
		</cfif>
		<cfreturn arguments.path />
	</cffunction>


</cfcomponent>