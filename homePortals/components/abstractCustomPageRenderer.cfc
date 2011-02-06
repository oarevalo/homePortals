<cfcomponent>
	
	<cfset variables.pageRenderer = 0>
	
	<cffunction name="init" access="public" returntype="abstractCustomPageRenderer" hint="Constructor">
		<cfargument name="pageRenderer" type="homeportals.components.pageRenderer" required="true">
		<cfset variables.pageRenderer = arguments.pageRenderer>
		<cfreturn this>
	</cffunction>

	<cffunction name="renderTitle" access="public" output="false" returntype="string" hint="Renders the page title">
		<cfreturn variables.pageRenderer.renderTitle()>
	</cffunction>

	<cffunction name="renderLayoutSection" access="public" output="false" returntype="string" hint="Renders all modules in a given layout section. Optionally, the caller can pass the html tag to use to for the layout section.">
		<cfargument name="layoutSection" type="string" required="yes">
		<cfargument name="tagName" type="string" required="no" default="div">
		<cfreturn variables.pageRenderer.renderLayoutSection(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="renderCustomSection" access="public" hint="Renders template-based resources such as headers and footers." returntype="string" output="false">
		<cfargument name="resourceType" type="string" required="true">
		<cfreturn variables.pageRenderer.renderCustomSection(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="renderHTMLHeadCode" access="public" returntype="string" output="false" hint="Returns the HTML code that should go in the head section of the document">
		<cfreturn variables.pageRenderer.renderHTMLHeadCode()>
	</cffunction>

	<cffunction name="getPageRenderer" access="public" returntype="homeportals.components.pageRenderer" output="false" hint="Returns the current instance of the pagerenderer object">
		<cfreturn variables.pageRenderer>
	</cffunction>

</cfcomponent>