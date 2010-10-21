<cfparam name="account" default="">
<cfparam name="page" default="">
<cfif page neq "">
        <cfset page = "/accounts/" & account & "/" & page>
<cfelse>
        <cfset page = "/accounts/" & account>
</cfif>
<cfinclude template="/homePortals/index.cfm">

