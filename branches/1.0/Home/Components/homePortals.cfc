<cfcomponent output="false">
	
	<cfscript>
		variables.stConfig = StructNew();		// HomePortals server-wide settings
		variables.stPage = StructNew();			// Current HomePortals page
		variables.stTimers = StructNew();		// Timers for debug
		variables.isHTTPS = false;				// flag to determine whether current request is made through https
		variables.loadedModuleClasses = "";		// this is a list of all module classes loaded in the current page
		variables.pageContent = structNew();
		variables.pageContent["_htmlHead"] = structNew();
		variables.pageContent["_htmlModule"] = structNew();
	</cfscript>
	
	<!--------------------------------------->
	<!----  init	 					----->
	<!--------------------------------------->
	<cffunction name="init" access="public" returntype="homePortals" hint="Constructor">
		<cfargument name="reloadConfig" type="boolean" required="false" default="false" hint="Flag to force a reload of the HomePortals settings">
		<cfargument name="homePath" type="string" required="false" default="" hint="Relative path to HomePortals root">
		<cfargument name="isHTTPS" type="boolean" required="false" default="false" hint="Indicates if current page is loaded using HTTPS protocol">
		<cfscript>
			var stSettings = structNew();
			
			if(not structKeyExists(application, "HomeSettings") or arguments.reloadConfig) {
				
				// initialize local vars
				variables.errorTemplate = arguments.homePath & "Common/Templates/error.cfm";
				variables.configFilePath = arguments.homePath & "Config/homePortals-config.xml";
				variables.isHTTPS = arguments.isHTTPS;

				// read the config file 
				loadConfig();	

				// store the config settings on the application scope
				application.HomeSettings = getConfig();
				application.HomeSettings.isHTTPS = arguments.isHTTPS;
			} else {
				// restore application settings
				stSettings = application.HomeSettings;
				setConfig(stSettings);
		
				variables.errorTemplate = variables.stConfig.homePortalsPath & "Common/Templates/error.cfm";
				variables.configFilePath = variables.stConfig.homePortalsPath & "Config/homePortals-config.xml";
				variables.isHTTPS = application.HomeSettings.isHTTPS;
			}
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	
	
	<!--------------------------------------->
	<!----  loadConfig / saveConfig		----->
	<!--------------------------------------->
	<cffunction name="loadConfig" access="public" hint="Loads the configuration settings for the entire HomePortals server">
		<cfscript>
			var tmpXML = "";
			var xmlConfigDoc = 0;
			var i = 0;
			var j = 0;
			var xmlNode = 0;
			var xmlThisNode = 0;
			var tmrStart = getTickCount();
		
			// ***** Get homeportals configuration ******
			xmlConfigDoc = readFile(variables.configFilePath);

			variables.stConfig = structNew();
			variables.stConfig.version = "";
			variables.stConfig.initialEvent = "";
			variables.stConfig.layoutSections = "";
			variables.stConfig.defaultPage = "";
			variables.stConfig.bodyOnLoad = "";
			variables.stConfig.homePortalsPath = "";
			variables.stConfig.moduleLibraryPath = "";
			variables.stConfig.adminEmail = "";
			variables.stConfig.resources = structNew();
			variables.stConfig.resources.script = ArrayNew(1);
			variables.stConfig.resources.style = ArrayNew(1);
			variables.stConfig.resources.header = ArrayNew(1);
			variables.stConfig.resources.footer = ArrayNew(1);
			variables.stConfig.moduleIcons = ArrayNew(1);
			variables.stConfig.SSLRoot = "";
			
			for(i=1;i lte ArrayLen(xmlConfigDoc.xmlRoot.xmlChildren);i=i+1) {
			
				// get poiner to current node
				xmlNode = xmlConfigDoc.xmlRoot.xmlChildren[i];
				
				if(xmlNode.xmlName eq "baseResources") {
				
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						xmlThisNode = xmlNode.xmlChildren[j];
						if(Not structKeyExists(variables.stConfig.resources, xmlThisNode.xmlAttributes.type)) 
							variables.stConfig.resources[xmlThisNode.xmlAttributes.type] = ArrayNew(1);
						ArrayAppend(variables.stConfig.resources[xmlThisNode.xmlAttributes.type], xmlThisNode.xmlAttributes.href);
						
					}
		
				} else if(xmlNode.xmlName eq "moduleIcons") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						ArrayAppend(variables.stConfig.moduleIcons, duplicate(xmlNode.xmlChildren[j].xmlAttributes) );
					}
							
				} else
					variables.stConfig[xmlNode.xmlName] = xmlNode.xmlText;
				
			}
		
			// set initial javascript event
			if(ListLen(variables.stConfig.initialEvent,".") eq 2)
				variables.stConfig.bodyOnLoad = "h_raiseEvent('#ListFirst(variables.stConfig.initialEvent,".")#', '#ListLast(variables.stConfig.initialEvent,".")#')";
		
			variables.stTimers["LOAD CONFIG"] = getTickCount()-tmrStart;
		</cfscript>
	</cffunction>

	<cffunction name="saveConfig" access="public" hint="Saves the configuration settings for the entire HomePortals server">
		<cfscript>
			var xmlConfigDoc = "";
			var xmlOriginalConfigDoc = "";
			var backupFileName = "";
			var lstResourceTypes = "script,style,header,footer";
			var lstKeys = "";
			var i = 1;
			var j = 1;
			var thisKey = "";
			var thisResourceType = "";
			var tmpIndex = 1;

			// ***** Get homeportals configuration ******
			xmlConfigDoc = xmlParse(variables.configFilePath);		
			xmlOriginalConfigDoc = xmlParse(variables.configFilePath);		
			
			// define name for backup file
			backupFileName = ReplaceNoCase(variables.configFilePath,".xml",".bak");
			
			// save simple value settings
			lstKeys = "initialEvent,layoutSections,defaultPage,homePortalsPath,moduleLibraryPath,SSLRoot,adminEmail";
			for(i=1;i lte ListLen(lstKeys);i=i+1) {
				thisKey = ListGetAt(lstKeys,i);

				if(StructKeyExists(xmlConfigDoc.xmlRoot,thisKey))  {
					xmlConfigDoc.xmlRoot[thisKey].xmlText = variables.stConfig[thisKey];
				} else
					throw("#thisKey# does not exist");
			}
			
			// ****** save resources *****
			
			// create baseResources section if does not exist
			if(not StructKeyExists(xmlConfigDoc.xmlRoot,"baseResources"))
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"baseResources") );
			
			// clear existing base resources
			ArrayClear(xmlConfigDoc.xmlRoot.baseResources.xmlChildren);
	
			// insert new resources
			for(i=1;i lte ListLen(lstResourceTypes);i=i+1) {
				thisResourceType = ListGetAt(lstResourceTypes, i);
				
				for(j=1;j lte ArrayLen(variables.stConfig.resources[thisResourceType]);j=j+1) {
					ArrayAppend(xmlConfigDoc.xmlRoot.baseResources.xmlChildren, xmlElemNew(xmlConfigDoc,"resource") );
					tmpIndex = ArrayLen(xmlConfigDoc.xmlRoot.baseResources.xmlChildren);
					xmlConfigDoc.xmlRoot.baseResources.xmlChildren[tmpIndex].xmlAttributes["href"] = variables.stConfig.resources[thisResourceType][j];
					xmlConfigDoc.xmlRoot.baseResources.xmlChildren[tmpIndex].xmlAttributes["type"] = thisResourceType;
				}		

			}
			
			// ***** save module icons *****
			// create moduleIcons section if does not exist
			if(not StructKeyExists(xmlConfigDoc.xmlRoot,"moduleIcons"))
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"moduleIcons") );
			
			// clear existing icons
			ArrayClear(xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren);
	
			// insert new icons
			for(i=1;i lte ArrayLen(variables.stConfig.moduleIcons);i=i+1) {
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i] = xmlElemNew(xmlConfigDoc,"icon");
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i].xmlAttributes["alt"] = variables.stConfig.moduleIcons[i].alt;
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i].xmlAttributes["image"] = variables.stConfig.moduleIcons[i].image;
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i].xmlAttributes["onClickFunction"] = variables.stConfig.moduleIcons[i].onClickFunction;
			}		
		</cfscript>		
		
		<!--- store page --->
		<cffile action="write" file="#variables.configFilePath#" output="#toString(xmlConfigDoc)#">

		<!--- store backup --->
		<cffile action="write" file="#backupFileName#" output="#toString(xmlOriginalConfigDoc)#">

	</cffunction>
		
	

	<!--------------------------------------->
	<!----  loadPage 					----->
	<!--------------------------------------->
	<cffunction name="loadPage" access="public" hint="Loads and parses a HomePortals page">
		<cfargument name="href" type="string" required="yes">
		
		<cfscript>
			var tmpXML = "";
			var xmlDoc = "";
			var i = 0;
			var j = 0;
			var xmlNode = 0;
			var xmlThisNode = 0;
			var tmrStart = getTickCount();
		
			// check if we are on HTTPS and if we need to modify the root
			if(variables.isHTTPS and left(arguments.href,1) eq "/")
				arguments.href = variables.stConfig.SSLRoot & arguments.href;
		
			// ****** Get homePortals page ******
			xmlDoc = readFile(arguments.href);
		
			// ****** Parse homePortals page contents ******
			// Structure to hold the page info
			variables.stPage = StructNew();
			variables.stPage.href = arguments.href;
			variables.stPage.xml = toString(xmlDoc);		
			variables.stPage.page = StructNew();
			variables.stPage.page.title = "";
			variables.stPage.page.basePath = "";
			variables.stPage.page.stylesheets = ArrayNew(1);
			variables.stPage.page.scripts = ArrayNew(1);
			variables.stPage.page.eventListeners = ArrayNew(1);
			variables.stPage.page.layout = StructNew();		// holds properties for layout sections
			variables.stPage.page.modules = StructNew();		// holds modules
		
		
			// add base resources
			for(i=1;i lte ArrayLen(variables.stConfig.resources.script);i=i+1) {
				ArrayAppend(variables.stPage.page.scripts, variables.stConfig.resources.script[i]);
			}
			for(i=1;i lte ArrayLen(variables.stConfig.resources.style);i=i+1) {
				ArrayAppend(variables.stPage.page.stylesheets, variables.stConfig.resources.style[i]);
			}
	
			// set placeholders for layout sections
			for(i=1;i lte ListLen(variables.stConfig.layoutSections);i=i+1) {
				thisSection = ListGetAt(variables.stConfig.layoutSections,i);
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
									throw("Invalid HomePortals xml. Location node does not have a Name.");
								if(Not structKeyExists(xmlThisNode.xmlAttributes, "type")) 
									throw("Invalid HomePortals xml. Location node does not have a Type.");
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
							if(xmlNode.xmlChildren[j].xmlName eq "module") {
								xmlThisNode = xmlNode.xmlChildren[j];
								args = duplicate(xmlThisNode.xmlAttributes);
								
								// validate module attributes
								if(Not structKeyExists(args, "name")) args.name = "";
								if(Not structKeyExists(args, "location")) 
									throw("Invalid HomePortals xml. Module node does not have a Location.");
								if(Not structKeyExists(args, "title")) args.title = args.name; 
								if(Not structKeyExists(args, "container")) args.container = true; 
								if(Not structKeyExists(args, "display")) args.display = "normal";  // normal, collapsed, hidden
								if(Not structKeyExists(args, "id")) args.id = ""; 
								if(Not structKeyExists(args, "showPrint")) args.showPrint = true; 
								if(Not structKeyExists(args, "output")) args.output = true; 
								if(Not structKeyExists(args, "style")) args.style = ""; 
	
								// Provide a unique ID for each module 
								if(args.id eq "") args.id = "h_module_#args.location#_#j#";
	
								// ******** process user-defined module icons  ******
								// get base module icons
								args["icons"] = variables.stConfig.moduleIcons;
								
								// get icons defined for the current module
								for(k=1;k lte ArrayLen(xmlThisNode.xmlChildren);k=k+1) {
									if(xmlThisNode.xmlChildren[k].xmlName eq "moduleIcon") {
										thisStruct = aTmpIcons[j].xmlAttributes;
										if(Not StructKeyExists(thisStruct,"alt")) thisStruct.alt = ""; //alternate text
										if(Not StructKeyExists(thisStruct,"image")) thisStruct.image = ""; // url of image
										if(Not StructKeyExists(thisStruct,"onClickFunction")) thisStruct.onClickFunction= ""; //JS for onclick event 
									
										stIcon = structNew();
										stIcon.alt = thisStruct.alt;
										stIcon.image = thisStruct.image;
										stIcon.onClickFunction = thisStruct.onClickFunction;
										
										ArrayAppend(args.icons, stIcon);
									}
								}
	
								// create structure for modules that belong to the same location
								if(Not StructKeyExists(variables.stPage.page.modules, args.location) )
									variables.stPage.page.modules[args.location] = ArrayNew(1);
								
								ArrayAppend(variables.stPage.page.modules[args.location], duplicate(args) );
							}
						}
	
						break;
							
					// event handlers
					case "eventListeners":
						for(j=1;j lte ArrayLen(xmlNode.xmlChildren); j=j+1) {
							if(xmlNode.xmlChildren[j].xmlName eq "event") {
								xmlThisNode = xmlNode.xmlChildren[j];
								if(Not StructKeyExists(xmlThisNode.xmlAttributes,"objectName")) xmlThisNode.objectName = ""; 
								if(Not StructKeyExists(xmlThisNode.xmlAttributes,"eventName")) xmlThisNode.xmlAttributes.eventName = ""; 
								if(Not StructKeyExists(xmlThisNode.xmlAttributes,"eventHandler")) xmlThisNode.xmlAttributes.eventHandler= ""; 
								
								ArrayAppend(variables.stPage.page.eventListeners, duplicate(xmlNode.xmlChildren[j].xmlAttributes));
							}
						}
						break;	
						
				}
			}		
			
			variables.stTimers["LOAD PAGE"] = getTickCount()-tmrStart;
		</cfscript>
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
			var location = "";
			
			for(location in stModules) {
				aModules = stModules[location];
				for(i=1;i lte arrayLen(aModules);i=i+1) {
					stModuleNode = stModules[location][i];
					if(stModuleNode.name neq "") {
						if(left(stModuleNode.name,4) neq "http")
							processModule(stModuleNode);
						else
							processRemoteModule(stModuleNode);
					}
				}	
			}
		</cfscript>
	</cffunction>

	<!--------------------------------------->
	<!----  processModule				----->
	<!--------------------------------------->
	<cffunction name="processModule" access="private">
		<cfargument name="moduleNode" type="any" required="true">
		<cfscript>
			var bIsFirstInClass = false;
			var oModuleController = 0;
			var moduleID = arguments.moduleNode.id;
			var moduleName = arguments.moduleNode.name;
			var tmpMsg = "";

			// if we are on HTTPS then prefix the module with the SSL root
			if(variables.isHTTPS) moduleName = variables.stConfig.SSLRoot & moduleName;

			try {
				// if there is a base path then prepend it to the module name
				// otherwise prepend the module library path
				if(variables.stPage.page.basePath neq "")
					moduleName = variables.stPage.page.basePath & moduleName;
				else
					moduleName = variables.stConfig.moduleLibraryPath & moduleName;

				moduleName = replace(moduleName,"/",".","ALL");
				if(left(moduleName,1) eq ".")
					moduleName = right(moduleName, len(moduleName)-1);

				bIsFirstInClass = (Not listFind(variables.loadedModuleClasses, moduleName));
				
				// instantiate module controller and call constructor
				oModuleController = createObject("component","moduleController");
				oModuleController.init(moduleID, moduleName, arguments.moduleNode, variables.stPage.href, bIsFirstInClass);

				// render html content
				appendPageContent("_htmlHead", moduleID, oModuleController.renderClientInit() );
				appendPageContent("_htmlHead", moduleID, oModuleController.renderHTMLHead() );
				appendPageContent("_htmlModule", moduleID, oModuleController.render() );
				
				if(bIsFirstInClass) {
					// append module name to list of loaded module classes to avoid initializing the same class twice
					variables.loadedModuleClasses = listAppend(variables.loadedModuleClasses, moduleName);
				}

			} catch(any e) {
				tmpMsg = "<b>An unexpected error ocurred while initializing module #moduleID#.</b><br><br><b>Message:</b> #e.message#";
				appendPageContent("_htmlModule", moduleID, tmpMsg );
			}
		</cfscript>			
	</cffunction>	
	
	<!--------------------------------------->
	<!----  processRemoteModule			----->
	<!--------------------------------------->
	<cffunction name="processRemoteModule" access="private">
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
			<cfset appendPageContent("_htmlModule", moduleID, cfhttp.FileContent )>

			<cfcatch type="any">
				<cfsavecontent variable="tmpHTML">
					<cfinclude template="#variables.errorTemplate#">
				</cfsavecontent>
				<cfset appendPageContent("_htmlModule", moduleID, tmpHTML )>
			</cfcatch>
		</cftry>
	</cffunction>





	<!--------------------------------------->
	<!----  renderLayoutSection			----->
	<!--------------------------------------->
	<cffunction name="renderLayoutSection" access="public" output="true" hint="Renders all modules in a given layout section. Optionally, the caller can pass the html tag to use to for the layout section.">
		<cfargument name="layoutSection" type="string" required="yes">
		<cfargument name="tagName" type="string" required="no" default="div">

		<cfset var i = 0>
		<cfset var j = 0>
		<cfset var aModules = ArrayNew(1)>
		<cfset var aLocations = variables.stPage.page.layout[arguments.layoutSection]>
		<cfset var stModuleNode = structNew()>

		<!--- Loop through each section --->
		<cfloop from="1" to="#ArrayLen(aLocations)#" index="i">
			<cfif StructKeyExists(variables.stPage.page.modules, aLocations[i].name)>
				<#arguments.TagName# class="#aLocations[i].Class#" style="#aLocations[i].Style#" id="#aLocations[i].ID#" valign="top">
					<!--- Display all modules within this section --->
					<cfset aModules = variables.stPage.page.modules[aLocations[i].name]>
					<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
						<cfset stModuleNode = variables.stPage.page.modules[aLocations[i].name][j]>
						<cfif stModuleNode.output>
							#renderModule(stModuleNode)#
						</cfif>
					</cfloop>
				</#arguments.TagName#>
			</cfif>
		</cfloop>
	</cffunction>

	<!--------------------------------------->
	<!----  renderModule				----->
	<!--------------------------------------->
	<cffunction name="renderModule" access="public" hint="Initializes and renders a HomePortals module instance.">
		<cfargument name="moduleNode" type="any" required="true">

		<cfscript>
			var tmpDisplay = "display:block;";
			var moduleID = arguments.moduleNode.id;
			var moduleName = arguments.moduleNode.name;
			var aIcons = arguments.moduleNode.icons;
			var imgRoot = variables.stConfig.homePortalsPath & "Common/Images";
			var j = 1;
		</cfscript>
		
		<!--- Display Module Output and Container --->
		<cfoutput>
			<div class="Section" id="#moduleID#" style="#tmpDisplay#">
				<cfif arguments.moduleNode.Container>
					<div class="SectionTitle" id="#moduleID#_Head">
						<h2>&nbsp;
							<cfif arguments.moduleNode.ShowPrint>
								<div class="SectionControls_Arrow">
									<a href="javascript:h_CollapseSection('#moduleID#');" id="#moduleID#_ButtonHide"><img src="#imgRoot#/blue-chevron_up.gif" border="0" alt="Hide Section"></a>
									<a href="javascript:h_ExpandSection('#moduleID#');" id="#moduleID#_ButtonShow" style="display:none;"><img src="#imgRoot#/blue-chevron_down.gif" border="0" alt="Show Section"></a>
								</div>
	
								<cfloop from="1" to="#ArrayLen(aIcons)#" index="j">
									<a href="javascript:#aIcons[j].onClickFunction#('#moduleID#')"><img src="#aIcons[j].image#" alt="#aIcons[j].alt#" title="#aIcons[j].alt#" border="0"></a>
								</cfloop>
							</cfif>
							<a href="javascript:h_ToggleSection('#moduleID#');"><div class="SectionTitleLabel" id="#moduleID#_Title">#arguments.moduleNode.Title#</div></a>
						</h2>
					</div>
				</cfif>
				
				<div class="SectionBody" id="#moduleID#_Body">
					<div class="SectionBodyRegion" id="#moduleID#_BodyRegion" style="#arguments.moduleNode.style#">
						#getPageContent("_htmlModule", moduleID)#
					</div>
				</div>
			</div>
		</cfoutput>
	</cffunction>

	<!--------------------------------------->
	<!----  renderCustomSection			----->
	<!--------------------------------------->
	<cffunction name="renderCustomSection" access="public" hint="Renders template-based resources such as headers and footers.">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var aResourceType = ArrayNew(1)>
		<cfset var i = 0>
		
		<cfif structKeyExists(variables.stConfig.resources, arguments.resourceType)>
			<cfset aResourceType = variables.stConfig.resources[arguments.resourceType]>
			<cfloop from="1" to="#ArrayLen(aResourceType)#" index="i">
				<cftry>
					<cfinclude template="#aResourceType[i]#">
					<cfcatch type="any">
						<cfinclude template="#variables.errorTemplate#">
					</cfcatch>
				</cftry>
			</cfloop>	
		</cfif>
	</cffunction>

	<!--------------------------------------->
	<!----  renderHTMLHeadCode			----->
	<!--------------------------------------->
	<cffunction name="renderHTMLHeadCode" access="public" returntype="string" output="false">
		<cfset var i = 0>
		<cfset var aStylesheets = variables.stPage.page.stylesheets>
		<cfset var aScripts = variables.stPage.page.scripts>
		<cfset var aEventListeners = variables.stPage.page.eventListeners>
		<cfset var stPageHeadContent = getPageContentByType("_htmlHead")>
		<cfset var moduleID = "">
		<cfset var tmpHTML = "">
		
		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<!--- Include basic and user-defined CSS styles --->
				<cfloop from="1" to="#ArrayLen(aStylesheets)#" index="i">
					<link rel="stylesheet" type="text/css" href="#aStylesheets[i]#" />
				</cfloop>
				
				<!--- Include required and user-defined Javascript files --->
				<cfloop from="1" to="#ArrayLen(aScripts)#" index="i">
					<script src="#aScripts[i]#" type="text/javascript"></script>
				</cfloop>
				
				<!--- Process event listeners --->
				<script type="text/javascript">
					/*********** Raise events by modules *************/
					function h_raiseEvent(objectName, eventName, args) {
						<cfloop from="1" to="#ArrayLen(aEventListeners)#" index="i">
							if(objectName=="#aEventListeners[i].objectName#" && eventName=="#aEventListeners[i].eventName#") {
								try {#aEventListeners[i].eventHandler#(args);} catch(e) {alert(e);}
							}
						</cfloop>
					}
				</script>
				
				<!--- Add html head code rendered by modules --->
				<cfloop collection="#stPageHeadContent#" item="moduleID">
					#stPageHeadContent[moduleID]#
				</cfloop>
			</cfoutput>
		</cfsavecontent>
		<cfset tmpHTML = REReplace(tmpHTML, "[[:space:]]{2,}","","ALL")> 
		<cfreturn tmpHTML>
	</cffunction>
	
	
	
	
	
	<!--------------------------------------->
	<!----  appendPageContent			----->
	<!--------------------------------------->
	<cffunction name="appendPageContent" access="private">
		<cfargument name="contentType" required="true">
		<cfargument name="contentKey" required="true" default="">
		<cfargument name="content" required="true">

		<cfset var stTemp = structNew()>
		
		<cfif not structKeyExists(variables.pageContent, arguments.contentType)>
			<cfset variables.pageContent[arguments.contentType] = structNew()>
		</cfif>
		
		<cfif not structKeyExists(variables.pageContent[arguments.contentType], arguments.contentKey)>
			<cfset variables.pageContent[arguments.contentType][arguments.contentKey] = arguments.content>
		<cfelse>
			<cfset variables.pageContent[arguments.contentType][arguments.contentKey] = variables.pageContent[arguments.contentType][arguments.contentKey] & arguments.content>
		</cfif>		
		
	</cffunction>
	
	<!--------------------------------------->
	<!----  getPageContent				----->
	<!--------------------------------------->
	<cffunction name="getPageContent" access="private" returntype="string">
		<cfargument name="contentType" required="true">
		<cfargument name="contentKey" required="true">
		<cfset var tmpHTML = "">
		<cfif structKeyExists(variables.pageContent[arguments.contentType], arguments.contentKey)>
			<cfset tmpHTML = variables.pageContent[arguments.contentType][arguments.contentKey]>
		</cfif>
		<cfset tmpHTML = REReplace(tmpHTML, "[[:space:]]{2,}"," ","ALL")>
		<cfreturn tmpHTML>
	</cffunction>

	<!--------------------------------------->
	<!----  getPageContentByType		----->
	<!--------------------------------------->
	<cffunction name="getPageContentByType" access="private" returntype="any">
		<cfargument name="contentType" required="true">
		<cfreturn variables.pageContent[arguments.contentType]>
	</cffunction>

	
	
	<!--------------------------------------->
	<!----  getters / setters			----->
	<!--------------------------------------->
	<cffunction name="getConfig" access="public" returntype="struct" output="false">
		<cfreturn variables.stConfig>
	</cffunction>

	<cffunction name="getPage" access="public" returntype="struct" output="false">
		<cfreturn variables.stPage>
	</cffunction>

	<cffunction name="getTimers" access="public" returntype="struct" output="false">
		<cfreturn variables.stTimers>
	</cffunction>
	
	<cffunction name="setConfig" access="public" output="false">
		<cfargument name="data" type="struct" required="yes">
		<cfset variables.stConfig = Duplicate(arguments.data)>
	</cffunction>

	<cffunction name="setPage" access="public" output="false">
		<cfargument name="data" type="struct" required="yes">
		<cfset variables.stPage = Duplicate(arguments.data)>
	</cffunction>

	<cffunction name="getDefaultPage" access="public" returntype="any" output="false">
		<cfreturn variables.stConfig.defaultPage>
	</cffunction>

	<cffunction name="getBodyOnLoad" access="public" returntype="any" output="false">
		<cfreturn trim(variables.stConfig.bodyOnLoad)>
	</cffunction>




	
		
	<!--------------------------------------->
	<!----  Private Methods  			----->
	<!--------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
	</cffunction>
	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

	<cffunction name="readFile" returntype="xml" access="private" hint="Retrieves a document and returns it as an xml object">
		<cfargument name="documentPath" type="string" hint="Path for the document">
		<cfargument name="isURL" type="boolean" default="true" required="false" hint="If true, then documentPath is a relative URL otherwise is an absolute path.">
		<cfscript>
			var tmpPath = arguments.documentPath;
			var xmlDoc = 0;

			if(arguments.isURL) tmpPath = expandPath(arguments.documentPath);

			// check that file exists
			if(Not fileExists(tmpPath))
				throw("The requested document [#arguments.documentPath#] does not exist.");
				
			// read and parse document
			xmlDoc = xmlParse(tmpPath);
		</cfscript>
		<cfreturn xmlDoc>
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

	<!---------------------------------------->
	<!--- include                          --->
	<!---------------------------------------->
	<cffunction name="include" access="private">
		<cfargument name="template" type="any">
		<cfinclude template="#arguments.template#">
	</cffunction>
				
</cfcomponent>
