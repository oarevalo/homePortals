<cfcomponent extends="eventHandler">

	<!------------------------------------------------->
	<!--- doSaveInfo                               ---->
	<!------------------------------------------------->
	<cffunction name="doSaveInfo" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<cfparam name="frm.name" default="">
		<cfparam name="frm.description" default="">

		<cfif frm.name eq "">
			<cfset throw("Please enter a name for this update site")>
		</cfif>	

		<!--- get reference to updateSite object --->
		<cfset cfcPath = arguments.state.stConfig.moduleLibraryPath & "updateSite/Components/updateSite.cfc">
		<cfset oUpdateSite = createInstance(cfcPath)>
		<cfset oUpdateSite.init(arguments.state.stConfig.homePortalsPath, arguments.state.stConfig.moduleLibraryPath)>
		<cfset oUpdateSite.saveInfo(frm.name, frm.description)>		
		
		<cfset arguments.state.infoMessage = "Update Site information saved.">
		<cfset arguments.state.view = "distManager/publish">
			
		<cfreturn arguments.state>
	</cffunction>

	<!------------------------------------------------->
	<!--- doAddPackage                             ---->
	<!------------------------------------------------->
	<cffunction name="doAddPackage" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<cfparam name="frm.PackageDir" default="">

		<cfif frm.PackageDir eq "">
			<cfset throw("Please enter the path to the package to be published")>
		</cfif>	

		<!--- get reference to updateSite object --->
		<cfset cfcPath = arguments.state.stConfig.moduleLibraryPath & "updateSite/Components/updateSite.cfc">
		<cfset oUpdateSite = createInstance(cfcPath)>
		<cfset oUpdateSite.init(arguments.state.stConfig.homePortalsPath, arguments.state.stConfig.moduleLibraryPath)>
		<cfset oUpdateSite.publishPackage(frm.PackageDir, ListLast(frm.PackageDir,"/"), "", "1.0")>		

		<cfset arguments.state.infoMessage = "Package has been created.">
		<cfset arguments.state.view = "distManager/publish">
			
		<cfreturn arguments.state>
	</cffunction>
	
	<!------------------------------------------------->
	<!--- doRemovePackage                          ---->
	<!------------------------------------------------->
	<cffunction name="doRemovePackage" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<cfparam name="frm.href" default="">

		<cfif frm.href eq "">
			<cfset throw("Please enter the package file name to delete")>
		</cfif>	

		<!--- get reference to updateSite object --->
		<cfset cfcPath = arguments.state.stConfig.moduleLibraryPath & "updateSite/Components/updateSite.cfc">
		<cfset oUpdateSite = createInstance(cfcPath)>
		<cfset oUpdateSite.init(arguments.state.stConfig.homePortalsPath, arguments.state.stConfig.moduleLibraryPath)>
		<cfset oUpdateSite.deletePackage(frm.href)>		
		
		<cfset arguments.state.infoMessage = "Package has been removed.">
		<cfset arguments.state.view = "distManager/publish">
			
		<cfreturn arguments.state>
	</cffunction>		
	
	<!------------------------------------------------->
	<!--- doSavePackageInfo                        ---->
	<!------------------------------------------------->
	<cffunction name="doSavePackageInfo" access="public" returntype="any">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="any"> 
	
		<cfset var temp = StructAppend(arguments.form, arguments.url)>
		<cfset var frm = arguments.form>

		<cfparam name="frm.href" default="">
		<cfparam name="frm.name" default="">
		<cfparam name="frm.description" default="">
		<cfparam name="frm.version" default="">

		<cfif frm.href eq "">
			<cfset throw("Please enter the package file name to update")>
		</cfif>	
		<cfif frm.name eq "">
			<cfset throw("Please enter a name for this update site")>
		</cfif>	
		<cfif frm.version eq "">
			<cfset frm.version = "1.0">
		</cfif>	

		<!--- get reference to updateSite object --->
		<cfset cfcPath = arguments.state.stConfig.moduleLibraryPath & "updateSite/Components/updateSite.cfc">
		<cfset oUpdateSite = createInstance(cfcPath)>
		<cfset oUpdateSite.init(arguments.state.stConfig.homePortalsPath, arguments.state.stConfig.moduleLibraryPath)>
		<cfset oUpdateSite.updatePackageInfo(frm.href, frm.name, frm.description, frm.version)>	

		<cfset arguments.state.infoMessage = "Package Info has been saved.">
		<cfset arguments.state.view = "distManager/publish">
			
		<cfreturn arguments.state>
	</cffunction>	
</cfcomponent>	