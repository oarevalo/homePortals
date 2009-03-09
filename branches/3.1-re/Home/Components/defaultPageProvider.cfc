<cfcomponent implements="pageProvider">

	<cffunction name="init" access="public" returntype="pageProvider" hint="constructor">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
		<cfreturn this>
	</cffunction>

	<cffunction name="query" access="public" returntype="struct" hint="returns a struct with information about a page">
		<cfargument name="href" type="string" hint="the location of the page document">

		<cfscript>
			var fileObj = createObject("java","java.io.File").init(expandPath(arguments.href));
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
		<cfargument name="href" type="string" hint="the location of the page document">
		<cfreturn createObject("java","java.io.File").init(expandPath(arguments.href)).exists()>
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="loads a page from the storage">
		<cfargument name="href" type="string" hint="the location of the page document">
		<cfset var xmlDoc = 0>
		<cfset var oPage = 0>

		<cfif not fileExists(expandPath(arguments.href))>
			<cfthrow message="Page not found. #arguments.href#" type="pageProvider.pageNotFound">
		</cfif>

		<cfset xmlDoc = xmlParse(expandPath(arguments.href))>

		<cfset oPage = createObject("component","pageBean").init(xmlDoc)>

		<cfreturn oPage>
	</cffunction>

	<cffunction name="save" access="public" returntype="void" hint="stores a page in the storage">
		<cfargument name="href" type="string" hint="the location of the page document">
		<cfargument name="page" type="pageBean" hint="the page to save">
		<cfset var xmlDoc = arguments.page.toXML()>
		<cffile action="write" file="#expandpath(arguments.href)#" output="#toString(xmlDoc)#">
	</cffunction>

	<cffunction name="delete" access="public" returntype="void" hint="deletes a page from the storage">
		<cfargument name="href" type="string" hint="the location of the page document">
		<cfif fileExists(expandPath(arguments.href))>
			<cffile action="delete" file="#expandpath(arguments.href)#">
		</cfif>
	</cffunction>

	<cffunction name="move" access="public" returntype="void" hint="moves a page from one location to another">
		<cfargument name="srchref" type="string" hint="the source location of the page document">
		<cfargument name="tgthref" type="string" hint="the target location of the page document">
		<cffile action="rename" source="#expandPath(arguments.srchref)#" destination="#expandPath(arguments.tgthref)#">
	</cffunction>

</cfcomponent>
