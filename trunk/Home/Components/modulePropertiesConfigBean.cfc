<cfcomponent displayname="modulePropertiesConfigBean" hint="A bean to store the module properties.">

	<cfset variables.stConfig = StructNew()>

	<cffunction name="init" access="public" returntype="modulePropertiesConfigBean" hint="This is the constructor. If a path to a config file is given, then config is read from file">
		<cfargument name="configFilePath" type="string" required="false" default="" 
					hint="The relative address of the config file. If not empty, then loads the config from the file">
		<cfscript>
			variables.stConfig = structNew();
						
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
			var xmlConfigDoc = 0;
			var i = 0; var j = 0;
			var xmlNode = 0;
		
			// read configuration file
			if(Not fileExists(arguments.configFilePath))
				throw("Configuration file not found [#configFilePath#]","","homePortals.modulePropertiesConfigBean.configFileNotFound");
			else
				xmlConfigDoc = xmlParse(arguments.configFilePath);
							
			// parse xml and conver to structure
			for(i=1;i lte arrayLen(xmlConfigDoc.xmlRoot.xmlChildren);i=i+1) {
				xmlNode = xmlConfigDoc.xmlRoot.xmlChildren[i];

				if(xmlNode.xmlName eq "module") {
					// create struct to hold this module's properties
					variables.stConfig[xmlNode.xmlAttributes.name] = structNew();

					for(j=1;j lte arrayLen(xmlNode.xmlChildren);j=j+1) {
						if(xmlNode.xmlChildren[j].xmlName eq "property") {
							variables.stConfig[xmlNode.xmlAttributes.name][xmlNode.xmlChildren[j].xmlAttributes.name] = xmlNode.xmlChildren[j].xmlAttributes.value;
						}		
					}
				}
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
			xmlConfigDoc.xmlRoot = xmlElemNew(xmlConfigDoc, "moduleProperties");		
			
			// save simple value settings
			for(thisKey in variables.stConfig) {
				
				xmlNode = xmlElemNew(xmlConfigDoc,"module");
				xmlNode.xmlAttributes["name"] = thisKey;

				for(prop in variables.stConfig[thisKey]) {
					xmlNode2 = xmlElemNew(xmlConfigDoc,"property");
					xmlNode2.xmlAttributes["name"] = prop; 					
					xmlNode2.xmlAttributes["value"] = variables.stConfig[thisKey][prop];
					arrayAppend(xmlNode.xmlChildren, xmlNode2);
				}

				arrayAppend(xmlConfigDoc.xmlRoot.xmlChildren, xmlNode);
			}
			
			return xmlConfigDoc;
		</cfscript>		
	</cffunction>

	<cffunction name="addProperty" access="public" returntype="void" hint="Adds a property for a module">
		<cfargument name="moduleName" type="string" required="true">
		<cfargument name="propertyName" type="string" required="true">
		<cfargument name="propertyValue" type="string" required="true">
		
		<!--- create struct for this module if not exists --->
		<cfif Not structKeyExists(variables.stConfig, arguments.moduleName)>
			<cfset variables.stConfig[arguments.moduleName] = structNew()>
		</cfif>
		
		<!--- set property --->
		<cfset variables.stConfig[arguments.moduleName][arguments.propertyName] = arguments.propertyValue>
	</cffunction>

	<cffunction name="removeProperty" access="public" returntype="void" hint="Removes a property entry for a module">
		<cfargument name="moduleName" type="string" required="true">
		<cfargument name="propertyName" type="string" required="true">
		<cfif structKeyExists(variables.stConfig, arguments.moduleName)>
			<cfset structDelete(variables.stConfig[arguments.moduleName], arguments.PropertyName, false)>
		</cfif>
	</cffunction>

	<cffunction name="getProperty" access="public" returntype="string" hint="Returns the value of the given property for a module">
		<cfargument name="moduleName" type="string" required="true">
		<cfargument name="propertyName" type="string" required="true">
		<cfif structKeyExists(variables.stConfig, arguments.moduleName) and structKeyExists(variables.stConfig[arguments.moduleName], arguments.propertyName)>
			<cfreturn variables.stConfig[arguments.moduleName][arguments.propertyName]>
		<cfelse>
			<cfthrow message="Module property not found" type="homePortals.modulePropertiesConfigBean.propertyNotFound">
		</cfif>
	</cffunction>

	<cffunction name="getModuleProperties" access="public" returntype="struct" hint="Returns a structure with all the name/value pairs for the properties of the given module. If the module doesnt have any properties then returns an empty struct.">
		<cfargument name="moduleName" type="string" required="true">
		<cfif structKeyExists(variables.stConfig, arguments.moduleName)>
			<cfreturn duplicate(variables.stConfig[arguments.moduleName])>
		<cfelse>
			<cfreturn structNew()>
		</cfif>
	</cffunction>

	<cffunction name="removeModuleProperties" access="public" returntype="void" hint="Removes all properties for the given module">
		<cfargument name="moduleName" type="string" required="true">
		<cfset structDelete(variables.stConfig, arguments.moduleName, false)>
	</cffunction>

</cfcomponent>	