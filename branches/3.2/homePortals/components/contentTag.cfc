<cfcomponent hint="This component encapsulates a single content renderer element (aka module) on a page. The purpose of this object is to act as an envelope to pass relevant page element to the actual renderer component to work on.">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.moduleBean = 0>

	<cffunction name="init" access="public" returntype="contentTag" hint="Constructor">
		<cfargument name="moduleBean" type="moduleBean" required="true" hint="This is a specific module on the page">
		<cfset variables.instance.moduleBean = arguments.moduleBean>
		<cfreturn this>
	</cffunction>

	<cffunction name="getAttribute" access="public" returntype="string" hint="Retrieves an attribute defined on the corresponding page element (module). If the requested attribute does not exist on the module, then returns empty or the given default value.">
		<cfargument name="attr" type="string" required="true">
		<cfargument name="default" type="any" required="false" default="">
		<cfset var st = variables.instance.moduleBean.toStruct()>
		<cfif structKeyExists(st, arguments.attr)>
			<cfreturn st[arguments.attr]>
		<cfelse>
			<cfreturn arguments.default>
		</cfif>
	</cffunction>

	<cffunction name="getModuleBean" access="public" returntype="moduleBean" hint="Returns a reference to the contained page element (module)">
		<cfreturn variables.instance.moduleBean>
	</cffunction>

</cfcomponent>