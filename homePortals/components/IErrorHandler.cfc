<cfinterface hint="Describes a component that can be used to provide custom behavior for handling errors">

	<cffunction name="onContentRendererError" returntype="void" hint="Handles an error ocurred while processing a content renderer on a page">
		<cfargument name="homePortals" type="homePortals.components.homePortals" required="true" hint="The homePortals engine">
		<cfargument name="pageRenderer" type="homePortals.components.pageRenderer" required="true" hint="The pageRenderer for the current page">
		<cfargument name="moduleBean" type="homePortals.components.moduleBean" required="true" hint="The page module node where the error ocurred">
		<cfargument name="contentBuffer" type="homePortals.components.singleContentBuffer" required="true" hint="A content buffer used to send back output to the current page">
		<cfargument name="exception" type="any" required="true" hint="The cfcatch structure">
	</cffunction>
	
</cfinterface>