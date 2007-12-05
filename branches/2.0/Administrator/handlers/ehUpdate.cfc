<cfcomponent name="ehUpdate" extends="ehBase">
	
	<!--- ************************************************************* --->
	<!--- 
		This method should not be altered, unless you want code to be executed
		when this handler is instantiated. This init method should be on all
		event handlers, usually left untouched.
	--->
	<cffunction name="init" access="public" returntype="Any">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<cffunction name="dspMain" access="public" returntype="void">
		<cfset session.mainMenuOption = "Check for Updates">
		<cfset setView("Update/vwMain")>
	</cffunction>

</cfcomponent>
