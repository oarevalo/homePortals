<cfcomponent>

	<cfset variables.instance = structNew()>
	<cfset variables.instance.moduleBean = 0>

	<cffunction name="init" access="public" returntype="contentTag">
		<cfargument name="moduleBean" type="moduleBean" required="true">
		<cfset variables.instance.moduleBean = arguments.moduleBean>
		<cfreturn this>
	</cffunction>

	<cffunction name="getAttribute" access="public" returntype="string">
		<cfargument name="attr" type="string" required="true">
		<cfargument name="default" type="any" required="false" default="">
		<cfset var st = variables.instance.moduleBean.toStruct()>
		<cfif structKeyExists(st, arguments.attr)>
			<cfreturn st[arguments.attr]>
		<cfelse>
			<cfreturn arguments.default>
		</cfif>
	</cffunction>

	<cffunction name="getModuleBean" access="public" returntype="moduleBean">
		<cfreturn variables.instance.moduleBean>
	</cffunction>

</cfcomponent>