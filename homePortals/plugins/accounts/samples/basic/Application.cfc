<cfcomponent output="false">
	<!---
	/*
		Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)
	
	    This file is part of HomePortals.
	
	*/ 
	---->
	<cfset this.name = "hpAccountsExtension"> 
	<cfset this.sessionManagement = true>
	
	<cffunction name="onRequestStart">
		<cfset request.appRoot = "/homePortals/plugins/accounts/samples/basic">
	</cffunction>
</cfcomponent>