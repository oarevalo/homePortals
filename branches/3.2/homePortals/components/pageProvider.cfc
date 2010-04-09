<cfinterface>

	<cffunction name="init" access="public" returntype="pageProvider" hint="constructor">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
	</cffunction>

	<cffunction name="getInfo" access="public" returntype="struct" hint="returns a struct with information about a page. Struct must contain the following elements: lastModified, size, readOnly and createdOn">
		<cfargument name="path" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="pageExists" access="public" returntype="boolean" hint="returns whether the page exists in the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="loads a page from the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="save" access="public" returntype="void" hint="stores a page in the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfargument name="page" type="pageBean" hint="the page to save">
	</cffunction>

	<cffunction name="delete" access="public" returntype="void" hint="deletes a page from the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
	</cffunction>

	<cffunction name="move" access="public" returntype="void" hint="moves a page from one location to another">
		<cfargument name="srcpath" type="string" hint="the source location of the page document">
		<cfargument name="tgtpath" type="string" hint="the target location of the page document">
	</cffunction>
	
	<!--- Folders --->
	
	<cffunction name="createFolder" access="public" returntype="void" hint="creates a folder that can contain other pages or folders">
		<cfargument name="path" type="string" hint="the location where to create the folder">
		<cfargument name="name" type="string" hint="folder name">
	</cffunction>
	
	<cffunction name="deleteFolder" access="public" returntype="void" hint="deletes a folder">
		<cfargument name="path" type="string" hint="the location of the folder to delete">
	</cffunction>

	<cffunction name="listFolder" access="public" returntype="query" hint="lists the contents of a folder. Returns a query with the following fields: name,type; where type is either 'folder' or 'page'">
		<cfargument name="path" type="string" hint="the location of the folder to delete">
	</cffunction>

	<cffunction name="renameFolder" access="public" returntype="void" hint="changes the name of a folder">
		<cfargument name="path" type="string" hint="the location of the folder to be renamed">
		<cfargument name="name" type="string" hint="the new folder name">
	</cffunction>

	<cffunction name="folderExists" access="public" returntype="boolean" hint="returns whether a folder exists in the storage">
		<cfargument name="path" type="string" hint="the location of the folder">
	</cffunction>
	
</cfinterface>
