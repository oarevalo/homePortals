<cfcomponent>

	<cfset variables.instance = structNew()>
	<cfset variables.instance.node = structNew()>

	<cffunction name="init" access="public" returntype="contentTag">
		<cfargument name="structNode" type="struct" required="true">
		<cfset variables.instance.node = duplicate(arguments.structNode)>
		<cfparam name="variables.instance.node.id">
		<cfreturn this>
	</cffunction>

	<cffunction name="getAttribute" access="public" returntype="string">
		<cfargument name="attr" type="string" required="true">
		<cfargument name="default" type="any" required="false" default="">
		<cfif structKeyExists(variables.instance.node,arguments.attr)>
			<cfreturn variables.instance.node[arguments.attr]>
		<cfelse>
			<cfreturn arguments.default>
		</cfif>
	</cffunction>

	<cffunction name="getNode" access="public" returntype="struct">
		<cfreturn variables.instance.node>
	</cffunction>

</cfcomponent>