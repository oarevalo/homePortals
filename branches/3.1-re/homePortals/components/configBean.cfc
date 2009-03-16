<cfcomponent displayname="configBean" hint="Abstract component for configuration beans">

	<!--- initialize structure where bean data will be held --->
	<cfset variables.data = structNew()>

	<!---------------------------------------->
	<!--- serialize	                       --->
	<!---------------------------------------->		
	<cffunction name="serialize" access="public" returntype="string"
				hint="Transforms all configBean contents into a string form that can be stored anywhere">
		<cfset var strData = "">
		<cfwddx action="cfml2wddx" input="#variables.data#" output="strData">
		<cfreturn strData>
	</cffunction>

	<!---------------------------------------->
	<!--- deserialize                      --->
	<!---------------------------------------->		
	<cffunction name="deserialize" access="public" 
				hint="Restores configBean contents from a string">
		<cfargument name="stringData" type="string" required="true">
		<cfwddx action="wddx2cfml" input="#arguments.stringData#" output="variables.data">
	</cffunction>

</cfcomponent>