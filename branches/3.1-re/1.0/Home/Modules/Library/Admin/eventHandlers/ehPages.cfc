<cfcomponent extends="eventHandler">

	<!------------------------------------------------->
	<!--- doDelete                               ---->
	<!------------------------------------------------->
	<cffunction name="doDelete" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- check fields --->
		<cfparam name="frm.CatalogIndex" default="0">	
		<cfparam name="frm.ID" default="0">	
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.removeCatalogResource(frm.CatalogIndex, frm.ID, "page")>
		<cfset arguments.state.infoMessage = "Page has been removed.">
		<cfset arguments.state.view = "libraryManager/pages">
			
		<cfreturn arguments.state>
	</cffunction>

	<!------------------------------------------------->
	<!--- doPublishPage                            ---->
	<!------------------------------------------------->
	<cffunction name="doPublish" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>
	
		<cfparam name="frm.catalogIndex" default="0">
		<cfparam name="frm.href" default="">
		<cfparam name="frm.description" default="">
		
		<cfscript>
			if(frm.href eq "") throw("Please enter the full path to the page you wish to publish.");
			if(frm.description eq "") throw("Please enter a brief description of the page to publish.");

			libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc";
			oLibrary = createInstance(libraryCFCPath);
			oLibrary.publishPage(frm.CatalogIndex, frm.href, frm.description);
			arguments.state.infoMessage = "Page has been published.";
			arguments.state.view = "libraryManager/pages";
		</cfscript>

		<cfreturn arguments.state>
	</cffunction>
</cfcomponent>