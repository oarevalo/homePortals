<cfcomponent displayName="configBeanStore" hint="This component provides an interface for persistent storage of configBeans data">

	<cfset variables.storeVarName = "_hpModuleConfigBeans">

	<cfif Not StructKeyExists(session, variables.storeVarName)>
		<cfset session[variables.storeVarName] = structNew()>
	</cfif>

	<!---------------------------------------->
	<!--- load		                       --->
	<!---------------------------------------->		
	<cffunction name="load" access="public" returnType="configBean"
				hint="Retrieves a configBean from the persisten storage">
		<cfargument name="key" required="true" hint="Key used to identify the config bean">
		<cfargument name="configBean" required="true" type="configBean" hint="Empty configBean that will be populated with the loaded data">
	
		<cfset var tmpData = "">
		<cfif structKeyExists(session[variables.storeVarName], arguments.key)>
			<cfset tmpData = session[variables.storeVarName][arguments.key]>
			<cfset arguments.configBean.deserialize(tmpData)>
		</cfif>
		
		<cfreturn arguments.configBean>
	</cffunction>

	<!---------------------------------------->
	<!--- save		                       --->
	<!---------------------------------------->		
	<cffunction name="save" access="public"
				hint="Stores a configBean into the persistent storage">
		<cfargument name="key" required="true" hint="Key used to identify the config bean">
		<cfargument name="configBean" required="true" type="configBean" hint="Empty configBean that will be populated with the loaded data">
		<cfset var tmpData = "">
		<cfset tmpData = arguments.configBean.serialize()>
		<cfset session[variables.storeVarName][arguments.key] = tmpData>
	</cffunction>

	<!---------------------------------------->
	<!--- exists	                       --->
	<!---------------------------------------->		
	<cffunction name="exists" access="public"
				hint="Checks if given configBean exists on the persistent storage">
		<cfargument name="key" required="true" hint="Key used to identify the config bean">
		<cfreturn structKeyExists(session[variables.storeVarName], arguments.key)>
	</cffunction>

	<!---------------------------------------->
	<!--- flush		                       --->
	<!---------------------------------------->		
	<cffunction name="flush" access="public"
				hint="Flushs a configBean from the persistent storage">
		<cfargument name="key" required="true" hint="Key used to identify the config bean">
		<cfset structDelete(session[variables.storeVarName], arguments.key, false)>
	</cffunction>

	<!---------------------------------------->
	<!--- flushAll	                       --->
	<!---------------------------------------->		
	<cffunction name="flushAll" access="public"
				hint="Flushes all configBeans from the persistent storage">
		<cfset structDelete(session, variables.storeVarName, false)>
	</cffunction>
	
</cfcomponent>