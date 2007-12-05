<cfcomponent name="ehDevRes" extends="ehBase">
	
	<!--- ************************************************************* --->
	<!--- 
		This method should not be altered, unless you want code to be executed
		when this handler is instantiated. This init method should be on all
		event handlers, usually left untouched.
	--->
	<cffunction name="init" access="public" returntype="Any">
		<cfset super.init()>
		<cfreturn this>
	</cffunction>
	<!--- ************************************************************* --->

	<cffunction name="dspMain" access="public" returntype="void">
		<cfset session.mainMenuOption = "Developer Resources">
		<cfset setView("DevRes/vwMain")>
	</cffunction>

	<cffunction name="dspCFCViewer" access="public" returntype="void">
		<cfscript>
			var hpCFCPath = getSetting("HOMEROOT") & "/Components/";
			var cfcViewer = getPlugin("cfcViewer");
			
			cfcViewer.setup(hpCFCPath, hpCFCPath, "public,remote");
			
			setValue("cfcViewer", cfcViewer);
			session.mainMenuOption = "Developer Resources";
		 	setView("DevRes/vwCFCViewer");
		</cfscript>
	</cffunction>

</cfcomponent>
