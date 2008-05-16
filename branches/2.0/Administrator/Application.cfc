<cfcomponent>
<cfset this.name = "HomePortals Administrator"> 
<cfset this.clientManagement = true> 
<cfset this.sessionManagement = true> 
<cfset this.sessionTimeout = createTimeSpan(0,0,30,0)> 
<cfset this.setClientCookies = true>
		
<cffunction name="onApplicationStart" returnType="boolean" output="false"> 
	<cfreturn true> 
	<!--- Place Here any application start code --->
</cffunction> 

<cffunction name="onApplicationEnd" returnType="void"  output="false"> 
	<cfargument name="applicationScope" required="true">
	<!--- Place Here any application end code --->
</cffunction>

<cffunction name="onSessionStart" returnType="void" output="false"> 
	<!--- Place Here any session start code --->
</cffunction> 

<cffunction name="onSessionEnd" returnType="void" output="false"> 
	<cfargument name="sessionScope" type="struct" required="true"> 
	<cfargument name="appScope" type="struct" required="false"> 
	<!--- Place Here any session end code --->
</cffunction> 
 
</cfcomponent>