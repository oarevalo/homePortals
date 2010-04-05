<cfcomponent extends="core.eventHandler">
	
	<cffunction name="loadPage">
		<cfset var page = getValue("page")>
		<cfset var pageRenderer = getService("homePortals").loadPage(page)>
		<cfset setValue("html",pageRenderer.renderPage())>
		<cfset setView("homePortals")>
	</cffunction>
	
</cfcomponent>