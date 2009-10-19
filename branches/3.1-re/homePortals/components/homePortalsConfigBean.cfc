<cfcomponent displayname="homePortalsConfigBean" hint="A bean to store the HomePortals configuration. Configuration is per-application">

	<cfset variables.stConfig = StructNew()>
	<cfset variables.hpEngineBaseVersion = "3.1.x">

	<cffunction name="init" access="public" returntype="homePortalsConfigBean">
		<cfargument name="configFilePath" type="string" required="false" default="" 
					hint="The relative address of the config file. If not empty, then loads the config from the file">
		<cfscript>
			variables.stConfig = structNew();
			variables.stConfig.version = variables.hpEngineBaseVersion;
			variables.stConfig.initialEvent = "";
			variables.stConfig.bodyOnLoad = "";
			variables.stConfig.homePortalsPath = "";
			variables.stConfig.defaultPage = "";
			variables.stConfig.appRoot = "";
			variables.stConfig.contentRoot = "";
			variables.stConfig.pageCacheSize = "";
			variables.stConfig.pageCacheTTL = "";
			variables.stConfig.catalogCacheSize = "";
			variables.stConfig.catalogCacheTTL = "";
			variables.stConfig.baseResourceTypes = "";
			variables.stConfig.pageProviderClass = "";
			variables.stConfig.lstResourceTypes = "";

			variables.stConfig.resourceLibraryPaths = arrayNew(1);
			variables.stConfig.renderTemplates = structNew();
			variables.stConfig.resources = structNew();
			variables.stConfig.contentRenderers = structNew();
			variables.stConfig.plugins = structNew();
			variables.stConfig.resourceTypes = structNew();
			variables.stConfig.pageProperties = structNew();
			variables.stConfig.resourceLibraryTypes = structNew();
			
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

						if(Not structKeyExists(xmlNode.xmlChildren[j].xmlAttributes,"name"))
							throw("HomePortals config file is malformed. Missing NAME attribute for renderTemplate","","homePortals.config.configFileNotValid");
						if(Not structKeyExists(xmlNode.xmlChildren[j].xmlAttributes,"type"))
							throw("HomePortals config file is malformed. Missing TYPE attribute for renderTemplate","","homePortals.config.configFileNotValid");
						
						key = xmlNode.xmlChildren[j].xmlAttributes.name;
						thisKey = xmlNode.xmlChildren[j].xmlAttributes.type;

						if(not structKeyExists(variables.stConfig.renderTemplates, thisKey)) 
							variables.stConfig.renderTemplates[thisKey] = structNew();
							
						variables.stConfig.renderTemplates[thisKey][ key ] = {
																			name = key,
																			type = thisKey,
																			href = xmlNode.xmlChildren[j].xmlAttributes.href,
																			description = xmlNode.xmlChildren[j].xmlText,
																			isDefault = false
																		};
						
						if(structKeyExists(xmlNode.xmlChildren[j].xmlAttributes,"default")) 
							variables.stConfig.renderTemplates[thisKey][key].isDefault = xmlNode.xmlChildren[j].xmlAttributes.default;
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

				} else if(xmlNode.xmlName eq "pageProperties") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						xmlThisNode = xmlNode.xmlChildren[j];
						if(xmlThisNode.xmlName eq "property" 
								and structKeyExists(xmlThisNode.xmlAttributes,"name")
								and structKeyExists(xmlThisNode.xmlAttributes,"value")) {
							variables.stConfig.pageProperties[xmlThisNode.xmlAttributes.name] = xmlThisNode.xmlAttributes.value;
						}
					}

				} else if(xmlNode.xmlName eq "resourceLibraryTypes") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						xmlThisNode = xmlNode.xmlChildren[j];
						
						if(xmlThisNode.xmlName eq "resourceLibraryType") {
							variables.stConfig.resourceLibraryTypes[ xmlThisNode.xmlAttributes.prefix ] = structNew();
							variables.stConfig.resourceLibraryTypes[ xmlThisNode.xmlAttributes.prefix ].prefix = xmlThisNode.xmlAttributes.prefix;
							variables.stConfig.resourceLibraryTypes[ xmlThisNode.xmlAttributes.prefix ].path = xmlThisNode.xmlAttributes.path;
							variables.stConfig.resourceLibraryTypes[ xmlThisNode.xmlAttributes.prefix ].properties = structNew();
					
							for(k=1;k lte arrayLen(xmlThisNode.xmlChildren);k=k+1) {
								if(xmlThisNode.xmlChildren[k].xmlName eq "property") {
									variables.stConfig.resourceLibraryTypes[ xmlThisNode.xmlAttributes.prefix ].properties[xmlThisNode.xmlChildren[k].xmlAttributes.name] = structNew();
									variables.stConfig.resourceLibraryTypes[ xmlThisNode.xmlAttributes.prefix ].properties[xmlThisNode.xmlChildren[k].xmlAttributes.name].name = xmlThisNode.xmlChildren[k].xmlAttributes.name;
									variables.stConfig.resourceLibraryTypes[ xmlThisNode.xmlAttributes.prefix ].properties[xmlThisNode.xmlChildren[k].xmlAttributes.name].value = xmlThisNode.xmlChildren[k].xmlAttributes.value;
								}
							}
						}
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
					case "bodyOnLoad": tmpXmlNode = xmlElemNew(xmlConfigDoc,"bodyOnLoad"); break;
					case "homePortalsPath": tmpXmlNode = xmlElemNew(xmlConfigDoc,"homePortalsPath"); break;
					case "defaultPage": tmpXmlNode = xmlElemNew(xmlConfigDoc,"defaultPage"); break;
					case "appRoot": tmpXmlNode = xmlElemNew(xmlConfigDoc,"appRoot"); break;
					case "contentRoot": tmpXmlNode = xmlElemNew(xmlConfigDoc,"contentRoot"); break;
					case "pageCacheSize": tmpXmlNode = xmlElemNew(xmlConfigDoc,"pageCacheSize"); break;
					case "pageCacheTTL": tmpXmlNode = xmlElemNew(xmlConfigDoc,"pageCacheTTL"); break;
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
			if(getBaseResourceTypes() neq "" or variables.stConfig.lstResourceTypes neq "") {
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
			}

			// ****** [renderTemplates] *****
			if(not structIsEmpty(variables.stConfig.renderTemplates)) {
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"renderTemplates") );
				
				for(key in variables.stConfig.renderTemplates) {
					for(thisKey in variables.stConfig.renderTemplates[key]) {
						tmpXmlNode = xmlElemNew(xmlConfigDoc,"renderTemplate");
						tmpXmlNode.xmlAttributes["name"] = thisKey;
						tmpXmlNode.xmlAttributes["type"] = key;
						tmpXmlNode.xmlAttributes["href"] = variables.stConfig.renderTemplates[key][thisKey].href;
						if(isBoolean(variables.stConfig.renderTemplates[key][thisKey].isDefault) and variables.stConfig.renderTemplates[key][thisKey].isDefault)
							tmpXmlNode.xmlAttributes["default"] = variables.stConfig.renderTemplates[key][thisKey].isDefault;
						tmpXmlNode.xmlText = variables.stConfig.renderTemplates[key][thisKey].description;
						ArrayAppend(xmlConfigDoc.xmlRoot.renderTemplates.xmlChildren, tmpXmlNode );
					}
				}
			}
			
			// ****** [contentRenderers] *****
			if(not structIsEmpty(variables.stConfig.contentRenderers)) {
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"contentRenderers") );
				
				for(thisKey in variables.stConfig.contentRenderers) {
					tmpXmlNode = xmlElemNew(xmlConfigDoc,"contentRenderer");
					tmpXmlNode.xmlAttributes["moduleType"] = thisKey;
					tmpXmlNode.xmlAttributes["path"] = variables.stConfig.contentRenderers[thisKey];
					ArrayAppend(xmlConfigDoc.xmlRoot.contentRenderers.xmlChildren, tmpXmlNode );
				}
			}

			// ****** [plugins] *****
			if(not structIsEmpty(variables.stConfig.plugins)) {
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"plugins") );
				
				for(thisKey in variables.stConfig.plugins) {
					tmpXmlNode = xmlElemNew(xmlConfigDoc,"plugin");
					tmpXmlNode.xmlAttributes["name"] = thisKey;
					tmpXmlNode.xmlAttributes["path"] = variables.stConfig.plugins[thisKey];
					ArrayAppend(xmlConfigDoc.xmlRoot.plugins.xmlChildren, tmpXmlNode );
				}
			}

			// ****** [resourceTypes] *****
			if(not structIsEmpty(variables.stConfig.resourceTypes)) {
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
			}

			// ****** [resourceLibrary] *****	
			if(arrayLen(variables.stConfig.resourceLibraryPaths) gt 0) {
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"resourceLibraryPaths") );
				for(i=1;i lte arrayLen(variables.stConfig.resourceLibraryPaths);i=i+1) {
					tmpXmlNode = xmlElemNew(xmlConfigDoc,"resourceLibraryPath");
					tmpXmlNode.xmlText = variables.stConfig.resourceLibraryPaths[i];
					ArrayAppend(xmlConfigDoc.xmlRoot.resourceLibraryPaths.xmlChildren, tmpXmlNode );
				}
			}
			
			// ***** [pageProperties] ******
			if(not structIsEmpty(variables.stConfig.pageProperties)) {
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"pageProperties") );
				
				for(thisKey in variables.stConfig.pageProperties) {
					tmpXmlNode = xmlElemNew(xmlConfigDoc,"property");
					tmpXmlNode.xmlAttributes["name"] = thisKey;
					tmpXmlNode.xmlAttributes["value"] = variables.stConfig.pageProperties[thisKey];
					ArrayAppend(xmlConfigDoc.xmlRoot.pageProperties.xmlChildren, tmpXmlNode );
				}
			}

			// ****** [resourceLibraryTypes] *****
			if(not structIsEmpty(variables.stConfig.resourceLibraryTypes)) {
				ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"resourceLibraryTypes") );
				
				for(thisKey in variables.stConfig.resourceLibraryTypes) {
					st = variables.stConfig.resourceLibraryTypes[thisKey];
					
					tmpXmlNode = xmlElemNew(xmlConfigDoc,"resourceLibraryType");
					tmpXmlNode.xmlAttributes["prefix"] = st.prefix;
					tmpXmlNode.xmlAttributes["path"] = st.path;
					
					for(k in st.properties) {
						tmpXmlNode2 = xmlElemNew(xmlConfigDoc,"property");
						tmpXmlNode2.xmlAttributes["name"] = st.properties[k].name;
						tmpXmlNode2.xmlAttributes["value"] = st.properties[k].value;
						ArrayAppend(tmpXmlNode.xmlChildren, tmpXmlNode2 );
					}
					
					ArrayAppend(xmlConfigDoc.xmlRoot.resourceLibraryTypes.xmlChildren, tmpXmlNode );
				}
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
		<cfreturn val(variables.stConfig.catalogCacheSize)>	
	</cffunction>

	<cffunction name="getCatalogCacheTTL" access="public" returntype="any" hint="Default TTL in minutes for content items on the catalog cache">
		<cfreturn val(variables.stConfig.catalogCacheTTL)>
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

	<cffunction name="getRenderTemplate" access="public" returntype="struct" hint="returns the location of the template that should be used to rendering a particular type of output">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfif structKeyExists( variables.stConfig.renderTemplates, arguments.type )>
			<cfif structKeyExists( variables.stConfig.renderTemplates[arguments.type], arguments.name )>
				<cfreturn variables.stConfig.renderTemplates[arguments.type][arguments.name]>
			<cfelse>
				<cfthrow message="Unknown render template name" type="homePortals.config.invalidRenderTemplateName">
			</cfif>
		<cfelse>
			<cfthrow message="Unknown render template type" type="homePortals.config.invalidRenderTemplateType">
		</cfif>
	</cffunction>

	<cffunction name="getRenderTemplates" access="public" returntype="struct" hint="returns a key-value map with all declared render templates">
		<cfreturn duplicate(variables.stConfig.renderTemplates)>
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

	<cffunction name="getPageProperty" access="public" returntype="any" hint="returns the value for a given page property, if exists">
		<cfargument name="name" type="string" required="true">
		<cfif structKeyExists( variables.stConfig.pageProperties, arguments.name )>
			<cfreturn variables.stConfig.pageProperties[arguments.name]>
		<cfelse>
			<cfthrow message="Unknown page property" type="homePortals.config.invalidPageProperty">
		</cfif>
	</cffunction>	

	<cffunction name="getPageProperties" access="public" returntype="struct" hint="returns a key-value map with all declared page properties and their values">
		<cfreturn duplicate(variables.stConfig.pageProperties)>
	</cffunction>	
	
	<cffunction name="getResourceLibraryTypes" access="public" returntype="struct" hint="returns a key-value map with all custom resourcelibrary types">
		<cfreturn duplicate(variables.stConfig.resourceLibraryTypes)>
	</cffunction>		
		
	<cffunction name="getMemento" access="public" returntype="struct" hint="returns a struct with a copy of all settings">
		<cfreturn duplicate(variables.stConfig)>
	</cffunction>
	
	
	<!--- Setters --->
	<cffunction name="setVersion" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.version = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setInitialEvent" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.initialEvent = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setHomePortalsPath" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.homePortalsPath = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setResourceLibraryPath" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.resourceLibraryPaths[1] = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setDefaultPage" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.defaultPage = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setAppRoot" access="public" returnType="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.appRoot = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setContentRoot" access="public" returnType="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.contentRoot = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setPageCacheSize" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.pageCacheSize = arguments.data>	
		<cfreturn this>
	</cffunction>

	<cffunction name="setPageCacheTTL" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.pageCacheTTL = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setCatalogCacheSize" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.CatalogCacheSize = arguments.data>
		<cfreturn this>	
	</cffunction>

	<cffunction name="setCatalogCacheTTL" access="public" returntype="homePortalsConfigBean">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.CatalogCacheTTL = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setBaseResourceTypes" access="public" returnType="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.baseResourceTypes = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="addBaseResource" access="public" returntype="homePortalsConfigBean">
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
		
		<cfreturn this>
	</cffunction>

	<cffunction name="removeBaseResource" access="public" returntype="homePortalsConfigBean">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfset var aTmp = arrayNew(1)>
		<cfset var i = 0>
		<cfif structKeyExists(variables.stConfig.resources, arguments.type)>
			<cfset aTmp = variables.stConfig.resources[arguments.type]>
			<cfloop from="1" to="#arrayLen(aTmp)#" index="i">
				<cfif aTmp[i] eq arguments.href>
					<cfset arrayDeleteAt(variables.stConfig.resources[arguments.type], i)>
					<cfreturn this>
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setRenderTemplate" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="isDefault" type="boolean" required="false" default="false">
		
		<cfif not structKeyExists(variables.stConfig.renderTemplates, arguments.type)>
			<cfset variables.stConfig.renderTemplates[arguments.type] = structNew()>
		</cfif>
		<cfset variables.stConfig.renderTemplates[arguments.type][arguments.name] = {
																						name = arguments.name,
																						type = arguments.type,
																						href = arguments.href,
																						description = arguments.description,
																						isDefault = arguments.isdefault
																					}>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeRenderTemplate" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfif structKeyExists(variables.stConfig.renderTemplates, arguments.type)>
			<cfset structDelete(variables.stConfig.renderTemplates[arguments.type], arguments.name, false)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="setPageProviderClass" access="public" returnType="homePortalsConfigBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.pageProviderClass = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="setContentRenderer" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfset variables.stConfig.contentRenderers[arguments.name] = arguments.path>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeContentRenderer" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.stConfig.contentRenderers, arguments.name, false)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setPlugin" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfif arguments.path neq "">
			<cfset variables.stConfig.plugins[arguments.name] = arguments.path>
		<cfelseif structKeyExists(variables.stConfig.plugins, arguments.name)>
			<cfset structDelete(variables.stConfig.plugins, arguments.name)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="removePlugin" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.stConfig.plugins, arguments.name, false)>
		<cfreturn this>
	</cffunction>

	<cffunction name="setResourceType" access="public" returntype="homePortalsConfigBean">
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
		<cfreturn this>
	</cffunction>

	<cffunction name="setResourceTypeProperty" access="public" returntype="homePortalsConfigBean">
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
		
		<cfreturn this>
	</cffunction>

	<cffunction name="removeResourceType" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.stConfig.resourceTypes, arguments.name, false)>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeResourceTypeProperty" access="public" returntype="homePortalsConfigBean">
		<cfargument name="resType" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfset var aProps = variables.stConfig.resourceTypes[arguments.resType].properties>
		<cfloop from="1" to="#arrayLen(aProps)#" index="i">
			<cfif aProps[i].name eq arguments.name>
				<cfset arrayDeleteAt(variables.stConfig.resourceTypes[arguments.resType].properties, i)>
				<cfreturn this>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>
		
	<cffunction name="addResourceLibraryPath" access="public" returntype="homePortalsConfigBean">
		<cfargument name="path" type="string" required="true">
		<cfset arrayAppend(variables.stConfig.resourceLibraryPaths, arguments.path)>
		<cfreturn this>
	</cffunction>	

	<cffunction name="removeResourceLibraryPath" access="public" returntype="homePortalsConfigBean">
		<cfargument name="path" type="string" required="true">
		<cfset var i = 0>
		<cfloop from="1" to="#arrayLen(variables.stConfig.resourceLibraryPaths)#" index="i">
			<cfif variables.stConfig.resourceLibraryPaths[i] eq arguments.path>
				<cfset arrayDeleteAt(variables.stConfig.resourceLibraryPaths, i)>
				<cfreturn this>
			</cfif>
		</cfloop>
		<cfreturn this>
	</cffunction>	

	<cffunction name="setPageProperty" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="any" required="true">
		<cfset variables.stConfig.pageProperties[arguments.name] = arguments.value>
		<cfreturn this>
	</cffunction>

	<cffunction name="removePageProperty" access="public" returntype="homePortalsConfigBean">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.stConfig.pageProperties, arguments.name, false)>
		<cfreturn this>
	</cffunction>

	<cffunction name="hasPageProperty" access="public" returntype="boolean">
		<cfargument name="name" type="string" required="true">
		<cfreturn structKeyExists(variables.stConfig.pageProperties, arguments.name)>
	</cffunction>

	<cffunction name="setResourceLibraryType" access="public" returntype="homePortalsConfigBean">
		<cfargument name="prefix" type="string" required="true">
		<cfargument name="path" type="string" required="true">
		<cfif not structKeyExists(variables.stConfig.resourceLibraryTypes, arguments.prefix)>
			<cfset variables.stConfig.resourceLibraryTypes[arguments.prefix] = structNew()>
			<cfset variables.stConfig.resourceLibraryTypes[arguments.prefix].prefix = arguments.prefix>
			<cfset variables.stConfig.resourceLibraryTypes[arguments.prefix].properties = structNew()>
		</cfif>
		<cfset variables.stConfig.resourceLibraryTypes[arguments.prefix].path = arguments.prefix>
		<cfreturn this>
	</cffunction>

	<cffunction name="setResourceLibraryTypeProperty" access="public" returntype="homePortalsConfigBean">
		<cfargument name="prefix" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfset variables.stConfig.resourceLibraryTypes[arguments.prefix].properties[arguments.name] = structNew()>
		<cfset variables.stConfig.resourceLibraryTypes[arguments.prefix].properties[arguments.name].name = arguments.name>
		<cfset variables.stConfig.resourceLibraryTypes[arguments.prefix].properties[arguments.name].value = arguments.value>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeResourceLibraryType" access="public" returntype="homePortalsConfigBean">
		<cfargument name="prefix" type="string" required="true">
		<cfset structDelete(variables.stConfig.resourceLibraryTypes, arguments.prefix, false)>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeResourceLibraryTypeProperty" access="public" returntype="homePortalsConfigBean">
		<cfargument name="prefix" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfif structKeyExists(variables.stConfig.resourceLibraryTypes, arguments.prefix)>
			<cfset structDelete(variables.stConfig.resourceLibraryTypes[arguments.prefix].properties, arguments.name, false)>
		</cfif>
		<cfreturn this>
	</cffunction>

	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

</cfcomponent>