<cfcomponent extends="base">
	
	<cffunction name="onRequestEnd" output="false">
		<cfif getView() eq "">
			<cfset setView( replace(getEvent(),".","/") )>
		</cfif>
	</cffunction>
		
	<cffunction name="loadPage" output="false">
		<cfset var page = getValue("homePortalsPage")>
		<cfset var oPageRenderer = getService("homePortals").loadPage( page )>
		<cfset setValue( "pageHTML", oPageRenderer.renderPage() )>
	</cffunction>
	
</cfcomponent>