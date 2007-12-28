<cfcomponent extends="eventHandler">

	<!------------------------------------------------->
	<!--- prologue                                 ---->
	<!------------------------------------------------->
	<cffunction name="prologue" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfif Not arguments.state.bAuthenticated and not ListFindNoCase("login",arguments.state.event)>
			<cfset arguments.state.view = "login">
			<cfset arguments.state.event = "">
		</cfif>
		
		<cfreturn arguments.state>
	</cffunction>
		
		
	<!------------------------------------------------->
	<!--- login                                    ---->
	<!------------------------------------------------->
	<cffunction name="login" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfparam name="form.password" default="">
		
		<cftry>
			<cfscript>
				if(arguments.form.password eq "") throw("Password cannot be empty.");
				
				// instantiate license manager object
				oLicense = createInstance(arguments.state.cfcPaths.license);
				
				// check if password is valid
				bValid = oLicense.verifyAdminPassword(arguments.form.password);
				
				if(Not bValid) throw("Invalid Password");

				// password is valid, so initialize application
				arguments.state.bAuthenticated = true;
				arguments.state.view = "main";
				
				// get settings
				oHP = createInstance(arguments.state.cfcPaths.homePortals);
				oHP.init(true, "/Home/");
				oHP.LoadConfig();
				arguments.state.stConfig = oHP.getConfig();
				
				// Build menu options
				oMenu = createInstance("components/menu.cfc");
				arguments.state.qryMenuOptions = oMenu.get();
			</cfscript>

			<cfcatch type="any">
				<cfset arguments.state.view = "login">
				<cfset arguments.state.errMessage = cfcatch.Message>
			</cfcatch>
		</cftry>
		
		<cfreturn arguments.state>
	</cffunction>
	

	<!------------------------------------------------->
	<!--- saveSettings                             ---->
	<!------------------------------------------------->
	<cffunction name="saveSettings" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfset frm = arguments.form>

		<cfparam name="frm.defaultPage" default="">
		<cfparam name="frm.homePortalsPath" default="">
		<cfparam name="frm.moduleLibraryPath" default="">
		<cfparam name="frm.SSLRoot" default="">
		<cfparam name="frm.adminEmail" default="">

		<cfset arguments.state.stConfig.defaultPage = frm.defaultPage>
		<cfset arguments.state.stConfig.homePortalsPath = frm.homePortalsPath>
		<cfset arguments.state.stConfig.moduleLibraryPath = frm.moduleLibraryPath>
		<cfset arguments.state.stConfig.SSLRoot = frm.SSLRoot>
		<cfset arguments.state.stConfig.adminEmail = frm.adminEmail>
		
		<!--- save settings --->
		<cfset oHP = createInstance(arguments.state.cfcPaths.homePortals)>
		<cfset oHP.init()>
		<cfset oHP.setConfig(arguments.state.stConfig)>		
		<cfset oHP.SaveConfig()>		
		
		<cfset arguments.state.infoMessage = "Settings Saved">
		
		<cfreturn arguments.state>
	</cffunction>	

	<!------------------------------------------------->
	<!--- saveResource                             ---->
	<!------------------------------------------------->
	<cffunction name="saveResource" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfset frm = arguments.form>

		<cfparam name="frm.resourceIndex" default="0">
		<cfparam name="frm.resourceType" default="">
		<cfparam name="frm.type" default="">
		<cfparam name="frm.href" default="">
	
		<cfif frm.resourceIndex gt 0>
			<cfif frm.resourceType eq frm.type>
				<cfset arguments.state.stConfig.resources[frm.resourceType][frm.resourceIndex] = frm.href>
			<cfelse>
				<cfset ArrayDeleteAt(arguments.state.stConfig.resources[frm.resourceType], frm.resourceIndex)>
				<cfif Not StructKeyExists(arguments.state.stConfig.resources, frm.type)>
					<cfset arguments.state.stConfig.resources[frm.type] = ArrayNew(1)>
				</cfif>
				<cfset ArrayAppend(arguments.state.stConfig.resources[frm.type], frm.href)>
			</cfif>
		<cfelse>
			<cfif Not StructKeyExists(arguments.state.stConfig.resources, frm.type)>
				<cfset arguments.state.stConfig.resources[frm.type] = ArrayNew(1)>
			</cfif>
			<cfset ArrayAppend(arguments.state.stConfig.resources[frm.type], frm.href)>
		</cfif>
		
		<!--- save settings --->
		<cfset oHP = createInstance(arguments.state.cfcPaths.homePortals)>
		<cfset oHP.init()>
		<cfset oHP.setConfig(arguments.state.stConfig)>		
		<cfset oHP.SaveConfig()>		
		
		<cfset arguments.state.infoMessage = "Resource Saved">
		
		<cfreturn arguments.state>
	</cffunction>	

	<!------------------------------------------------->
	<!--- deleteResource                           ---->
	<!------------------------------------------------->
	<cffunction name="deleteResource" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfset frm = arguments.url>

		<cfparam name="frm.resourceIndex" default="0">
		<cfparam name="frm.resourceType" default="">
	
		<cfif frm.resourceIndex gt 0>
			<cfset ArrayDeleteAt(arguments.state.stConfig.resources[frm.resourceType], frm.resourceIndex)>
		</cfif>
		
		<!--- save settings --->
		<cfset oHP = createInstance(arguments.state.cfcPaths.homePortals)>
		<cfset oHP.init()>
		<cfset oHP.setConfig(arguments.state.stConfig)>		
		<cfset oHP.SaveConfig()>		
		
		<cfset arguments.state.infoMessage = "Resource Deleted">
		
		<cfreturn arguments.state>
	</cffunction>	

	<!------------------------------------------------->
	<!--- saveModuleIcon                           ---->
	<!------------------------------------------------->
	<cffunction name="saveModuleIcon" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfset frm = arguments.form>

		<cfparam name="frm.moduleIconIndex" default="0">
		<cfparam name="frm.image" default="">
		<cfparam name="frm.alt" default="">
		<cfparam name="frm.onClickFunction" default="">
	
		<cfif frm.moduleIconIndex gt 0>
			<cfset arguments.state.stConfig.moduleIcons[frm.moduleIconIndex].image = frm.image>
			<cfset arguments.state.stConfig.moduleIcons[frm.moduleIconIndex].alt = frm.alt>
			<cfset arguments.state.stConfig.moduleIcons[frm.moduleIconIndex].onClickFunction = frm.onClickFunction>
		<cfelse>
			<cfset stTemp = StructNew()>
			<cfset stTemp.image = frm.image>
			<cfset stTemp.alt = frm.alt>
			<cfset stTemp.onClickFunction = frm.onClickFunction>
			<cfset ArrayAppend(arguments.state.stConfig.moduleIcons, Duplicate(stTemp))>
		</cfif>
		
		<!--- save settings --->
		<cfset oHP = createInstance(arguments.state.cfcPaths.homePortals)>
		<cfset oHP.init()>
		<cfset oHP.setConfig(arguments.state.stConfig)>		
		<cfset oHP.SaveConfig()>		
		
		<cfset arguments.state.infoMessage = "Module Icon Saved">
		
		<cfreturn arguments.state>
	</cffunction>	

	<!------------------------------------------------->
	<!--- deleteModuleIcon                         ---->
	<!------------------------------------------------->
	<cffunction name="deleteModuleIcon" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cfset frm = arguments.url>

		<cfparam name="frm.moduleIconIndex" default="0">
	
		<cfif frm.moduleIconIndex gt 0>
			<cfset ArrayDeleteAt(arguments.state.stConfig.moduleIcons, frm.moduleIconIndex)>
		</cfif>
		
		<!--- save settings --->
		<cfset oHP = createInstance(arguments.state.cfcPaths.homePortals)>
		<cfset oHP.init()>
		<cfset oHP.setConfig(arguments.state.stConfig)>		
		<cfset oHP.SaveConfig()>		
		
		<cfset arguments.state.infoMessage = "Module Icon Deleted">
		
		<cfreturn arguments.state>
	</cffunction>				
	
	

	<!------------------------------------------------->
	<!--- changePassword                           ---->
	<!------------------------------------------------->
	<cffunction name="changePassword" access="public" returntype="appState">
		<cfargument name="form" required="no" default="#StructNew()#"> 
		<cfargument name="url" required="no" default="#StructNew()#"> 
		<cfargument name="state" required="yes" type="appState"> 
		
		<cftry>
			<cfset frm = arguments.form>
	
			<cfparam name="frm.oldPwd" default="">
			<cfparam name="frm.newPwd" default="">
			<cfparam name="frm.newPwd2" default="">
	
			<cfscript>
				if(arguments.form.oldPwd eq "") throw("Please enter your current password.");
				if(arguments.form.newPwd eq "") throw("Please enter the new password.");
				if(arguments.form.newPwd2 eq "") throw("Please confirm the new password.");
				if(len(arguments.form.newPwd) lt 5) throw("The new password must be at least 6 characters long.");
				if(arguments.form.newPwd neq arguments.form.newPwd2) throw("Both new passwords do not match.");
			</cfscript>
	
			<!--- instantiate license manager object --->
			<cfset oLicense = createInstance(arguments.state.cfcPaths.license)>

			<!--- check if current password is okay --->
			<cfset bValid = oLicense.verifyAdminPassword(arguments.form.oldPwd)>
			
			<cfif Not bValid>
				<cfthrow message="The current password is not correct. Please enter your current password.">
			<cfelse>
				<cfset oLicense.saveAdminPassword(arguments.form.newPwd)>
				<cfset arguments.state.infoMessage = "The administrator password has been changed.">
			</cfif>
					
			<cfcatch type="any">
				<cfset arguments.state.view = "changePassword">
				<cfset arguments.state.errMessage = cfcatch.Message>
			</cfcatch>
		</cftry>
		
		<cfreturn arguments.state>
	</cffunction>
	
</cfcomponent>