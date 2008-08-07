<cfcomponent displayname="accountsConfigBean" hint="A bean to store the HomePortals accounts configuration. Configuration is per-application">

	<cfset variables.stConfig = StructNew()>
	<cfset variables.configKeys = "accountsRoot,newAccountTemplate,newPageTemplate,storageType,datasource,username,password,dbtype">

	<cffunction name="init" access="public" returntype="accountsConfigBean">
		<cfargument name="configFilePath" type="string" required="false" default="" 
					hint="The relative address of the config file. If not empty, then loads the config from the file">
		<cfscript>
			variables.stConfig = structNew();
			variables.stConfig.accountsRoot = "";
			variables.stConfig.newAccountTemplate = "";
			variables.stConfig.newPageTemplate = "";
			variables.stConfig.storageType = "xml";
			variables.stConfig.datasource = "";
			variables.stConfig.username = "";
			variables.stConfig.password = "";
			variables.stConfig.dbtype = "";
						
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
			var tmpXML = "";
			var xmlConfigDoc = 0;
			var i = 0;
			var xmlNode = 0;
			var tmpString = "";
		
			// read configuration file
			if(Not fileExists(arguments.configFilePath))
				throw("Configuration file not found [#configFilePath#]","","homePortals.accountsConfig.configFileNotFound");
			else
				xmlConfigDoc = xmlParse(arguments.configFilePath);
							
			for(i=1;i lte ArrayLen(xmlConfigDoc.xmlRoot.xmlChildren);i=i+1) {
				// get poiner to current node
				xmlNode = xmlConfigDoc.xmlRoot.xmlChildren[i];
				tmpString = xmlUnformat(xmlNode.xmlText);
				variables.stConfig[xmlNode.xmlName] = tmpString;
			}
		</cfscript>
	</cffunction>
		
	<cffunction name="toXML" access="public" returnType="xml" hint="Returns the bean settings as an XML document">
		<cfscript>
			var xmlConfigDoc = "";
			var backupFileName = "";
			var tmpString = "";
			var thisKey = "";
			var i = 0;

			// create a blank xml document and add the root node
			xmlConfigDoc = xmlNew();
			xmlConfigDoc.xmlRoot = xmlElemNew(xmlConfigDoc, "homePortalsAccounts");		
			
			// save simple value settings
			for(i=1;i lte ListLen(configKeys);i=i+1) {
				thisKey = ListGetAt(configKeys,i);
				tmpString = "";

				arrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, xmlElemNew(xmlConfigDoc,thisKey));

				if(structKeyExists(variables.stConfig,thisKey))
					tmpString = variables.stConfig[thisKey];

				xmlConfigDoc.xmlRoot[thisKey].xmlText = xmlFormat(tmpString);
			}
			
			return xmlConfigDoc;
		</cfscript>		
	</cffunction>
	
	<!--- Getters --->
	<cffunction name="getAccountsRoot" access="public" returntype="string">
		<cfreturn variables.stConfig.accountsRoot>
	</cffunction>

	<cffunction name="getNewAccountTemplate" access="public" returntype="string">
		<cfreturn variables.stConfig.newAccountTemplate>
	</cffunction>

	<cffunction name="getNewPageTemplate" access="public" returntype="string">
		<cfreturn variables.stConfig.newPageTemplate>
	</cffunction>

	<cffunction name="getStorageType" access="public" returntype="string">
		<cfreturn variables.stConfig.storageType>
	</cffunction>

	<cffunction name="getDatasource" access="public" returntype="string">
		<cfreturn variables.stConfig.datasource>
	</cffunction>
	
	<cffunction name="getUsername" access="public" returntype="string">
		<cfreturn variables.stConfig.username>
	</cffunction>
	
	<cffunction name="getPassword" access="public" returntype="string">
		<cfreturn variables.stConfig.password>
	</cffunction>

	<cffunction name="getDBType" access="public" returntype="string">
		<cfreturn variables.stConfig.dbtype>
	</cffunction>
	

	<!--- Setters --->
	<cffunction name="setAccountsRoot" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.accountsRoot = arguments.data>
	</cffunction>

	<cffunction name="setNewAccountTemplate" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.newAccountTemplate = arguments.data>
	</cffunction>

	<cffunction name="setNewPageTemplate" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.newPageTemplate = arguments.data>
	</cffunction>

	<cffunction name="setStorageType" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.storageType = arguments.data>
	</cffunction>

	<cffunction name="setDatasource" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.datasource = arguments.data>
	</cffunction>
	
	<cffunction name="setUsername" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.username = arguments.data>
	</cffunction>
	
	<cffunction name="setPassword" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.password = arguments.data>
	</cffunction>

	<cffunction name="setDBType" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.stConfig.dbtype = arguments.data>
	</cffunction>
	


	<cffunction name="XMLUnFormat" access="private" returntype="string">
		<cfargument name="string" type="string" default="">
		<cfscript>
			var resultString=arguments.string;
			resultString=ReplaceNoCase(resultString,"&apos;","'","ALL");
			resultString=ReplaceNoCase(resultString,"&quot;","""","ALL");
			resultString=ReplaceNoCase(resultString,"&lt;","<","ALL");
			resultString=ReplaceNoCase(resultString,"&gt;",">","ALL");
			resultString=ReplaceNoCase(resultString,"&amp;","&","ALL");
		</cfscript>
		<cfreturn resultString>
	</cffunction>			
	
	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>	
</cfcomponent>