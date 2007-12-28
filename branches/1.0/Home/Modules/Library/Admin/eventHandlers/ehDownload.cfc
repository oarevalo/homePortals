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
		<cfparam name="frm.url" default="">	
				
		<cfif frm.url eq "">
			<cfset throw("Please enter the URL Address of the HomePortals update site you wish to register.")>
		</cfif>		
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.registerUpdateSite(frm.url)>
		<cfset arguments.state.infoMessage = "Update Site has been registered.">
		<cfset arguments.state.view = "libraryManager/downloadSites">
			
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
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.removeUpdateSite(frm.index)>
		<cfset arguments.state.infoMessage = "Update Site has been removed.">
		<cfset arguments.state.view = "libraryManager/downloadSites">
			
		<cfreturn arguments.state>
	</cffunction>

	<!------------------------------------------------->
	<!--- doDownloadPackage                        ---->
	<!------------------------------------------------->
	<cffunction name="doDownloadPackage" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<!--- check fields --->
		<cfparam name="frm.index" default="0">	
		<cfparam name="frm.href" default="">	
		<cfparam name="frm.catalogIndex" default="1">	
				
		<!--- get reference to library object --->
		<cfset libraryCFCPath = arguments.state.stConfig.moduleLibraryPath & "Library/Components/library.cfc">
		<cfset oLibrary = createInstance(libraryCFCPath)>
		<cfset oLibrary.downloadPackage(frm.index, frm.href, frm.catalogIndex, arguments.state.stConfig.moduleLibraryPath)>
		<cfset arguments.state.infoMessage = "Package has been installed and registered.">
		<cfset arguments.state.view = "libraryManager/downloadSites">
			
		<cfreturn arguments.state>
	</cffunction>

</cfcomponent>