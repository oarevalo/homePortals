<cfcomponent implements="pageProvider">

	<cfset variables.contentRoot = "">

	<cffunction name="init" access="public" returntype="pageProvider" hint="constructor">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
		<cfset variables.contentRoot = arguments.config.getContentRoot()>
		<cfreturn this>
	</cffunction>

	<cffunction name="query" access="public" returntype="struct" hint="returns a struct with information about a page">
		<cfargument name="path" type="string" hint="the location of the page document">

		<cfscript>
			var fileObj = createObject("java","java.io.File").init(resolvePath(arguments.path));
			var stInfo = structNew();
			
			stInfo.lastModified = createObject("java","java.util.Date").init(fileObj.lastModified());
			stInfo.size = fileObj.length();
			stInfo.readOnly = fileObj.canRead() and not fileObj.canWrite();
			stInfo.createdOn = stInfo.lastModified;
			stInfo.path = fileObj.getAbsolutePath();
			stInfo.exists = fileObj.exists();
			
			return stInfo;
		</cfscript>
	</cffunction>

	<cffunction name="pageExists" access="public" returntype="boolean" hint="returns whether the page exists in the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfreturn createObject("java","java.io.File").init(resolvePath(arguments.path)).exists()>
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="loads a page from the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfset var xmlDoc = 0>
		<cfset var oPage = 0>

		<cfif not pageExists(arguments.path)>
			<cfthrow message="Page not found. #arguments.path#" type="pageProvider.pageNotFound">
		</cfif>

		<cfset xmlDoc = xmlParse(resolvePath(arguments.path))>

		<cfset oPage = createObject("component","pageBean").init(xmlDoc)>

		<cfreturn oPage>
	</cffunction>

	<cffunction name="save" access="public" returntype="void" hint="stores a page in the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfargument name="page" type="pageBean" hint="the page to save">
		<cfset var xmlDoc = arguments.page.toXML()>
		<cffile action="write" file="#resolvePath(arguments.path)#" output="#toString(xmlDoc)#">
	</cffunction>

	<cffunction name="delete" access="public" returntype="void" hint="deletes a page from the storage">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfif pageExists(arguments.path)>
			<cffile action="delete" file="#resolvePath(arguments.path)#">
		</cfif>
	</cffunction>

	<cffunction name="move" access="public" returntype="void" hint="moves a page from one location to another">
		<cfargument name="srcpath" type="string" hint="the source location of the page document">
		<cfargument name="tgtpath" type="string" hint="the target location of the page document">
		<cffile action="rename" source="#resolvePath(arguments.srcpath)#" destination="#resolvePath(arguments.tgtpath)#">
	</cffunction>
	
	<cffunction name="createFolder" access="public" returntype="void" hint="creates a folder that can contain other pages or folders">
		<cfargument name="path" type="string" hint="the location where to create the folder">
		<cfargument name="name" type="string" hint="folder name">
		<cfset var newpath = arguments.path & "/" & arguments.name>
		<cfdirectory action="create" directory="#resolvePath(newpath)#">
	</cffunction>
	
	<cffunction name="deleteFolder" access="public" returntype="void" hint="deletes a folder">
		<cfargument name="path" type="string" hint="the location of the folder to delete">
		<cfdirectory action="delete" directory="#resolvePath(arguments.path)#" recurse="true">
	</cffunction>

	<cffunction name="listFolder" access="public" returntype="query" hint="lists the contents of a folder. Returns a query with the following fields: name,type; where type is either 'folder' or 'page'">
		<cfargument name="path" type="string" hint="the location of the folder to delete">
		<cfset var qryDir = 0>
		<cfset var qryRet = queryNew("name,type")>
		
		<cfdirectory action="list" directory="#resolvePath(arguments.path)#" name="qryDir">
		
		<cfloop query="qryDir">
			<cfset queryAddRow(qryRet)>
			<cfif qryDir.type eq "file">
				<cfif findNoCase(".xml",qryDir.name)>
					<cfset querySetCell(qryRet,"type","page")>
					<cfset querySetCell(qryRet,"name",replaceNoCase(qryDir.name,".xml",""))>
				</cfif>
			</cfif>
			<cfif qryDir.type eq "dir">
				<cfset querySetCell(qryRet,"type","folder")>
				<cfset querySetCell(qryRet,"name",qryDir.name)>
			</cfif>
		</cfloop>
		
		<cfreturn qryRet>
	</cffunction>

	<cffunction name="renameFolder" access="public" returntype="void" hint="changes the name of a folder">
		<cfargument name="path" type="string" hint="the location of the folder to be renamed">
		<cfargument name="name" type="string" hint="the new folder name">
		<cfdirectory action="rename" directory="#resolvePath(arguments.path)#" newdirectory="#arguments.name#">
	</cffunction>

	<cffunction name="folderExists" access="public" returntype="boolean" hint="returns whether a folder exists in the storage">
		<cfargument name="path" type="string" hint="the location of the folder">
		<cfreturn directoryExists(resolvePath(arguments.path))>
	</cffunction>	
	
	
	<cffunction name="resolvePath" access="private" returntype="string">
		<cfargument name="path" type="string" hint="the location of the page document">
		<cfreturn expandPath( variables.contentRoot & arguments.path )>
	</cffunction>
	
</cfcomponent>
