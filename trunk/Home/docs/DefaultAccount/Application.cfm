<!--- Application.cfm

This is the Application.cfm executed for all requests within the HomePortals framework.
All applications implemented with the framwork will share this Application.cfm

--->

<cfsetting showdebugoutput="false">

<cfapplication name="HomePortals"  
			 	sessionmanagement="yes" 
			 	sessiontimeout="#CreateTimeSpan(0,2,0,0)#" 
			 	clientmanagement="true">

<!--- Kill the session when the user closes the browser --->
<cfif IsDefined("Cookie.CFID") AND IsDefined("Cookie.CFTOKEN")>
  <cfset cfid_local = Cookie.CFID>
  <cfset cftoken_local = Cookie.CFTOKEN>
  <cfcookie name="CFID" value="#cfid_local#">
  <cfcookie name="CFTOKEN" value="#cftoken_local#">
</cfif> 
