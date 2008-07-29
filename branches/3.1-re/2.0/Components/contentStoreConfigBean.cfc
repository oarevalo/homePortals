<cfcomponent displayname="contentStoreConfigBean" 
				extends="configBean"
				hint="Represents the configuration properties for a content store.">

	<cfscript>
		variables.data.accountsRoot = "/Accounts";
		variables.data.defaultName = "myContentStore.xml";
		variables.data.description = "";
		variables.data.rootNode = "dataStore";
		variables.data.url = "";
		variables.data.createStorage = true;
	</cfscript>

	<!---------------------------------------->
	<!---- 		ACCESSORS 				  ---->
	<!---------------------------------------->
	<cffunction name="getAccountsRoot" returntype="any" access="public">
		<cfreturn variables.data.accountsRoot>
	</cffunction>

	<cffunction name="getDefaultName" returntype="any" access="public">
		<cfreturn variables.data.defaultName>
	</cffunction>

	<cffunction name="getDescription" returntype="any" access="public">
		<cfreturn variables.data.description>
	</cffunction>

	<cffunction name="getRootNode" returntype="any" access="public">
		<cfreturn variables.data.rootNode>
	</cffunction>

	<cffunction name="getURL" returntype="any" access="public">
		<cfreturn variables.data.url>
	</cffunction>

	<cffunction name="getCreateStorage" returntype="any" access="public">
		<cfreturn variables.data.createStorage>
	</cffunction>


	<!---------------------------------------->
	<!---- 		MUTATORS 				  ---->
	<!---------------------------------------->
	<cffunction name="setAccountsRoot" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.accountsRoot = arguments.data>
	</cffunction>

	<cffunction name="setDefaultName" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.defaultName = arguments.data>
	</cffunction>

	<cffunction name="setDescription" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.description = arguments.data>
	</cffunction>

	<cffunction name="setRootNode" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.rootNode = arguments.data>
	</cffunction>

	<cffunction name="setURL" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.url = arguments.data>
	</cffunction>	
	
	<cffunction name="setCreateStorage" access="public">
		<cfargument name="data" required="true">
		<cfset variables.data.createStorage = arguments.data>
	</cffunction>		
</cfcomponent>	