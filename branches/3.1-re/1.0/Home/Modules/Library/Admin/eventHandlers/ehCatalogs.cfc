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
				
		<cfif frm.href eq "">
			<cfset throw("Please enter the path to the catalog file.")>
		</cfif>		
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.registerCatalog(frm.href)>
		<cfset arguments.state.infoMessage = "Catalog has been registered.">
		<cfset arguments.state.view = "libraryManager/catalogs">
			
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
		<cfparam name="frm.index" default="0">	
		<cfparam name="frm.DeleteFile" default="false" type="boolean">	
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.removeCatalog(frm.index, frm.deleteFile)>
		<cfset arguments.state.infoMessage = "Catalog has been removed.">
		<cfset arguments.state.view = "libraryManager/catalogs">
			
		<cfreturn arguments.state>
	</cffunction>


	<!------------------------------------------------->
	<!--- doSave                                   ---->
	<!------------------------------------------------->
	<cffunction name="doSave" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- check fields --->
		<cfparam name="frm.index" default="0">
		<cfparam name="frm.href" default="">
		<cfparam name="frm.name" default="">
		<cfparam name="frm.description" default="">
		
		<cfscript>
			if(frm.href eq "") throw("The path to the catalog file cannot be empty.");
			if(frm.name eq "") throw("Please enter a name for this catalog.");
			if(left(frm.href,1) neq "/") throw("The location of the catalog file must start with '/'.");
			if(len(frm.href) lt 2) throw("Please enter a valid location for the catalog file.");

			// get reference to library object
			libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc";
			oLibrary = createInstance(libraryCFCPath);
			
			if(frm.index gt 0) {
				// update existing catalog
				oLibrary.updateCatalogInfo(frm.index, frm.name, frm.description);
				arguments.state.infoMessage = "Catalog information updated.";
			} else {
				// create and register new catalog
				oLibrary.createCatalog(frm.href, frm.name, frm.description);
				oLibrary.registerCatalog(frm.href);
				arguments.state.infoMessage = "New catalog has been created.";
				arguments.state.view = "libraryManager/catalogs";
			}
		</cfscript>
				
		<cfreturn arguments.state>
	</cffunction>


</cfcomponent>