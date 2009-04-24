<cfcomponent displayname="homePortalsConfigBean" hint="A bean to store the HomePortals configuration. Configuration is per-application">

	<cfset variables.stConfig = StructNew()>
	<cfset variables.hpEngineBaseVersion = "3.1.x">
	<cfset variables.stRenderTemplatesCache = structNew()>

	<cffunction name="init" access="public" returntype="homePortalsConfigBean">
		<cfargument name="configFilePath" type="string" required="false" default="" 
					hint="The relative address of the config file. If not empty, then loads the config from the file">
		<cfscript>
			variables.stConfig = structNew();
			variables.stConfig.version = variables.hpEngineBaseVersion;
			variables.stConfig.initialEvent = "";
			variables.stConfig.layoutSections = "";
			variables.stConfig.bodyOnLoad = "";
			variables.stConfig.homePortalsPath = "";
			variables.stConfig.defaultPage = "";
			variables.stConfig.appRoot = "";
			variables.stConfig.contentRoot = "";
			variables.stConfig.pageCacheSize = "";
			variables.stConfig.pageCacheTTL = "";
			variables.stConfig.contentCacheSize = "";
			variables.stConfig.contentCacheTTL = "";
			variables.stConfig.catalogCacheSize = "";
			variables.stConfig.catalogCacheTTL = "";
			variables.stConfig.rssCacheSize = "";
			variables.stConfig.rssCacheTTL = "";
			variables.stConfig.baseResourceTypes = "";
			variables.stConfig.pageProviderClass = "";
			variables.stConfig.lstResourceTypes = "";

			variables.stConfig.resourceLibraryPaths = arrayNew(1);
			variables.stConfig.renderTemplates = structNew();
			variables.stConfig.resources = structNew();
			variables.stConfig.contentRenderers = structNew();
			variables.stConfig.plugins = structNew();
			variables.stConfig.resourceTypes = structNew();
			
			// if a config path is given, then load the config from the given file
			if(arguments.configFilePath neq "") {
				load(arguments.configFilePath);
			}
			
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="load" access="public" returntype="void" hint="Loads config settings from the given file">
		<cfargument name="configFilePath" type="string" required="true" 
					hint="The absolute path to the config file.">

		<cfscript>
			var i = 0;
			var xmlNode = 0;
			var j = 0; var k = 0;
			var xmlThisNode = 0;
			var key = "";
			
			// read configuration file
			if(Not fileExists(arguments.configFilePath))
				throw("Configuration file not found [#configFilePath#]","","homePortals.config.configFileNotFound");
			else
				xmlConfigDoc = xmlParse(arguments.configFilePath);

			// get version
			if(structKeyExists(xmlConfigDoc.xmlRoot.xmlAttributes,"version")) 
				variables.stConfig.version = xmlConfigDoc.xmlRoot.xmlAttributes.version;

			// parse config doc		
			for(i=1;i lte ArrayLen(xmlConfigDoc.xmlRoot.xmlChildren);i=i+1) {
			
				// get poiner to current node
				xmlNode = xmlConfigDoc.xmlRoot.xmlChildren[i];
				
				if(xmlNode.xmlName eq "baseResources") {
				
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						xmlThisNode = xmlNode.xmlChildren[j];
						if(xmlThisNode.xmlName eq "resource") {
							// make sure we have a type attribute
							if(Not structKeyExists(xmlThisNode.xmlAttributes,"type"))
								throw("HomePortals config file is malformed. Missing TYPE attribute for baseResource","","homePortals.config.configFileNotValid");

							// store baseresources indexed by type
							if(Not structKeyExists(variables.stConfig.resources, xmlThisNode.xmlAttributes.type)) {
								variables.stConfig.resources[xmlThisNode.xmlAttributes.type] = ArrayNew(1);
							
								// keep track of list of existing types (this is used in case there is no baseResourceTypes entry)
								variables.stConfig.lstResourceTypes = listAppend(variables.stConfig.lstResourceTypes, xmlThisNode.xmlAttributes.type);
							}
							ArrayAppend(variables.stConfig.resources[xmlThisNode.xmlAttributes.type], xmlThisNode.xmlAttributes.href);
						}
						
					}

				} else if(xmlNode.xmlName eq "renderTemplates") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						variables.stConfig.renderTemplates[ xmlNode.xmlChildren[j].xmlAttributes.type ] = xmlNode.xmlChildren[j].xmlAttributes.href;
					}

				} else if(xmlNode.xmlName eq "contentRenderers") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						variables.stConfig.contentRenderers[ xmlNode.xmlChildren[j].xmlAttributes.moduleType ] = xmlNode.xmlChildren[j].xmlAttributes.path;
					}

				} else if(xmlNode.xmlName eq "plugins") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						variables.stConfig.plugins[ xmlNode.xmlChildren[j].xmlAttributes.name ] = xmlNode.xmlChildren[j].xmlAttributes.path;
					}

				} else if(xmlNode.xmlName eq "resourceTypes") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						xmlThisNode = xmlNode.xmlChildren[j];
						
						if(xmlThisNode.xmlName eq "resourceType") {
							variables.stConfig.resourceTypes[ xmlThisNode.xmlAttributes.name ] = structNew();
							variables.stConfig.resourceTypes[ xmlThisNode.xmlAttributes.name ].name = xmlThisNode.xmlAttributes.name;
							variables.stConfig.resourceTypes[ xmlThisNode.xmlAttributes.name ].properties = arrayNew(1);
					
							for(k=1;k lte arrayLen(xmlThisNode.xmlChildren);k=k+1) {
								if(xmlThisNode.xmlChildren[k].xmlName eq "property") {
									arrayAppend(variables.stConfig.resourceTypes[ xmlThisNode.xmlAttributes.name ].properties,
												xmlThisNode.xmlChildren[k].xmlAttributes);								
								} else {
									variables.stConfig.resourceTypes[ xmlThisNode.xmlAttributes.name ][ xmlThisNode.xmlChildren[k].xmlName ] = xmlThisNode.xmlChildren[k].xmlText;
								}
							}
						}
					}

				} else if(xmlNode.xmlName eq "resourceLibraryPath") {

					arrayAppend( variables.stConfig.resourceLibraryPaths, xmlNode.xmlText ); 

				} else if(xmlNode.xmlName eq "resourceLibraryPaths") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						arrayAppend( variables.stConfig.resourceLibraryPaths , xmlNode.xmlChildren[j].xmlText );
					}
							
				} else
					variables.stConfig[xmlNode.xmlName] = xmlNode.xmlText;
				
			}
		
			// set initial javascript event
			if(ListLen(variables.stConfig.initialEvent,".") eq 2)
				variables.stConfig.bodyOnLoad = "h_raiseEvent('#ListFirst(variables.stConfig.initialEvent,".")#', '#ListLast(variables.stConfig.initialEvent,".")#')";
				
		
		</cfscript>	
	</cffunction>

	<cffunction name="toXML" access="public" returnType="xml" hint="Returns the bean settings as an XML document">
		<cfscript>
			var xmlConfigDoc = "";
			var xmlOriginalConfigDoc = "";
			var lstResourceTypes = "";
			var lstKeys = "";
			var i = 1; var j = 1; var k = 1;
			var thisKey = "";
			var key = ""; var st = structNew();
			var thisResourceType = "";
			var tmpXmlNode = 0; var tmpXmlNode2 = 0;
			var lstKeysIgnore = "version,renderTemplates,resources,contentRenderers,plugins,resourceTypes,resourceLibraryPaths";

			// create a blank xml document and add the root node
			xmlConfigDoc = xmlNew();
			xmlConfigDoc.xmlRoot = xmlElemNew(xmlConfigDoc, "homePortals");		
			xmlConfigDoc.xmlRoot.xmlAttributes["version"] = variables.stConfig.version;
			
			// save simple value settings
			lstKeys = structKeyList(variables.stConfig);

			for(i=1;i lte ListLen(lstKeys);i=i+1) {
				thisKey = ListGetAt(lstKeys,i);
				tmpXmlNode = 0;
				switch(thisKey) {
					case "initialEvent": tmpXmlNode = xmlElemNew(xmlConfigDoc,"initialEvent"); break;
					case "layoutSections": tmpXmlNode = xmlElemNew(xmlConfigDoc,"layoutSections"); break;
					case "bodyOnLoad": tmpXmlNode = xmlElemNew(xmlConfigDoc,"bodyOnLoad"); break;
					case "homePortalsPath": tmpXmlNode = xmlElemNew(xmlConfigDoc,"homePortalsPath"); break;
					case "defaultPage": tmpXmlNode = xmlElemNew(xmlConfigDoc,"defaultPage"); break;
					case "appRoot": tmpXmlNode = xmlElemNew(xmlConfigDoc,"appRoot"); break;
					case "contentRoot": tmpXmlNode = xmlElemNew(xmlConfigDoc,"contentRoot"); break;
					case "pageCacheSize": tmpXmlNode = xmlElemNew(xmlConfigDoc,"pageCacheSize"); break;
					case "pageCacheTTL": tmpXmlNode = xmlElemNew(xmlConfigDoc,"pageCacheTTL"); break;
					case "contentCacheSize": tmpXmlNode = xmlElemNew(xmlConfigDoc,"contentCacheSize"); break;
					case "contentCacheTTL": tmpXmlNode = xmlElemNew(xmlConfigDoc,"contentCacheTTL"); break;
					case "rssCacheSize": tmpXmlNode = xmlElemNew(xmlConfigDoc,"rssCacheSize"); break;
					case "rssCacheTTL": tmpXmlNode = xmlElemNew(xmlConfigDoc,"rssCacheTTL"); break;
					case "catalogCacheSize": tmpXmlNode = xmlElemNew(xmlConfigDoc,"catalogCacheSize"); break;
					case "catalogCacheTTL": tmpXmlNode = xmlElemNew(xmlConfigDoc,"catalogCacheTTL"); break;
					case "baseResourceTypes": tmpXmlNode = xmlElemNew(xmlConfigDoc,"baseResourceTypes"); break;
					case "pageProviderClass": tmpXmlNode = xmlElemNew(xmlConfigDoc,"pageProviderClass"); break;
				}
				if(isXMLNode(tmpXmlNode)) {
					tmpXmlNode.xmlText = variables.stConfig[thisKey];
					arrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, tmpXmlNode);
				}	
			}
			
			
			// ****** [baseResources] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"baseResources") );
			
			if(getBaseResourceTypes() neq "") {
				lstResourceTypes = getBaseResourceTypes();
			} else {
				lstResourceTypes = variables.stConfig.lstResourceTypes;
			}
			
			for(i=1;i lte ListLen(lstResourceTypes);i=i+1) {
				thisResourceType = ListGetAt(lstResourceTypes, i);
				
				if(structKeyExists(variables.stConfig.resources, thisResourceType)) {
					for(j=1;j lte ArrayLen(variables.stConfig.resources[thisResourceType]);j=j+1) {
						tmpXmlNode = xmlElemNew(xmlConfigDoc,"resource");
						tmpXmlNode.xmlAttributes["type"] = thisResourceType;
						tmpXmlNode.xmlAttributes["href"] = variables.stConfig.resources[thisResourceType][j];
						ArrayAppend(xmlConfigDoc.xmlRoot.baseResources.xmlChildren, tmpXmlNode);
					}		
				}
			}

			// ****** [renderTemplates] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"renderTemplates") );
			
			for(thisKey in variables.stConfig.renderTemplates) {
				tmpXmlNode = xmlElemNew(xmlConfigDoc,"renderTemplate");
				tmpXmlNode.xmlAttributes["type"] = thisKey;
				tmpXmlNode.xmlAttributes["href"] = variables.stConfig.renderTemplates[thisKey];
				ArrayAppend(xmlConfigDoc.xmlRoot.renderTemplates.xmlChildren, tmpXmlNode );
			}

			// ****** [contentRenderers] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"contentRenderers") );
			
			for(thisKey in variables.stConfig.contentRenderers) {
				tmpXmlNode = xmlElemNew(xmlConfigDoc,"contentRenderer");
				tmpXmlNode.xmlAttributes["moduleType"] = thisKey;
				tmpXmlNode.xmlAttributes["path"] = variables.stConfig.contentRenderers[thisKey];
				ArrayAppend(xmlConfigDoc.xmlRoot.contentRenderers.xmlChildren, tmpXmlNode );
			}

			// ****** [plugins] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"plugins") );
			
			for(thisKey in variables.stConfig.plugins) {
				tmpXmlNode = xmlElemNew(xmlConfigDoc,"plugin");
				tmpXmlNode.xmlAttributes["name"] = thisKey;
				tmpXmlNode.xmlAttributes["path"] = variables.stConfig.plugins[thisKey];
				ArrayAppend(xmlConfigDoc.xmlRoot.plugins.xmlChildren, tmpXmlNode );
			}

			// ****** [resourceTypes] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"resourceTypes") );
			
			for(thisKey in variables.stConfig.resourceTypes) {
				st = variables.stConfig.resourceTypes[thisKey];
				
				tmpXmlNode = xmlElemNew(xmlConfigDoc,"resourceType");
				tmpXmlNode.xmlAttributes["name"] = st.name;
				
				for(key in st) {
					tmpXmlNode2 = 0;
					switch(key) {
						case "description":  tmpXmlNode2 = xmlElemNew(xmlConfigDoc,"description"); break;
						case "folderName": tmpXmlNode2 = xmlElemNew(xmlConfigDoc,"folderName"); break;
						case "resBeanPath": tmpXmlNode2 = xmlElemNew(xmlConfigDoc,"resBeanPath"); break;
						case "fileTypes": tmpXmlNode2 = xmlElemNew(xmlConfigDoc,"fileTypes"); break;
					}
					if(isXmlNode(tmpXmlNode2) and st[key] neq "") {
						tmpXmlNode2.xmlText = xmlFormat(st[key]);
						ArrayAppend(tmpXmlNode.xmlChildren, tmpXmlNode2 );
					}
				}
				
				if(structKeyExists(st,"properties")) {
					aProperties = st.properties;
					for(k=1;k lte arrayLen(aProperties);k=k+1) {
						tmpXmlNode2 = xmlElemNew(xmlConfigDoc,"property");
						if(structKeyExists(aProperties[k],"name") and aProperties[k].name neq "") tmpXmlNode2.xmlAttributes["name"] = aProperties[k].name;
						if(structKeyExists(aProperties[k],"description") and aProperties[k].description neq "") tmpXmlNode2.xmlAttributes["description"] = aProperties[k].description;
						if(structKeyExists(aProperties[k],"type") and aProperties[k].type neq "") tmpXmlNode2.xmlAttributes["type"] = aProperties[k].type;
						if(structKeyExists(aProperties[k],"values") and aProperties[k].values neq "") tmpXmlNode2.xmlAttributes["values"] = aProperties[k].values;
						if(structKeyExists(aProperties[k],"required") and aProperties[k].required neq "") tmpXmlNode2.xmlAttributes["required"] = aProperties[k].required;
						if(structKeyExists(aProperties[k],"default") and aProperties[k]["default"] neq "") tmpXmlNode2.xmlAttributes["default"] = aProperties[k]["default"];
						if(structKeyExists(aProperties[k],"label") and aProperties[k].label neq "") tmpXmlNode2.xmlAttributes["label"] = aProperties[k].label;
						ArrayAppend(tmpXmlNode.xmlChildren, tmpXmlNode2 );
					}
				}
				
				ArrayAppend(xmlConfigDoc.xmlRoot.resourceTypes.xmlChildren, tmpXmlNode );
			}

			// ****** [resourceLibrary] *****	
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"resourceLibraryPaths") );
			for(i=1;i lte arrayLen(variables.stConfig.resourceLibraryPaths);i=i+1) {
				tmpXmlNode = xmlElemNew(xmlConfigDoc,"resourceLibraryPath");
				tmpXmlNode.xmlText = variables.stConfig.resourceLibraryPaths[i];
				ArrayAppend(xmlConfigDoc.xmlRoot.resourceLibraryPaths.xmlChildren, tmpXmlNode );
			}

			// return document
			return xmlConfigDoc;
		</cfscript>		
	</cffunction>

	<!--- Getters --->
	<cffunction name="getVersion" access="public" returntype="string">
		<cfreturn variables.stConfig.version>
	</cffunction>

	<cffunction name="getInitialEvent" access="public" returntype="string">
		<cfreturn variables.stConfig.initialEvent>
	</cffunction>

	<cffunction name="getLayoutSections" access="public" returntype="string">
		<cfreturn variables.stConfig.layoutSections>
	</cffunction>

	<cffunction name="getBodyOnLoad" access="public" returntype="string">
		<cfreturn variables.stConfig.bodyOnLoad>
	</cffunction>

	<cffunction name="getHomePortalsPath" access="public" returntype="string" hint="The path to the HomePortals engine">
		<cfreturn variables.stConfig.homePortalsPath>
	</cffunction>

	<cffunction name="getDefaultPage" access="public" returntype="string" hint="The name of the page to load when page has been specified">
		<cfreturn variables.stConfig.defaultPage>
	</cffunction>

	<cffunction name="getAppRoot" access="public" returnType="string" hint="The root of the application">
		<cfreturn variables.stConfig.appRoot>
	</cffunction>

	<cffunction name="getContentRoot" access="public" returnType="string" hint="The root where content pages will be stored">
		<cfreturn variables.stConfig.contentRoot>
	</cffunction>

	<cffunction name="getPageCacheSize" access="public" returntype="any" hint="The maximum number of homeportals pages to cache at any given time">
		<cfreturn val(variables.stConfig.pageCacheSize)>	
	</cffunction>

	<cffunction name="getPageCacheTTL" access="public" returntype="any" hint="The maximum amount in minutes before an unchanged page is expelled from the cache.">
		<cfreturn val(variables.stConfig.pageCacheTTL)>
	</cffunction>

	<cffunction name="getCatalogCacheSize" access="public" returntype="any" hint="The maximum number of items to hold in the catalog cache">
		<cfreturn val(variables.stConfig.contentCacheSize)>	
	</cffunction>

	<cffunction name="getCatalogCacheTTL" access="public" returntype="any" hint="Default TTL in minutes for content items on the catalog cache">
		<cfreturn val(variables.stConfig.contentCacheTTL)>
	</cffunction>

	<cffunction name="getBaseResourceTypes" access="public" returntype="string" hint="List with allowed types of base resources">
		<cfreturn variables.stConfig.baseResourceTypes>
	</cffunction>	

	<cffunction name="getBaseResourcesByType" access="public" returntype="array" hint="Returns all base resources of the given type">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var aResources = arrayNew(1)>
		<cfif structKeyExists( variables.stConfig.resources, arguments.resourceType )>
			<cfset aResources = variables.stConfig.resources[arguments.resourceType]>
		</cfif>
		<cfreturn aResources>
	</cffunction>

	<cffunction name="getRenderTemplate" access="public" returntype="string" hint="returns the location of the template that should be used to rendering a particular type of output">
		<cfargument name="type" type="string" required="true">
		<cfif structKeyExists( variables.stConfig.renderTemplates, arguments.type )>
			<cfreturn variables.stConfig.renderTemplates[arguments.type]>
		<cfelse>
			<cfthrow message="Unknown render template type" type="homePortals.config.invalidRenderTemplateType">
		</cfif>
	</cffunction>

	<cffunction name="getRenderTemplateBody" access="public" returntype="string" hint="returns the contents of a rendertemplate">
		<cfargument name="type" type="string" required="true">
			
		<cfif Not StructKeyExists(variables.stRenderTemplatesCache, arguments.type)>
			<cfset xmlDoc = xmlParse(expandPath( getRenderTemplate(arguments.type) ))>
			<cfset templateBody = toString(xmlDoc.xmlRoot.xmlChildren[1])>
			<cfset variables.stRenderTemplatesCache[arguments.type] = templateBody>
		<cfelse>
			<cfset templateBody = variables.stRenderTemplatesCache[arguments.type]>
		</cfif>

		<cfreturn templateBody>
	</cffunction>

	<cffunction name="getPageProviderClass" access="public" returntype="string" hint="Returns the path in dot notation for the class responsible for storing/retrieving HomePortals pages">
		<cfreturn variables.stConfig.pageProviderClass>
	</cffunction>	

	<cffunction name="getContentRenderer" access="public" returntype="string" hint="returns the path to the given content renderer cfc">
		<cfargument name="name" type="string" required="true">
		<cfif structKeyExists( variables.stConfig.contentRenderers, arguments.name )>
			<cfreturn variables.stConfig.contentRenderers[arguments.name]>
		<cfelse>
			<cfthrow message="Unknown content renderer" type="homePortals.config.invalidContentRendererName">
		</cfif>
	</cffunction>

	<cffunction name="getContentRenderers" access="public" returntype="struct" hint="returns a key-value map with all declared content renderers and their paths">
		<cfreturn duplicate(variables.stConfig.contentRenderers)>
	</cffunction>	
	
	<cffunction name="getPlugin" access="public" returntype="string" hint="returns the path to the given extension plugin cfc">
		<cfargument name="name" type="string" required="true">
		<cfif structKeyExists( variables.stConfig.plugins, arguments.name )>
			<cfreturn variables.stConfig.plugins[arguments.name]>
		<cfelse>
			<cfthrow message="Unknown plugin" type="homePortals.config.invalidPluginName">
		</cfif>
	</cffunction>	

	<cffunction name="getPlugins" access="public" returntype="struct" hint="returns a key-value map with all declared plugins and their paths">
		<cfreturn duplicate(variables.stConfig.plugins)>
	</cffunction>	
	
	<cffunction name="getResourceTypes" access="public" returntype="struct" hint="returns a key-value map with all declared resource types and their associated extensions">
		<cfreturn duplicate(variables.stConfig.resourceTypes)>
	</cffunction>		

	<cffunction name="getResourceType" access="public" returntype="struct" hint="returns a key-value map with the requested resource type and its associated extensions">
		<cfargument name="name" type="string" required="true">
		<cfreturn duplicate(variables.stConfig.resourceTypes[arguments.name])>
	</cffunction>		
	
	<cffunction name="getResourceLibraryPath" access="public" returntype="string" hint="The path to the root where all resources are stored">
		<cfset var rtn = "">
		<cfif arrayLen(variables.stConfig.resourceLibraryPaths) gt 0>
			<cfreturn variables.stConfig.resourceLibraryPaths[1]>
		</cfif>
		<cfreturn rtn>
	</cffunction>

	<cffunction name="getResourceLibraryPaths" access="public" returntype="array" hint="Array with all registered resource paths">
		<cfreturn variables.stConfig.resourceLibraryPaths>
	</cffunction>
	
	<cffunction name="getMemento" access="public" returntype="struct" hint="returns a struct with a copy of all settings">
		<cfreturn duplicate(variables.stConfig)>
	</cffunction>
	
	
	<!--- Setters --->
	<cffunction name="setVersion" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.version = arguments.data>
	</cffunction>

	<cffunction name="setInitialEvent" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.initialEvent = arguments.data>
	</cffunction>

	<cffunction name="setLayoutSections" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.layoutSections = arguments.data>
	</cffunction>

	<cffunction name="setHomePortalsPath" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.homePortalsPath = arguments.data>
	</cffunction>

	<cffunction name="setResourceLibraryPath" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.resourceLibraryPaths[1] = arguments.data>
	</cffunction>

	<cffunction name="setDefaultPage" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.defaultPage = arguments.data>
	</cffunction>

	<cffunction name="setAppRoot" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.appRoot = arguments.data>
	</cffunction>

	<cffunction name="setContentRoot" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.contentRoot = arguments.data>
	</cffunction>

	<cffunction name="setPageCacheSize" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.pageCacheSize = arguments.data>	
	</cffunction>

	<cffunction name="setPageCacheTTL" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.pageCacheTTL = arguments.data>
	</cffunction>

	<cffunction name="setCatalogCacheSize" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.CatalogCacheSize = arguments.data>	
	</cffunction>

	<cffunction name="setCatalogCacheTTL" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.CatalogCacheTTL = arguments.data>
	</cffunction>

	<cffunction name="setBaseResourceTypes" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.baseResourceTypes = arguments.data>
	</cffunction>

	<cffunction name="addBaseResource" access="public" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		
		<cfif not listFindNoCase(variables.stConfig.baseResourceTypes, arguments.type)
				and not listFindNoCase(variables.stConfig.lstResourceTypes, arguments.type)>
			<cfset variables.stConfig.lstResourceTypes = listAppend(variables.stConfig.lstResourceTypes, arguments.type)>
		</cfif>
		
		<cfif not structKeyExists(variables.stConfig.resources, arguments.type)>
			<cfset variables.stConfig.resources[arguments.type] = arrayNew(1)>
		</cfif>

		<cfset arrayAppend(variables.stConfig.resources[arguments.type], arguments.href)>
	</cffunction>

	<cffunction name="removeBaseResource" access="public" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfset var aTmp = arrayNew(1)>
		<cfset var i = 0>
		<cfif structKeyExists(variables.stConfig.resources, arguments.type)>
			<cfset aTmp = variables.stConfig.resources[arguments.type]>
			<cfloop from="1" to="#arrayLen(aTmp)#" index="i">
				<cfif aTmp[i] eq arguments.href>
					<cfset arrayDeleteAt(variables.stConfig.resources[arguments.type], i)>
					<cfreturn>
				</cfif>
			</cfloop>
		</cfif>
	</cffunction>

	<cffunction name="setRenderTemplate" access="public" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfset variables.stConfig.renderTemplates[arguments.type] = arguments.href>
	</cffunction>

	<cffunction name="removeRenderTemplate" access="public" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfset structDelete(variables.stConfig.renderTemplates, arguments.type, false)>
	</cffunction>

	<cffunction name="setPageProviderClass" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.pageProviderClass = arguments.data>
	</cffunction>

	<cffunction name="setContentRenderer" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfset variables.stConfig.contentRenderers[arguments.name] = arguments.path>
	</cffunction>

	<cffunction name="removeContentRenderer" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.stConfig.contentRenderers, arguments.name, false)>
	</cffunction>

	<cffunction name="setPlugin" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfif arguments.path neq "">
			<cfset variables.stConfig.plugins[arguments.name] = arguments.path>
		<cfelseif structKeyExists(variables.stConfig.plugins, arguments.name)>
			<cfset structDelete(variables.stConfig.plugins, arguments.name)>
		</cfif>
	</cffunction>

	<cffunction name="removePlugin" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.stConfig.plugins, arguments.name, false)>
	</cffunction>

	<cffunction name="setResourceType" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="folderName" type="string" required="false" default="">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="resBeanPath" type="string" required="false" default="">
		<cfargument name="fileTypes" type="string" required="false" default="">
		<cfif not structKeyExists(variables.stConfig.resourceTypes, arguments.name)>
			<cfset variables.stConfig.resourceTypes[arguments.name] = structNew()>
			<cfset variables.stConfig.resourceTypes[arguments.name].properties = arrayNew(1)>
		</cfif>
		<cfset variables.stConfig.resourceTypes[arguments.name].name = arguments.name>
		<cfset variables.stConfig.resourceTypes[arguments.name].folderName = arguments.folderName>
		<cfset variables.stConfig.resourceTypes[arguments.name].description = arguments.description>
		<cfset variables.stConfig.resourceTypes[arguments.name].resBeanPath = arguments.resBeanPath>
		<cfset variables.stConfig.resourceTypes[arguments.name].fileTypes = arguments.fileTypes>
	</cffunction>

	<cffunction name="setResourceTypeProperty" access="public" returntype="void">
		<cfargument name="resType" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="type" type="string" required="false" default="">
		<cfargument name="values" type="string" required="false" default="">
		<cfargument name="required" type="string" required="false" default="">
		<cfargument name="default" type="string" required="false" default="">
		<cfargument name="label" type="string" required="false" default="">
		<cfset var st = structNew()>
		<cfset var aProps = variables.stConfig.resourceTypes[arguments.resType].properties>
		<cfset var index = 0>
		<cfset var i = 0>

		<cfloop from="1" to="#arrayLen(aProps)#" index="i">
			<cfif aProps[i].name eq arguments.name>
				<cfset index = i>
				<cfbreak>
			</cfif>
		</cfloop>

		<cfset st.name = arguments.name>
		<cfset st.description = arguments.description>
		<cfset st.type = arguments.type>
		<cfset st.values = arguments.values>
		<cfset st.required = arguments.required>
		<cfset st.default = arguments.default>
		<cfset st.label = arguments.label>
		
		<cfif index eq 0>
			<cfset arrayAppend(variables.stConfig.resourceTypes[arguments.resType].properties, duplicate(st))>
		<cfelse>
			<cfset variables.stConfig.resourceTypes[arguments.resType].properties[index] = duplicate(st)>
		</cfif>
	</cffunction>

	<cffunction name="removeResourceType" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.stConfig.resourceTypes, arguments.name, false)>
	</cffunction>

	<cffunction name="removeResourceTypeProperty" access="public" returntype="void">
		<cfargument name="resType" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfset var aProps = variables.stConfig.resourceTypes[arguments.resType].properties>
		<cfloop from="1" to="#arrayLen(aProps)#" index="i">
			<cfif aProps[i].name eq arguments.name>
				<cfset arrayDeleteAt(variables.stConfig.resourceTypes[arguments.resType].properties, i)>
				<cfreturn>
			</cfif>
		</cfloop>
	</cffunction>
		
	<cffunction name="addResourceLibraryPath" access="public" returntype="void">
		<cfargument name="path" type="string" required="true">
		<cfset arrayAppend(variables.stConfig.resourceLibraryPaths, arguments.path)>
	</cffunction>	

	<cffunction name="removeResourceLibraryPath" access="public" returntype="void">
		<cfargument name="path" type="string" required="true">
		<cfset var i = 0>
		<cfloop from="1" to="#arrayLen(variables.stConfig.resourceLibraryPaths)#" index="i">
			<cfif variables.stConfig.resourceLibraryPaths[i] eq arguments.path>
				<cfset arrayDeleteAt(variables.stConfig.resourceLibraryPaths, i)>
				<cfreturn>
			</cfif>
		</cfloop>
	</cffunction>	
	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

</cfcomponent>