<cfcomponent displayname="homePortalsConfigBean" hint="A bean to store the HomePortals configuration. Configuration is per-application">

	<cfset variables.stConfig = StructNew()>
	<cfset variables.hpEngineBaseVersion = "3.0.x">
	<cfset variables.stRenderTemplatesCache = structNew()>

	<cffunction name="init" access="public" returntype="homePortalsConfigBean">
		<cfargument name="configFilePath" type="string" required="false" default="" 
					hint="The relative address of the config file. If not empty, then loads the config from the file">
		<cfscript>
			variables.stConfig = structNew();
			variables.stConfig.version = variables.hpEngineBaseVersion;
			variables.stConfig.initialEvent = "";
			variables.stConfig.layoutSections = "";
			variables.stConfig.defaultPage = "";
			variables.stConfig.bodyOnLoad = "";
			variables.stConfig.homePortalsPath = "";
			variables.stConfig.resourceLibraryPath = "";
			variables.stConfig.defaultAccount = "";
			variables.stConfig.SSLRoot = "";		
			variables.stConfig.appRoot = "";
			variables.stConfig.accountsRoot = "";
			variables.stConfig.pageCacheSize = "";
			variables.stConfig.pageCacheTTL = "";
			variables.stConfig.contentCacheSize = "";
			variables.stConfig.contentCacheTTL = "";

			variables.stConfig.moduleIcons = ArrayNew(1);

			variables.stConfig.renderTemplates = structNew();

			variables.stConfig.resources = structNew();
			variables.stConfig.resources.script = ArrayNew(1);
			variables.stConfig.resources.style = ArrayNew(1);
			variables.stConfig.resources.header = ArrayNew(1);
			variables.stConfig.resources.footer = ArrayNew(1);
			
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
				
		
		</cfscript>	
	</cffunction>

	<cffunction name="toXML" access="public" returnType="xml" hint="Returns the bean settings as an XML document">
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
			var tmpXmlNode = 0;

			// create a blank xml document and add the root node
			xmlConfigDoc = xmlNew();
			xmlConfigDoc.xmlRoot = xmlElemNew(xmlConfigDoc, "homePortals");		
			xmlConfigDoc.xmlRoot.xmlAttributes["version"] = variables.stConfig.version;
			
			// save simple value settings
			lstKeys = "initialEvent,layoutSections,defaultPage,bodyOnLoad,homePortalsPath,resourceLibraryPath,defaultAccount,SSLRoot,appRoot,accountsRoot,pageCacheSize,pageCacheTTL,contentCacheSize,contentCacheTTL";
			for(i=1;i lte ListLen(lstKeys);i=i+1) {
				thisKey = ListGetAt(lstKeys,i);

				tmpXmlNode = xmlElemNew(xmlConfigDoc,thisKey);
				tmpXmlNode.xmlText = variables.stConfig[thisKey];
				arrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, tmpXmlNode);
				
			}
			
			
			// ****** [baseResources] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"baseResources") );
			
			for(i=1;i lte ListLen(lstResourceTypes);i=i+1) {
				thisResourceType = ListGetAt(lstResourceTypes, i);
				
				for(j=1;j lte ArrayLen(variables.stConfig.resources[thisResourceType]);j=j+1) {
					ArrayAppend(xmlConfigDoc.xmlRoot.baseResources.xmlChildren, xmlElemNew(xmlConfigDoc,"resource") );
					tmpIndex = ArrayLen(xmlConfigDoc.xmlRoot.baseResources.xmlChildren);
					xmlConfigDoc.xmlRoot.baseResources.xmlChildren[tmpIndex].xmlAttributes["href"] = variables.stConfig.resources[thisResourceType][j];
					xmlConfigDoc.xmlRoot.baseResources.xmlChildren[tmpIndex].xmlAttributes["type"] = thisResourceType;
				}		

			}

			
			// ***** [moduleIcons] *****
			ArrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, XMLElemNew(xmlConfigDoc,"moduleIcons") );
			
			for(i=1;i lte ArrayLen(variables.stConfig.moduleIcons);i=i+1) {
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i] = xmlElemNew(xmlConfigDoc,"icon");
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i].xmlAttributes["alt"] = variables.stConfig.moduleIcons[i].alt;
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i].xmlAttributes["image"] = variables.stConfig.moduleIcons[i].image;
				xmlConfigDoc.xmlRoot.moduleIcons.xmlChildren[i].xmlAttributes["onClickFunction"] = variables.stConfig.moduleIcons[i].onClickFunction;
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

	<cffunction name="getDefaultPage" access="public" returntype="string">
		<cfreturn variables.stConfig.defaultPage>
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

	<cffunction name="getDefaultAccount" access="public" returntype="string">
		<cfreturn variables.stConfig.defaultAccount>
	</cffunction>

	<cffunction name="getSSLRoot" access="public" returntype="string">
		<cfreturn variables.stConfig.SSLRoot>
	</cffunction>

	<cffunction name="getAppRoot" access="public" returnType="string" hint="The root of the application">
		<cfreturn variables.stConfig.appRoot>
	</cffunction>

	<cffunction name="getAccountsRoot" access="public" returnType="string" hint="The path to the directory where account files are stored">
		<cfreturn variables.stConfig.accountsRoot>
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



	<cffunction name="getBaseResourcesByType" access="public" returntype="array">
		<cfargument name="resourceType" type="string" required="true">
		<cfset var aResources = arrayNew(1)>
		<cfif ListFindNoCase( structKeyList(variables.stConfig.resources), arguments.resourceType )>
			<cfset aResources = variables.stConfig.resources[arguments.resourceType]>
		</cfif>
		<cfreturn aResources>
	</cffunction>

	<cffunction name="getModuleIcons" access="public" returntype="array">
		<cfreturn variables.stConfig.moduleIcons>
	</cffunction>

	<cffunction name="getRenderTemplate" access="public" returntype="string" hint="returns the location of the template that should be used to rendering a particular type of output">
		<cfargument name="type" type="string" required="true">
		<cfif ListFindNoCase( structKeyList(variables.stConfig.renderTemplates), arguments.type )>
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
	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

</cfcomponent>