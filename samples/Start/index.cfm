<cfparam name="account" default="">
<cfparam name="page" default="">

<cfif account neq "">
	<cfset page = "/accounts/" & account & "/" & page>
</cfif>

<cfinclude template="/homePortals/index.cfm">

