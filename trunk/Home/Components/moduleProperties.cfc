<cfcomponent name="moduleProperties" hint="This component retrieves and stored module properties for an applications">

	<cfscript>
		variables.storeVarName = "_hpModuleProperties";
		variables.propsFileName = "module-properties.xml";  // name of the properties file, must be located on the Config directory of either the application or the engine
	</cfscript>

	<cffunction name="init" access="public" returntype="moduleProperties">
		<cfargument name="loadProperties" type="boolean" required="false" default="false" hint="Flag to force loading the properties file. If set to true then the application root must be provided">
		<cfargument name="appRoot" type="string" required="false" default="true" hint="Path to the application root">

		<cfif arguments.loadProperties>
			<cfif arguments.appRoot eq "">
				<cfthrow message="Appplication root cannot be empty" type="homePortals.moduleProperties.applicationRootMissing">
			</cfif>
			
			<!--- clear any existing module properties --->
			<cfset application[variables.storeVarName] = structNew()>
			
			<!--- load properties --->
			<cfset loadPropertiesFile(arguments.appRoot)>
		</cfif>
	
		<cfreturn this>
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="struct" hint="Returns module properties for the given module">
		<cfargument name="moduleName" required="true" type="string" hint="module name as declared on the resource descriptor file">
	
		<cfset var st = structNew()>

		<cfif structKeyExists(application, variables.storeVarName)>
			<cfif structKeyExists(application[variables.storeVarName], arguments.moduleName)>
				<cfset st = application[variables.storeVarName][arguments.moduleName]>
			</cfif>
		<cfelse>
			<cfthrow message="Module properties not initialized" type="homePortals.moduleProperties.notInitialized">
		</cfif>

		<cfreturn st>
	</cffunction>	
	
	<cffunction name="getAllProperties" access="public" returntype="struct" hint="Returns module properties for all modules">
		<cfset var st = structNew()>

		<cfif structKeyExists(application, variables.storeVarName)>
			<cfset st = application[variables.storeVarName]>
		<cfelse>
			<cfthrow message="Module properties not initialized" type="homePortals.moduleProperties.notInitialized">
		</cfif>

		<cfreturn st>
	</cffunction>	



	
	<cffunction name="loadPropertiesFile" access="private" returntype="void" hint="load the properties file">
		<cfargument name="appRoot" type="string" required="true" hint="Path to the application root">
	
		<cfscript>
			var tmpPropsFile = "";
			var xmlPropsDoc = 0;
			var stProperties = structNew();
			var tmpNode = 0;
			var i = 0;
			var j = 0;
			var pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");

			// initialize module properties structure
			application[variables.storeVarName] = duplicate(stProperties);

			// get location of module properties file for the application
			tmpPropsFile = arguments.appRoot & "/Config/" & variables.propsFileName;
			tmpPropsFile = expandPath(tmpPropsFile);
			
			if(not fileExists(tmpPropsFile)) {
				// application doesn't have a module-properties.xml file,
				// so let's see if there is one on the main config directory
				
				tmpPropsFile = getDirectoryFromPath(getCurrentTemplatePath()) & pathSeparator & ".." & pathSeparator & "Config" & pathSeparator & variables.propsFileName;
				
				if(not fileExists(tmpPropsFile)) {
					// there is no module properties file to load
					tmpPropsFile = "";
				}
			}

			// If we found a properties file the load it
			if(tmpPropsFile neq "") {
				// read file and convert to xml object
				xmlPropsDoc = xmlParse(tmpPropsFile);
				
				// parse xml and conver to structure
				for(i=1;i lte arrayLen(xmlPropsDoc.xmlRoot.xmlChildren);i=i+1) {
					tmpNode = xmlPropsDoc.xmlRoot.xmlChildren[i];
					if(tmpNode.xmlName eq "module") {
						stProperties[tmpNode.xmlAttributes.name] = structNew();
						for(j=1;j lte arrayLen(tmpNode.xmlChildren);j=j+1) {
							if(tmpNode.xmlChildren[j].xmlName eq "property") {
								stProperties[tmpNode.xmlAttributes.name][tmpNode.xmlChildren[j].xmlAttributes.name] = tmpNode.xmlChildren[j].xmlAttributes.value;
							}		
						}
					}
				}
				
				// copy properties structure to application scope for persistence
				application[variables.storeVarName] = duplicate(stProperties);
			} 
		</cfscript>	
	</cffunction>

</cfcomponent>