<cfcomponent extends="core.eventHandler" output="false">

	<cffunction name="hello" returntype="void" output="false">
		<cfset setView("hello")>
	</cffunction>

	<cffunction name="info" returntype="void" output="false">
		<cfset setMessage("info","I am a message from a plugin")>
		<cfset setView("info")>
	</cffunction>

</cfcomponent>