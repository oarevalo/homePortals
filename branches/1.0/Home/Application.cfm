<!--- Application.cfm

This is the Application.cfm executed for all requests within the HomePortals framework.
All applications implemented with the framwork will share this Application.cfm

--->


<cfapplication name="HomePortal" 
			 	sessionmanagement="yes" sessiontimeout="#CreateTimeSpan(0,2,0,0)#" 
			 	clientmanagement="true" clientstorage="cookie">

<!--- error template 
<cferror type="exception" template="/home/common/templates/error.cfm">
<cferror type="request" template="/home/common/templates/error.cfm">
--->

<!--- Kill the session when the user closes the browser --->
<cfif IsDefined("Cookie.CFID") AND IsDefined("Cookie.CFTOKEN")>
  <cfset cfid_local = Cookie.CFID>
  <cfset cftoken_local = Cookie.CFTOKEN>
  <cfcookie name="CFID" value="#cfid_local#">
  <cfcookie name="CFTOKEN" value="#cftoken_local#">
</cfif> 
