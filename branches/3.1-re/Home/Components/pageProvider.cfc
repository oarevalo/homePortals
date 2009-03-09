<cfinterface>

	<cffunction name="init" access="public" returntype="pageProvider" hint="constructor">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
	</cffunction>

	<cffunction name="query" access="public" returntype="struct" hint="returns a struct with information about a page. Struct must contain the following elements: lastModified, size, readOnly and createdOn">
		<cfargument name="href" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="pageExists" access="public" returntype="boolean" hint="returns whether the page exists in the storage">
		<cfargument name="href" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="loads a page from the storage">
		<cfargument name="href" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="save" access="public" returntype="void" hint="stores a page in the storage">
		<cfargument name="href" type="string" hint="the location of the page document">
		<cfargument name="page" type="pageBean" hint="the page to save">
	</cffunction>

	<cffunction name="delete" access="public" returntype="void" hint="deletes a page from the storage">
		<cfargument name="href" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="move" access="public" returntype="void" hint="moves a page from one location to another">
		<cfargument name="srchref" type="string" hint="the source location of the page document">
		<cfargument name="tgthref" type="string" hint="the target location of the page document">
	</cffunction>
	
</cfinterface>
