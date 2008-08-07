<cfcomponent>

	<cffunction name="init" access="public" returntype="struct" hint="constructor">
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
			stInfo.readOnly = fileObj.canWrite();
			stInfo.createdOn = stInfo.lastModified;
			
			return stInfo;
		</cfscript>
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

</cfcomponent>
