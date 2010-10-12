<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="Use this content renderer to display a short text label.">
	<cfproperty name="value" type="string" hint="The text to display">
	<cfproperty name="href" type="string" hint="If not empty, indicates a URL to go to when clicking on the text." />

	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">
		<cfset var tmpHTML = "">
		<cfset var value = getContentTag().getAttribute("value")>
		<cfset var href = getContentTag().getAttribute("href")>
		<cfif trim(href) neq "">
			<cfset tmpHTML = "<a href=""#trim(href)#"">#value#</a>">
		<cfelse>
			<cfset tmpHTML = value>
		</cfif>
		<cfset arguments.bodyContentBuffer.set( tmpHTML )>
	</cffunction>

</cfcomponent>