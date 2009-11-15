<cfcomponent extends="coldbox.system.EventHandler" output="false">

	<!--- Override the default layout and set a plain layout so that 
		events here can be called directly and are not tried to be
		rendered as HomePortals pages --->
	<cffunction name="preHandler" returntype="void" output="false" hint="Executes before any event in this handler">
		<cfargument name="event" required="true">
		<cfargument name="action" hint="The intercepted action"/>
		<cfset event.setLayout("Layout.Plain")>
	</cffunction>
	
	<cffunction name="hello" returntype="void" output="false">
		<cfargument name="event" required="true">
		<cfset event.setView("hello")>
	</cffunction>

	<cffunction name="info" returntype="void" output="false">
		<cfargument name="event" required="true">
		<cfset getPlugin("MessageBox").setMessage("info","I am a message from a plugin")>
		<cfset event.setView("info")>
	</cffunction>

</cfcomponent>