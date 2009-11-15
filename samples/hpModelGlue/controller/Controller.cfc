<cfcomponent output="false" hint="I am a Model-Glue controller." extends="ModelGlue.gesture.controller.Controller">

	<cffunction name="init" access="public" output="false" hint="Constructor">
		<cfargument name="framework" />
		<cfset super.init(framework) />
		<cfreturn this />
	</cffunction>

	<cffunction name="loadPage" access="public" returntype="void">
		<cfargument name="event" type="any">  
		<cfset var page = arguments.event.getValue("page")>
		<cfset var pageRenderer = beans.homePortals.loadPage(page)>
		<cfset var html = pageRenderer.renderPage()>
		<cfset arguments.event.setValue("html", html)>
	</cffunction>

</cfcomponent>
	
