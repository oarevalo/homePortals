<!--- textPad.cfc
	This component provides content editing functionality to the textPad module.
	Version: 0.1
	
	
	Changelog:
    - 1/13/05 - oarevalo - If no URL is given, use a default file to store content
						 - save owner when creating the datafile, only owner can add or change content
	- 3/9/06 - oarevalo - fixed owner intialization bug
	- 4/18/06 - oarevalo - changed module to use TinyMCE as the HTML editor
						- use contentStorage to handle all storage functions. this component is now only a facade
	- 4/20/06 - oarevalo - changed name of this version to textPad (formerly editBox)
--->

<cfcomponent displayname="textPad">
	<meta http-equiv="Expires" content="0">
	<META HTTP-EQUIV="Pragma" CONTENT="no-cache">
	<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
		
	<!---------------------------------------->
	<!--- init                             --->
	<!---------------------------------------->
	<cffunction name="init" access="remote" output="true" hint="Initializes the component">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="URL" type="string" default="">
		<cfargument name="contentID" type="string" default="">
				
		<cftry>
			<cfif Not StructKeyExists(session,"homeConfig")>
				Your session has timed out. Please refresh this page.
				<cfexit>
			</cfif>
			
			<!--- get the owner of the current page --->
			<cfset owner = ListGetAt(session.homeConfig.href, 2, "/")>
			
			<!--- instantiate storage document --->
			<cfset oStorage = CreateObject("component","contentStorage")>
			<cfset oStorage.init(owner, arguments.URL, true)>
			
			<!--- get current user info --->
			<cfset stUser = getUserInfo()>

			<!--- check if the current user is the owner of the document --->
			<cfset tmpDocumentOwner = oStorage.getOwner()>
			<cfset bIsContentOwner = (stUser.username eq tmpDocumentOwner)>

			<!--- store values in session --->
			<cfset Session.textPad[Arguments.InstanceName] = StructNew()>
			<cfset Session.textPad[Arguments.InstanceName].url = oStorage.getStorageURL()>
			<cfset Session.textPad[Arguments.InstanceName].contentID = arguments.contentID>
			<cfset Session.textPad[Arguments.InstanceName].isContentOwner = bIsContentOwner>
			
			<cfcatch type="any">
				#cfcatch.Message# 
			</cfcatch>
		</cftry>
	</cffunction>

	<!---------------------------------------->
	<!--- getView                          --->
	<!---------------------------------------->	
	<cffunction name="getView" access="remote" output="true" hint="Renders the interface to display the selected entry">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="contentID" type="string" default="#arguments.instanceName#">
		
		<cfset var myContent = StructNew()>
		<cfset var stSettings = StructNew()>
		
		<cftry>
			<cfset stSettings = session.textPad[Arguments.InstanceName]>

			<!--- instantiate storage document --->
			<cfset oStorage = CreateObject("component","contentStorage")>
			<cfset oStorage.init("", stSettings.URL, false)>

			<cfif arguments.contentID eq "" and stSettings.contentID neq "">
				<cfset arguments.contentID = stSettings.contentID>
			</cfif>
			
			<cfif arguments.contentID neq "">
				<cfset stContent = oStorage.getEntry(Arguments.contentID)>
				
				<cfif stContent.found>
					<cfset writeOutput(stContent.content)>

					<!--- if there is no default content, then show link to go back to index --->
					<cfif stSettings.contentID eq "">
						<p><a href="javascript:#arguments.instanceName#.getIndex()"><strong>Back To Index</strong></a></p>
					</cfif>
				<cfelse>
					<!--- show index of entries --->
					<cfset getIndex(arguments.instanceName)>
				</cfif>
			<cfelse>
				<!--- show index of entries --->
				<cfset getIndex(arguments.instanceName)>
			</cfif>
			
			<cfcatch type="any">
				#cfcatch.Message# 
			</cfcatch>
		</cftry>		
	</cffunction>
	
	
	<!---------------------------------------->
	<!--- save                             --->
	<!---------------------------------------->		
	<cffunction name="save" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="content" type="string" default="1">
		<cfargument name="contentID" type="string" default="">
		<cfargument name="newContentID" type="string" default="#arguments.instanceName#">
		
		<cftry>
			<cfset stSettings = session.textPad[Arguments.InstanceName]>
			
			<cfif stSettings.isContentOwner>
				<!--- instantiate storage document --->
				<cfset oStorage = CreateObject("component","contentStorage")>
				<cfset oStorage.init("", stSettings.URL, false)>
				<cfset oStorage.saveEntry(arguments.contentID, arguments.newContentID, arguments.content)>						
		
				<b>Content saved.</b>
				<script>
					#arguments.instanceName#.saveCallback('#arguments.newContentID#');
				</script>				
			<cfelse>
				<cfthrow message="You must be signed-in and be the owner of this page to make changes.">
			</cfif>
			
			<cfcatch type="any">
				#cfcatch.Message# 
			</cfcatch>
		</cftry>		
	</cffunction>	


	<!---------------------------------------->
	<!--- getIndex                         --->
	<!---------------------------------------->	
	<cffunction name="getIndex" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="td">

		<cftry>
			<cfset stSettings = session.textPad[Arguments.InstanceName]>
			
			<!--- get list of content entries --->
			<cfset stSettings = session.textPad[InstanceName]>
			<cfset oStorage = CreateObject("component","contentStorage")>
			<cfset oStorage.init("", stSettings.URL, false)>
			<cfset qryContents = oStorage.getIndex()>
			
			<cfset tmpCreatedOn = oStorage.getCreateDate()>
			<cfset tmpOwner = oStorage.getOwner()>

			<cfsavecontent variable="tmpHTML">
				<cfloop query="qryContents">
					<li>
						<a href="javascript:#Arguments.InstanceName#.getContent('#qryContents.id#')">#qryContents.id#</a>
					</li>
				</cfloop>

				<p style="font-size:10px;">
					textPad created by <a href="/accounts/#tmpOwner#"><b>#tmpOwner#</b></a>
					<cfif tmpCreatedOn neq "">
					 on #tmpCreatedOn#
					</cfif>
				</p>
			</cfsavecontent> 
			
			#tmpHTML#
			 
			<cfcatch type="any">
				#cfcatch.Message# 
			</cfcatch>
		</cftry>		
	</cffunction>


	<!---------------------------------------->
	<!--- deleteEntry                      --->
	<!---------------------------------------->	
	<cffunction name="deleteEntry" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="contentID" type="string" required="yes">
		
		<cftry>
			<cfset stSettings = session.textPad[Arguments.InstanceName]>
			
			<cfif stSettings.isContentOwner>
				<!--- instantiate storage document --->
				<cfset oStorage = CreateObject("component","contentStorage")>
				<cfset oStorage.init("", stSettings.URL, false)>
				<cfset oStorage.deleteEntry(arguments.contentID)>			
					
				Entry deleted.
				<script>
					#arguments.instanceName#.deleteEntryCallback('#arguments.contentID#');
				</script>
			<cfelse>
				<cfthrow message="You must be signed-in and be the owner of this page to make changes.">
			</cfif>
			
			<cfcatch type="any">
				#cfcatch.Message# 
			</cfcatch>
		</cftry>		
	</cffunction>	


	<!-------------------------------------->
	<!--- getUserInfo                    --->
	<!-------------------------------------->
	<cffunction name="getUserInfo" returntype="struct" hint="returns info about the current logged in user">
		<cfset var stRet = StructNew()>
		<cfset stRet.username = "">
		<cfset stRet.isOwner = false>
		
		<cfif IsDefined("Session.homeConfig")>
			<cfif IsDefined("Session.User.qry")>
				<cfset stRet.username = session.user.qry.username>
				<cfset stRet.isOwner = (session.user.qry.username eq ListGetAt(session.homeConfig.href, 2, "/"))>
			</cfif>
		</cfif>
		
		<cfreturn stRet>
	</cffunction>	


	<!-------------------------------------->
	<!--- getContent                     --->
	<!-------------------------------------->
	<cffunction name="getContent" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="contentID" type="string" default="#arguments.instanceName#">
		
		<cfset var stSettings = 0>
		<cfset var stContent = 0>

		<cftry>
			<cfset stSettings = session.textPad[Arguments.InstanceName]>

			<!--- instantiate storage document --->
			<cfset oStorage = CreateObject("component","contentStorage")>
			<cfset oStorage.init("", stSettings.URL, false)>
			<cfset stContent = oStorage.getEntry(Arguments.contentID)>
			
			<cfset tmpID = createUUID()>
			<cfoutput>
				<div id="#tmpID#" style="display:none;">#stContent.content#</div>
				<script>
					#arguments.instanceName#.setContent("#stContent.id#","#tmpID#");
				</script>
			</cfoutput>
						
			<cfcatch type="any">
				#cfcatch.Message# 
			</cfcatch>
		</cftry>		
	</cffunction>

	<!---------------------------------------->
	<!--- getContentSelector               --->
	<!---------------------------------------->	
	<cffunction name="getContentSelector" access="remote" output="true" hint="Renders the interface to select entries for edit">
		<cfargument name="instanceName" type="string" default="td">

		<cfset var stSettings = StructNew()>
		<cfset var qryContents = QueryNew("")>
		
		<cftry>
			<!--- get list of content entries --->
			<cfset stSettings = session.textPad[InstanceName]>
			<cfset oStorage = CreateObject("component","contentStorage")>
			<cfset oStorage.init("", stSettings.URL, false)>
			<cfset qryContents = oStorage.getIndex()>
								
			<select name="EntryID" onchange="#arguments.InstanceName#.getContent(this.value)">
				<option value="">--- Select One ---</option>
				<cfloop query="qryContents">
					<option value="#qryContents.id#">#qryContents.id#</option>
				</cfloop>
			</select>
			 
			<cfcatch type="any">
				#cfcatch.Message# 
			</cfcatch>
		</cftry>			
	</cffunction>
	
</cfcomponent>
