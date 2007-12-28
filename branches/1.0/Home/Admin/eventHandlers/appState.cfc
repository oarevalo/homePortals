<cfcomponent displayname="appState"
			hint="This component is used to encapsulate all variables that will be used
					to keep track of the state of the application.">

	<cfset this.init()>

	<cffunction name="init" access="public" hint="Initializes all application variables" returntype="appState">
		<cfscript>
			this.view = "";
			this.LastView = "";
			this.errMessage = "";
			this.infoMessage = "";
				
			this.bAuthenticated = 0;
			this.stConfig = structNew();
			
			this.datasource = "";
			this.username = "";
			this.password = "";
			
			// get paths for CFCs
			this.cfcPaths = StructNew();
			this.cfcPaths.root = "Home.Components.";
			this.cfcPaths.license = this.cfcPaths.root & "license";
			this.cfcPaths.HomePortals = this.cfcPaths.root & "homePortals";
			
			this.qryMenuOptions = QueryNew("");
		</cfscript>
		
		<cfreturn this>
	</cffunction>
	

</cfcomponent>