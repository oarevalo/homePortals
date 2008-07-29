<cfcomponent implements="pageProvider">

	<cffunction name="init" access="public" returntype="struct" hint="constructor">
		<cfargument name="config" type="homePortalsConfigBean" hint="main configuration bean for the application">
		<cfreturn this>
	</cffunction>

	<cffunction name="query" access="public" returntype="struct" hint="returns a struct with information about a page">
		<cfargument name="uri" type="string" hint="an identifier for the page">

		<cfscript>
			var fileObj = createObject("java","java.io.File").init(expandPath(arguments.uri));
			var stInfo = structNew();
			
			stInfo.lastModified = createObject("java","java.util.Date").init(fileObj.lastModified());
			stInfo.size = fileObj.length();
			stInfo.readOnly = fileObj.canWrite();
			stInfo.createdOn = stInfo.lastModified;
			
			return stInfo;
		</cfscript>
	</cffunction>

	<cffunction name="load" access="public" returntype="pageBean" hint="loads a page from the storage">
		<cfargument name="uri" type="string" hint="an identifier for the page">
		<cfset var xmlDoc = 0>
		<cfset var oPage = 0>

		<cfif not fileExists(expandPath(arguments.uri))>
			<cfthrow message="Page not found. #arguments.uri#" type="pageProvider.pageNotFound">
		</cfif>

		<cfset xmlDoc = xmlParse(expandPath(arguments.uri))>

		<cfset oPage = createObject("component","pageBean").init(xmlDoc)>

		<cfreturn oPage>
	</cffunction>

	<cffunction name="save" access="public" returntype="void" hint="stores a page in the storage">
		<cfargument name="uri" type="string" hint="an identifier for the page">
		<cfargument name="page" type="pageBean" hint="the page to save">
		<cfset var xmlDoc = arguments.page.toXML()>
		<cffile action="write" file="#expandpath(arguments.uri)#" output="#toString(xmlDoc)#">
	</cffunction>

</cfcomponent>
