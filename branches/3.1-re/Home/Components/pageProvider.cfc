<cfinterface>

	<cffunction name="init" access="public" returntype="struct" hint="pageProvider">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
	</cffunction>

	<cffunction name="query" access="public" returntype="struct" hint="returns a struct with information about a page">
		<cfargument name="uri" type="string" hint="an identifier for the page">
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="loads a page from the storage">
		<cfargument name="uri" type="string" hint="an identifier for the page">
	</cffunction>
	
	<cffunction name="save" access="public" returntype="void" hint="stores a page in the storage">
		<cfargument name="uri" type="string" hint="an identifier for the page">
		<cfargument name="page" type="pageBean" hint="the page to save">
	</cffunction>


</cfinterface>