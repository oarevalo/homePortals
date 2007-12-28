<cfcomponent displayname="moduleConfigBean" 
			 extends="configBean"
			 hint="Represents the configuration properties for a module.">

	<cfscript>
		variables.data.defaultLayout = "";
		variables.data.moduleClassLocation = "";
		variables.data.moduleClassName = "module";
		variables.data.pageHREF = "";
		variables.data.stPageSettings = structNew();
		variables.data.stProperties = structNew();
		variables.data.stViews = structNew();
		variables.data.stViews.default = "";
		variables.data.stViews.htmlHead = "";
		variables.data.stViews.error = "";
		variables.data.moduleRoot = "";
	</cfscript>

	<!---- ACCESSORS ---->
	<cffunction name="getDefaultLayout" returntype="any" access="public">
		<cfreturn variables.data.defaultLayout>
	</cffunction>

	<cffunction name="getModuleClassLocation" returntype="any" access="public">
		<cfreturn variables.data.moduleClassLocation>
	</cffunction>

	<cffunction name="getModuleClassName" returntype="any" access="public">
		<cfreturn variables.data.moduleClassName>
	</cffunction>

	<cffunction name="getModuleRoot" returntype="any" access="public">
		<cfreturn variables.data.moduleRoot>
	</cffunction>
	
	<cffunction name="getPageHREF" returntype="any" access="public">
		<cfreturn variables.data.pageHREF>
	</cffunction>

	<cffunction name="getPageSettings" returntype="any" access="public">
		<cfreturn variables.data.stPageSettings>
	</cffunction>

	<cffunction name="getPageSetting" returntype="any" access="public">
		<cfargument name="key" required="true">
		<cfargument name="defaultValue" type="any" required="false" default="">

		<cfset var rtn = arguments.defaultValue>
		<cfif structKeyExists(variables.data.stPageSettings, arguments.key)>
			<cfset rtn = variables.data.stPageSettings[arguments.key]>
		</cfif>
		<cfreturn rtn>
	</cffunction>

	<cffunction name="getView" returntype="any" access="public">
		<cfargument name="key" required="true">
		<cfreturn variables.data.stViews[arguments.key]>
	</cffunction>

	<cffunction name="getProperty" returntype="any" access="public">
		<cfargument name="key" required="true">
		<cfargument name="defaultValue" type="any" required="false" default="">
		<cfset var rtn = arguments.defaultValue>
		<cfif structKeyExists(variables.data.stProperties, arguments.key)>
			<cfset rtn = variables.data.stProperties[arguments.key]>
		</cfif>
		<cfreturn rtn>
	</cffunction>



	<!---- MUTATORS ---->
	<cffunction name="setDefaultLayout" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.defaultLayout = arguments.data>
	</cffunction>

	<cffunction name="setModuleClassLocation" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.moduleClassLocation = arguments.data>
	</cffunction>

	<cffunction name="setModuleClassName" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.moduleClassName = arguments.data>
	</cffunction>

	<cffunction name="setModuleRoot" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.moduleRoot = arguments.data>
	</cffunction>
	
	<cffunction name="setPageHREF" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.pageHREF = arguments.data>
	</cffunction>

	<cffunction name="setPageSettings" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.stPageSettings = duplicate(arguments.data)>
	</cffunction>

	<cffunction name="setPageSetting" access="public">
		<cfargument name="key" required="true">
		<cfargument name="data" required="true">
		<cfset variables.data.stPageSettings[arguments.key] = arguments.data>
	</cffunction>

	<cffunction name="setView" access="public">
		<cfargument name="key" required="true">
		<cfargument name="data" required="true">
		<cfset variables.data.stViews[arguments.key] = arguments.data>
	</cffunction>

	<cffunction name="setProperty" access="public">
		<cfargument name="key" required="true">
		<cfargument name="data" required="true">
		<cfset variables.data.stProperties[arguments.key] = arguments.data>
	</cffunction>
</cfcomponent>