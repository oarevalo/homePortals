<!--- myAccount module --->

<cfif Not IsDefined("Session.User.qry")>
	<cfinvoke component="home.modules.content.addContent" method="doLogOff">
	</cfinvoke>
</cfif>

<cfset initContext()>
<cfset link1 = "javascript:alert('Coming Soon!');">
<cfset link3 = "/Accounts/#Session.user.qry.username#/">
<cfset link4 = "index.cfm?currentHome=#this.PageURL#&refresh=true&#RandRange(1,100)#">
<cfset link5 = "javascript:controlPanel.doLogoff('logoutMsg');">

<cfoutput>
	<div id="logoutMsg_BodyRegion"></div>

	Welcome, #Session.User.qry.username# 
	<p>
		<b>What do you want to do?</b>
		<!--- <li><a href="#link1#">Edit my account information</a></li> --->
		<li><a href="#link3#">Go to my public site</a></li>
		<li><a href="#link4#">Refresh this page</a></li>
		<li><a href="#link5#"><strong>Log Out</strong></a></li>
	</p>
</cfoutput>
