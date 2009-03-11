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
			variables.stConfig.resourceLibraryPath = "";
			variables.stConfig.defaultPage = "";
			variables.stConfig.appRoot = "";
			variables.stConfig.contentRoot = "";
			variables.stConfig.pageCacheSize = "";
			variables.stConfig.pageCacheTTL = "";
			variables.stConfig.contentCacheSize = "";
			variables.stConfig.contentCacheTTL = "";
			variables.stConfig.rssCacheSize = "";
			variables.stConfig.rssCacheTTL = "";
			variables.stConfig.baseResourceTypes = "";
			variables.stConfig.pageProviderClass = "";

			variables.stConfig.renderTemplates = structNew();
			variables.stConfig.resources = structNew();
			variables.stConfig.contentRenderers = structNew();
			
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
			var j = 0;
			var xmlThisNode = 0;
			
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
						if(Not structKeyExists(xmlThisNode.xmlAttributes,"type"))
							throw("HomePortals config file is malformed. Missing TYPE attribute for baseResource","","homePortals.config.configFileNotValid");
						if(Not structKeyExists(variables.stConfig.resources, xmlThisNode.xmlAttributes.type)) 
							variables.stConfig.resources[xmlThisNode.xmlAttributes.type] = ArrayNew(1);
						ArrayAppend(variables.stConfig.resources[xmlThisNode.xmlAttributes.type], xmlThisNode.xmlAttributes.href);
						
					}

				} else if(xmlNode.xmlName eq "renderTemplates") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						variables.stConfig.renderTemplates[ xmlNode.xmlChildren[j].xmlAttributes.type ] = xmlNode.xmlChildren[j].xmlAttributes.href;
					}

				} else if(xmlNode.xmlName eq "contentRenderers") {
		
					for(j=1;j lte ArrayLen(xmlNode.xmlChildren);j=j+1) {
						variables.stConfig.contentRenderers[ xmlNode.xmlChildren[j].xmlAttributes.moduleType ] = xmlNode.xmlChildren[j].xmlAttributes.path;
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
			var backupFileName = "";
			var lstResourceTypes = getBaseResourceTypes();
			var lstKeys = "";
			var i = 1;
			var j = 1;
			var thisKey = "";
			var thisResourceType = "";
			var tmpXmlNode = 0;
			var lstKeysIgnore = "version,renderTemplates,resources";

			// create a blank xml document and add the root node
			xmlConfigDoc = xmlNew();
			xmlConfigDoc.xmlRoot = xmlElemNew(xmlConfigDoc, "homePortals");		
			xmlConfigDoc.xmlRoot.xmlAttributes["version"] = variables.stConfig.version;
			
			// save simple value settings
			lstKeys = structKeyList(variables.stConfig);

			for(i=1;i lte ListLen(lstKeys);i=i+1) {
				thisKey = ListGetAt(lstKeys,i);
				if(not listFindNoCase(lstKeysIgnore, thisKey)) {
					tmpXmlNode = xmlElemNew(xmlConfigDoc,thisKey);
					tmpXmlNode.xmlText = variables.stConfig[thisKey];
					arrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, tmpXmlNode);
				}	
			}
			
			
			// ****** [baseResources] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"baseResources") );
			
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

	<cffunction name="getResourceLibraryPath" access="public" returntype="string" hint="The path to the root where all resources are stored">
		<cfreturn variables.stConfig.resourceLibraryPath>
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

	<cffunction name="getPageCacheSize" access="public" returntype="numeric" hint="The maximum number of homeportals pages to cache at any given time">
		<cfreturn val(variables.stConfig.pageCacheSize)>	
	</cffunction>

	<cffunction name="getPageCacheTTL" access="public" returntype="numeric" hint="The maximum amount in minutes before an unchanged page is expelled from the cache.">
		<cfreturn val(variables.stConfig.pageCacheTTL)>
	</cffunction>

	<cffunction name="getContentCacheSize" access="public" returntype="numeric" hint="The maximum number of items to hold in the content cache">
		<cfreturn val(variables.stConfig.contentCacheSize)>	
	</cffunction>

	<cffunction name="getContentCacheTTL" access="public" returntype="numeric" hint="Default TTL in minutes for content items on the content cache. This can be overriden for individual entries">
		<cfreturn val(variables.stConfig.contentCacheTTL)>
	</cffunction>

	<cffunction name="getRSSCacheSize" access="public" returntype="numeric" hint="The maximum number of items to hold in the RSS cache">
		<cfreturn val(variables.stConfig.rssCacheSize)>	
	</cffunction>

	<cffunction name="getRSSCacheTTL" access="public" returntype="numeric" hint="Default TTL in minutes for content items on the RSS cache. This can be overriden for individual entries">
		<cfreturn val(variables.stConfig.rssCacheTTL)>
	</cffunction>

	<cffunction name="getBaseResourceTypes" access="public" returntype="string" hint="List with allowed types of base resources">
		<cfreturn variables.stConfig.baseResourceTypes>
	</cffunction>	

	<cffunction name="getBaseResourcesByType" access="public" returntype="array" hint="Returns all base resources of the given type">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var aResources = arrayNew(1)>
		<cfif listFindNoCase(variables.stConfig.baseResourceTypes, arguments.resourceType) and structKeyExists( variables.stConfig.resources, arguments.resourceType )>
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
		<cfset variables.stConfig.resourceLibraryPath = arguments.data>
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

	<cffunction name="setContentCacheSize" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.contentCacheSize = arguments.data>	
	</cffunction>

	<cffunction name="setContentCacheTTL" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.contentCacheTTL = arguments.data>
	</cffunction>

	<cffunction name="setRSSCacheSize" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.rssCacheSize = arguments.data>	
	</cffunction>

	<cffunction name="setRSSCacheTTL" access="public" returntype="void">
		<cfargument name="data" type="numeric" required="true">
		<cfset variables.stConfig.rssCacheTTL = arguments.data>
	</cffunction>

	<cffunction name="setBaseResourceTypes" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.baseResourceTypes = arguments.data>
	</cffunction>

	<cffunction name="addBaseResource" access="public" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		
		<cfif listFindNoCase(variables.stConfig.baseResourceTypes, arguments.type)>
			<cfif not structKeyExists(variables.stConfig.resources, arguments.type)>
				<cfset variables.stConfig.resources[arguments.type] = arrayNew(1)>
			</cfif>
			<cfset arrayAppend(variables.stConfig.resources[arguments.type], arguments.href)>
		<cfelse>
			<cfthrow message="Resource type not allowed" type="homePortals.config.invalidBaseResourceType">		
		</cfif>
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

	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

</cfcomponent>