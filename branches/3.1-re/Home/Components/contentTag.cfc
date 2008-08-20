<cfcomponent>

	<cfset variables.instance = structNew()>
	<cfset variables.instance.node = structNew()>

	<cffunction name="init" access="public" returntype="contentTag">
		<cfargument name="structNode" type="struct" required="true">
		<cfset variables.instance.node = duplicate(arguments.structNode)>
		<cfreturn this>
	</cffunction>

	<cffunction name="getAttribute" access="public" returntype="string">
		<cfargument name="attr" type="string" required="true">
		<cfreturn variables.instance.node[arguments.attr]>
	</cffunction>

	<cffunction name="getNode" access="public" returntype="struct">
		<cfreturn variables.instance.node>
	</cffunction>

</cfcomponent>