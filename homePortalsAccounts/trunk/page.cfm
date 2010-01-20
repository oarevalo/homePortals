<cfsilent>
	<!---
		Copyright 2007 - Oscar Arevalo (http://www.oscararevalo.com)
	
	    This file is part of HomePortals.
	---->
	<!------- Page parameters ----------->
	<cfparam name="account" default=""> 			<!--- account name --->
	<cfparam name="page" default=""> 				<!--- page to load within account --->
	<cfparam name="pageHREF" default="#account#::#page#">
	<!----------------------------------->
	<cfset page = pageHREF>	
</cfsilent>
<cfinclude template="/homePortals/common/Templates/page.cfm">


