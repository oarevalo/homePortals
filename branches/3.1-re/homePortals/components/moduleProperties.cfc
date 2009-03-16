<cfcomponent name="moduleProperties" hint="This component retrieves and stored module properties for an applications">

	<cfscript>
		variables.configFileName = "module-properties.xml";
		variables.configFilePath = "config/" & variables.configFileName;  // path of the config file relative to the root of the application
		variables.oConfigBean = 0;	// bean to store config settings
	</cfscript>

	<cffunction name="init" access="public" returntype="moduleProperties" hint="Constructor. Loads module settings from config files. Properties defined on config directory in current application overwrite those defined on the central config directory">
		<cfargument name="configBean" type="homePortalsConfigBean" required="true" hint="HomePortals application settings">

		<cfscript>
			var pathSeparator =  createObject("java","java.lang.System").getProperty("file.separator");
			var defaultConfigFilePath = "";
			
			// create object to store configuration settings
			variables.oConfigBean = createObject("component", "modulePropertiesConfigBean").init();

			// load default configuration settings
			defaultConfigFilePath = getDirectoryFromPath(getCurrentTemplatePath()) & pathSeparator & ".." & pathSeparator & "Config" & pathSeparator & variables.configFileName;
			if(fileExists(defaultConfigFilePath))
				variables.oConfigBean.load(defaultConfigFilePath);

			// load configuration settings for the application
			configFilePath = listAppend(arguments.configBean.getAppRoot(), variables.configFilePath, "/");
			if(fileExists(expandPath(configFilePath)))
				variables.oConfigBean.load(expandPath(configFilePath));
		
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="getConfig" access="public" returntype="modulePropertiesConfigBean" 
				hint="Returns the effective module properties config bean for the application. This config bean contains any properties as the application sees them, properties may come from the config file in the application or the config file in the main Config dir in Home">
		<cfreturn variables.oConfigBean>
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="struct" hint="Returns module properties for the given module">
		<cfargument name="moduleName" required="true" type="string" hint="module name as declared on the resource descriptor file">
		<cfreturn variables.oConfigBean.getModuleProperties(arguments.moduleName)>
	</cffunction>	

	<cffunction name="getProperty" access="public" returntype="string" hint="Returns the value of the requested module property for the given module">
		<cfargument name="moduleName" required="true" type="string" hint="module name as declared on the resource descriptor file">
		<cfargument name="propertyName" required="true" type="string" hint="Name of the property">
		<cfreturn variables.oConfigBean.getProperty(arguments.moduleName, arguments.propertyName)>
	</cffunction>	

</cfcomponent>