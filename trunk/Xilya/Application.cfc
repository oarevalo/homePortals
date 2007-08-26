<cfcomponent>
	<!--- Application.cfc
	
	This is the Application.cfm executed for all requests within the HomePortals framework.
	All applications implemented with the framwork will share this Application.cfm
	
	--->
	<cfset this.name = "Xilya">
	<cfset this.sessionManagement = true>
	<cfset this.sessiontimeout = CreateTimeSpan(0,2,0,0)>
	
	<cffunction name="onRequestStart" returnType="boolean">
	   <cfargument type="String" name="targetPage" required=true/>

		<!--- path to application --->
		<cfset request.appRoot = "/xilya">

		<!--- path to website --->
		<cfif cgi.SERVER_NAME eq "localhost">
			<cfset request.homePagePath = "/xilya.com">
		<cfelse>
			<cfset request.homePagePath = "">
		</cfif>

	   <cfreturn true>
	</cffunction>
	
	
	<cffunction name="onError" returnType="void">
	   <cfargument name="Exception" required=true/>
	   <cfargument name="EventName" type="String" required=true/>

		<cfif arguments.exception.type eq "homePortals.engine.unauthorizedAccess">
			<cfinclude template="#request.appRoot#/includes/noAccess.cfm">
			<cfabort>
		<cfelse>
			<cfinclude template="#request.appRoot#/includes/error.cfm">
		</cfif>

	</cffunction>

</cfcomponent>