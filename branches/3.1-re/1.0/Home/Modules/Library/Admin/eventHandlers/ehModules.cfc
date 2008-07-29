<cfcomponent extends="eventHandler">

	<!------------------------------------------------->
	<!--- doRegister                               ---->
	<!------------------------------------------------->
	<cffunction name="doRegister" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- check fields --->
		<cfparam name="frm.href" default="">	
		<cfparam name="frm.CatalogIndex" default="0">	
				
		<cfif frm.href eq "">
			<cfset throw("Please enter the path to the resource descriptor file.")>
		</cfif>		
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.importCatalogResource(frm.CatalogIndex, frm.href, "module")>
		<cfset arguments.state.infoMessage = "Module has been registered.">
		<cfset arguments.state.view = "libraryManager/modules">
			
		<cfreturn arguments.state>
	</cffunction>

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
		<cfparam name="frm.ModuleID" default="0">	
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.removeCatalogResource(frm.CatalogIndex, frm.ModuleID, "module")>
		<cfset arguments.state.infoMessage = "Module has been removed.">
		<cfset arguments.state.view = "libraryManager/modules">
			
		<cfreturn arguments.state>
	</cffunction>

</cfcomponent>