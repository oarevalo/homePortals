<cfcomponent extends="eventHandler">
	
	<cffunction name="setNextEvent" access="private">
		<cfargument name="eventName" type="string" required="false" default="">
		<cfargument name="queryString" type="string" required="false" default="">
		
		<cfset var base = request.appRoot>
		<cfset var href = "index.cfm">
		
		<cfif arguments.eventName neq "">
			<cfset href = base & "/" & eventName & ".cfm">
		</cfif>
		<cfif arguments.queryString neq "">
			<cfset href = base & href & "?" & arguments.queryString>
		</cfif>

		<cflocation url="#href#" addtoken="false">
	</cffunction>
	
</cfcomponent>