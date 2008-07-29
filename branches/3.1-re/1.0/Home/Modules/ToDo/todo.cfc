<!--- todo.cfc
	This component provides task list editing functionality to the todo module.
	Version: 1.1 
	
	
	Changelog:
    - 1/13/05 - oarevalo - save owner when creating the datafile, only owner can add or change content
						 - show footnote with todo list owner and create date (if available)
						 - when owner is not signed in, do not show buttons to add or delete items, disable save item
	- 1/27/06 - oarevalo - change delete icon
						 - fixed css to display properly in IE
	- 3/5/06 - oarevalo  - fixed bug. When indicating a custom datastore file, owner name was not being saved.
	- 4/20/06 - oarevalo - fixed bug. Added escaping of quotes when viewing items
--->
<cfcomponent displayname="toDo">

	<!---------------------------------------->
	<!--- init                             --->
	<!---------------------------------------->
	<cffunction name="init" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="URL" type="string" default="">
				
		<cfset var defContent = "<toDo />">
		<cfset var owner = "">
		<cftry>
			<!--- get page owner --->
			<cfset owner = ListGetAt(session.homeConfig.href, 2, "/")>

			<!--- check that a data file is given --->
			<cfif arguments.url eq "">
				<cfset arguments.url = "/accounts/" & owner & "/myTODO.xml">
			</cfif>

			<!--- get full path for the data file --->
			<cfset filePath = expandPath(arguments.URL)>

			<!--- if the data file exists, then read it else create it --->
			<cfif FileExists(filePath)>
				<cffile action="read" file="#filePath#" variable="txtDoc">
			<cfelse>
				<cfset txtDoc = "<toDo owner=""#owner#"" createdOn=""#GetHTTPTimeString(now())#"" />">
				<cffile action="write" file="#filePath#" output="#txtDoc#">
			</cfif>

			<!--- get current user info --->
			<cfset stUser = getUserInfo()>			
			
			<!--- check that the given file is a valid xml --->
			<cfif not IsXML(txtDoc)>
				<cfthrow message="The given document is not valid xml.">
			<cfelse>
				<cfset xmlDoc = xmlParse(txtDoc)>
			</cfif>
			
			<!--- if this todo has an owner, check that only the owner can update it --->
			<cfif StructKeyExists(xmlDoc.xmlRoot.xmlAttributes,"owner")>
				<cfset bIsContentOwner = (stUser.username eq xmlDoc.xmlRoot.xmlAttributes.owner)>
				<cfset tmpOwner = xmlDoc.xmlRoot.xmlAttributes.owner>
			<cfelse>
				<cfset bIsContentOwner = true>
				<cfset tmpOwner = "">
			</cfif> 						

			<cfif StructKeyExists(xmlDoc.xmlRoot.xmlAttributes,"createdOn")>
				<cfset tmpcreatedOn = xmlDoc.xmlRoot.xmlAttributes.createdOn>
			<cfelse>
				<cfset tmpcreatedOn = "">
			</cfif> 	

			<cfif txtDoc neq "">
				<cfset Session.ToDo[Arguments.InstanceName] = StructNew()>
				<cfset Session.ToDo[Arguments.InstanceName].xml = xmlParse(txtDoc)>
				<cfset Session.ToDo[Arguments.InstanceName].url = arguments.url>
				<cfset Session.ToDo[Arguments.InstanceName].category = "">
				<cfset Session.ToDo[Arguments.InstanceName].isContentOwner = bIsContentOwner>
				<cfset Session.ToDo[Arguments.InstanceName].owner = tmpOwner>
				<cfset Session.ToDo[Arguments.InstanceName].createdOn = tmpcreatedOn>
			<cfelse>
				<cfthrow message="The given document is not valid ToDo xml.">
			</cfif>
		
			<script>
				#Arguments.InstanceName#.getItems();
			</script>
			
			
			<cfcatch type="any">
				#cfcatch.Message#<br>#cfcatch.Detail# 
			</cfcatch>
		</cftry>
	</cffunction>
	
	
	<!---------------------------------------->
	<!--- getItems                         --->
	<!---------------------------------------->
	<cffunction name="getItems" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="category" type="string" default="">
		
		<cfset var tmpHTML = "">
		<cfset var bIsContentOwner = true>
		<cftry>
			<cfset xmlDoc = Session.ToDo[Arguments.InstanceName].xml>
			<cfset bIsContentOwner = Session.ToDo[Arguments.InstanceName].IsContentOwner>
			<cfset tmpOwner = Session.ToDo[Arguments.InstanceName].owner>
			<cfset tmpCreatedOn = Session.ToDo[Arguments.InstanceName].createdOn>
			
			<cfif arguments.category neq "">
				<cfset aItems = xmlSearch(xmlDoc,"//item[@category='#arguments.category#']")>
			<cfelse>
				<cfset aItems = xmlSearch(xmlDoc,"//item")>
			</cfif>
			
			<cfset Session.ToDo[Arguments.InstanceName].category = arguments.category>
			
			<!--- create categories list --->
			<cfset aItemsCat = xmlSearch(xmlDoc,"//item")>
			<cfset lstCats = "">
			<cfloop from="1" to="#ArrayLen(aItemsCat)#" index="i">
				<cfif Not ListFindNoCase(lstCats,aItemsCat[i].xmlAttributes.category)>
					<cfset lstCats = ListAppend(lstCats,aItemsCat[i].xmlAttributes.category)>
				</cfif>			
			</cfloop>
			<cfset lstCats = ListSort(lstCats,"textnocase")>
			
			<cfsavecontent variable="tmpHTML">
				<table width="100%" style="background-color:##FFFFFF;border:1px solid silver;">
					<tr>
						<td align="left" style="padding:3px;">
							<select name="lstCategory" onchange="#arguments.instanceName#.getItems(this.value)">
								<option value="">--- All Categories ---</option>
								<cfset i = 1>
								<cfset catIndex = 0>
								<cfloop list="#lstCats#" index="thisCat">
									<option value="#thisCat#"
											<cfif thisCat eq arguments.category>
												selected
												<cfset catIndex = i>
											</cfif>
										>#thisCat#</option>
									<cfset i = i +1>
								</cfloop>
							</select>
						</td>
						<cfset tmpItemID = "#Arguments.InstanceName#_items_#catIndex#_0">
						<td align="center" style="padding:3px;">
							<input type="checkbox" name="hideComplete" onclick="#arguments.instanceName#.hideComplete(this.checked)"> Hide Completed Tasks
						</td>
						<td align="right" style="padding:3px;">
							<cfif bIsContentOwner>
								<input type="button" 
										value="Add New Task" 
										style="font-size:10px;"
										onclick="#arguments.instanceName#.editItem('#arguments.category#',0,'#tmpItemID#')">
							</cfif>
						</td>
					</tr>
					<tr class="hideRow" id="#tmpItemId#_row">
						<td colspan="3" id="#tmpItemId#_BodyRegion">Loading...</td>
					</tr>
				</table>


				<table cellpading="0" cellspacing="0" border="0" style="margin-top:10px;">
					<cfif arguments.category neq "">
						<cfset lstCats = arguments.category>
					</cfif>
					
					<cfset catIndex = 1>
					<cfloop list="#lstCats#" index="thisCat">
						<cfset aCatItems = xmlSearch(xmlDoc,"//item[@category='#thisCat#']")>
						<tr style="background-color:##d3dbe3;color:black;">
							<td colspan="3" style="border-bottom:1px solid white;">&nbsp;&nbsp;<b>#thisCat#</b></td>
						</tr>
						<cfloop from="1" to="#arrayLen(aCatItems)#" index="i">
							<cfset tmpNode = aCatItems[i].xmlAttributes>
							<cfset tmpItemId = "#Arguments.InstanceName#_items_#catIndex#_#i#">
							<cfparam name="tmpNode.task" default="#Left(aCatItems[i].xmlText,50)#">
							<cfparam name="tmpNode.category" default="">

							<tr <cfif tmpNode.completed>class="taskRowComplete"</cfif>>
								<td style="width:20px;" align="center">
									<input type="checkbox" 
											<cfif tmpNode.completed>checked</cfif>
											<cfif not bIsContentOwner>disabled</cfif>
											onclick="#Arguments.InstanceName#.setItemStatus(this,'#thisCat#',#i#,'#tmpItemId#')"
											style="border:0px;">
								</td>
								<td id="#tmpItemId#">
									<a href="javascript:#arguments.instanceName#.editItem('#thisCat#', #i#,'#tmpItemID#')">#tmpNode.task#</a>
								</td>
								<td align="center" style="width:20px;">
									<cfif bIsContentOwner>
										<a href="javascript:#arguments.instanceName#.deleteItem('#thisCat#', #i#)"><img src="/Home/Modules/Appointments/Images/delete2.gif" border="0" align="absmiddle" title="Delete Task" alt="Delete Task"></a>
									</cfif>
								</td>
							</tr>
							<tr class="hideRow" id="#tmpItemId#_row">
								<td colspan="3" id="#tmpItemId#_BodyRegion">&nbsp;</td>
							</tr>
						</cfloop>
						<cfset catIndex = catIndex +1>
					</cfloop>
					<cfif arrayLen(aItems) eq 0>
						<tr>
							<td colspan="3"><em>No tasks created.</em></td>
						</tr>
					</cfif>
				</table>
				
				<cfif tmpOwner neq "">
					<div style="font-size:10px;padding:2px;text-align:center;margin-top:10px;">
						ToDo list created by <a href="/accounts/#tmpOwner#"><b>#tmpOwner#</b></a>
						<cfif tmpCreatedOn neq "">
						 on #tmpCreatedOn#
						</cfif>
					</div>
				</cfif>
			</cfsavecontent> 
			
			#tmpHTML#

			<cfcatch type="any">
				Error: #cfcatch.Message#<br>#cfcatch.Detail# 
			</cfcatch>
		</cftry>		
	</cffunction>
	
	
	<!---------------------------------------->
	<!--- setItemStatus                    --->
	<!---------------------------------------->
	<cffunction name="setItemStatus" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="index" type="numeric" default="1">
		<cfargument name="completed" type="boolean" default="true">
		<cfargument name="category" type="string" default="">
		
		<cfset var tmpHTML = "">
		<cftry>
			<cfset xmlDoc = Session.ToDo[Arguments.InstanceName].xml>
			<cfset xmlURL = Session.ToDo[Arguments.InstanceName].url>
			<cfset bIsContentOwner = Session.ToDo[Arguments.InstanceName].IsContentOwner>
			<cfset category = arguments.category>
			
			<cfif category neq "">
				<cfset aItems = xmlSearch(xmlDoc,"//item[@category='#category#']")>
			<cfelse>
				<cfset aItems = xmlSearch(xmlDoc,"//item")>
			</cfif>			
			
			<cfif not bIsContentOwner>
				<cfthrow message="Only the owner of this ToDo list can make changes to it.">
			</cfif>
			
			<cfset aItems[arguments.index].xmlAttributes.completed = arguments.completed>
			<cffile action="write" file="#expandpath(xmlURL)#" output="#toString(xmlDoc)#">
	
			#tmpHTML#
			<cfcatch type="any">
				Error: #cfcatch.Message#<br>#cfcatch.Detail# 
			</cfcatch>
		</cftry>		
	</cffunction>	
	

	<!---------------------------------------->
	<!--- saveItem                         --->
	<!---------------------------------------->
	<cffunction name="saveItem" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="index" type="numeric" default="1">
		<cfargument name="completed" type="boolean" default="true">
		<cfargument name="task" type="string" default="">
		<cfargument name="category" type="string" default="">
		<cfargument name="description" type="string" default="">
		
		<cfset var tmpHTML = "">
		<cftry>
			<cfset xmlDoc = Session.ToDo[Arguments.InstanceName].xml>
			<cfset xmlURL = Session.ToDo[Arguments.InstanceName].url>
			<cfset bIsContentOwner = Session.ToDo[Arguments.InstanceName].IsContentOwner>
			<cfset currentcategory = Session.ToDo[Arguments.InstanceName].category>

			<cfif not bIsContentOwner>
				<cfthrow message="Only the owner of this ToDo list can make changes to it.">
			</cfif>
	
			<cfif arguments.index gt 0>
				<cfif currentcategory eq "">
					<cfset nodeIndex = arguments.index>
				<cfelse>
					<cfset j = 0>
					<cfloop from="1" to="#ArrayLen(xmlDoc.toDo.xmlChildren)#" index="i">
						<cfif xmlDoc.toDo.xmlChildren[i].xmlAttributes.category eq currentcategory>
							<cfset j=j+1>
							<cfif j eq index>
								<cfset nodeIndex = i>
								<cfset i = ArrayLen(xmlDoc.toDo.xmlChildren) + 1>
							</cfif>
						</cfif>
					</cfloop>			
				</cfif>
	
				<cfset xmlDoc.toDo.xmlChildren[nodeIndex].xmlText = arguments.description>
				<cfset xmlDoc.toDo.xmlChildren[nodeIndex].xmlAttributes["completed"] = arguments.completed>
				<cfset xmlDoc.toDo.xmlChildren[nodeIndex].xmlAttributes["task"] = arguments.task>
				<cfset xmlDoc.toDo.xmlChildren[nodeIndex].xmlAttributes["category"] = arguments.category>
				<cfif arguments.completed>
					<cfset xmlDoc.toDo.xmlChildren[nodeIndex].xmlAttributes["completeDate"] = Now()>
				</cfif>
			<cfelse>
				<cfset newIndex = ArrayLen(xmlDoc.toDo.xmlChildren)+1>
				<cfset xmlDoc.toDo.xmlChildren[newIndex] = xmlElemNew(xmlDoc,"item")>
				<cfset xmlDoc.toDo.xmlChildren[newIndex].xmlText = arguments.description>
				<cfset xmlDoc.toDo.xmlChildren[newIndex].xmlAttributes["completed"] = arguments.completed>
				<cfset xmlDoc.toDo.xmlChildren[newIndex].xmlAttributes["createDate"] = Now()>
				<cfset xmlDoc.toDo.xmlChildren[newIndex].xmlAttributes["task"] = arguments.task>
				<cfset xmlDoc.toDo.xmlChildren[newIndex].xmlAttributes["category"] = arguments.category>
				<cfif arguments.completed>
					<cfset xmlDoc.toDo.xmlChildren[newIndex].xmlAttributes["completeDate"] = Now()>
				</cfif>
			</cfif>

			<cffile action="write" file="#expandpath(xmlURL)#" output="#toString(xmlDoc)#">
	
			#tmpHTML#
			
			<script>
				#Arguments.InstanceName#.getItems('#currentcategory#');
			</script>
			
			<cfcatch type="any">
				Error: #cfcatch.Message#<br>#cfcatch.Detail# 
			</cfcatch>
		</cftry>		
	</cffunction>	



	<!---------------------------------------->
	<!--- deleteItem                       --->
	<!---------------------------------------->
	<cffunction name="deleteItem" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="index" type="numeric" default="1">
		<cfargument name="category" type="string" default="">
		
		<cfset var tmpHTML = "">
		<cftry>
			<cfset xmlDoc = Session.ToDo[Arguments.InstanceName].xml>
			<cfset xmlURL = Session.ToDo[Arguments.InstanceName].url>
			<cfset bIsContentOwner = Session.ToDo[Arguments.InstanceName].IsContentOwner>
			<cfset category = arguments.category>

			<cfif not bIsContentOwner>
				<cfthrow message="Only the owner of this ToDo list can make changes to it.">
			</cfif>

			<cfif category eq "">
				<cfset ArrayClear(xmlDoc.toDo.xmlChildren[index])>
			<cfelse>
				<cfset j = 0>
				<cfloop from="1" to="#ArrayLen(xmlDoc.toDo.xmlChildren)#" index="i">
					<cfif xmlDoc.toDo.xmlChildren[i].xmlAttributes.category eq category>
						<cfset j=j+1>
						<cfif j eq index>
							<cfset ArrayClear(xmlDoc.toDo.xmlChildren[i])>
							<cfbreak>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>

			<cffile action="write" file="#expandpath(xmlURL)#" output="#toString(xmlDoc)#">

			#tmpHTML#
			
			<script>
				#Arguments.InstanceName#.getItems('#category#');
			</script>
	
			<cfcatch type="any">
				Error: #cfcatch.Message#<br>#cfcatch.Detail# 
			</cfcatch>
		</cftry>		
	</cffunction>	



	<!---------------------------------------->
	<!--- editItem                         --->
	<!---------------------------------------->	
	<cffunction name="editItem" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="index" type="numeric" default="0">
		<cfargument name="category" type="string" default="">
		
		<cfset var tmpHTML = "">
		<cftry>
			<cfset xmlDoc = Evaluate("Session.ToDo.#Arguments.InstanceName#.xml")>
			<cfset bIsContentOwner = Session.ToDo[Arguments.InstanceName].IsContentOwner>
			<!--- <cfset category = Evaluate("Session.ToDo.#Arguments.InstanceName#.category")> --->
			<cfset category = arguments.category>
			
			<cfif Arguments.index gt 0>
				<cfif category neq "">
					<cfset aItems = xmlSearch(xmlDoc,"//item[@category='#category#']")>
					<cfset thisItem = aItems[arguments.index]>
				<cfelse>
					<cfset thisItem = xmlDoc.toDo.xmlChildren[arguments.index]>
				</cfif>
			<cfelse>
				<cfset thisItem = StructNew()>
				<cfset thisItem.xmlAttributes = StructNew()>
			</cfif>

			<cfparam name="thisItem.xmlText" default="">
			<cfparam name="thisItem.xmlAttributes.completed" default="false">
			<cfparam name="thisItem.xmlAttributes.createDate" default="#DateFormat(Now(),"mm/dd/yyyy")#">
			<cfparam name="thisItem.xmlAttributes.completeDate" default="">
			<cfparam name="thisItem.xmlAttributes.category" default="#category#">
			<cfparam name="thisItem.xmlAttributes.task" default="">
			
			<cfsavecontent variable="tmpHTML">
				<form action="##" method="post" name="frmEditItem" style="padding:0px;margin:0px;padding:5px;" id="frmEditItem">
				<table cellpading="0" cellspacing="0" border="0" width="90%"  style="font-size:10px;">
					<tr valign="middle" style="font-size:11px;">
						<td><strong>Created On:</strong></td>
						<td>#DateFormat(thisItem.xmlAttributes.createDate,"mm/dd/yyyy")#</td>
						<td><strong>Completed On:</strong></td>
						<td>#DateFormat(thisItem.xmlAttributes.completeDate,"mm/dd/yyyy")#</td>
					</tr>
					<tr><td colspan="4"><hr></td></tr>
					<tr>
						<td width="90"><strong>Task Complete?</strong></td>
						<td colspan="3"><input type="checkbox" name="completed" <cfif thisItem.xmlAttributes.completed>checked</cfif> style="border:0px;"></td>
					</tr>
					<tr>
						<td><strong>Category:</strong></td>
						<td colspan="3"><input type="text" name="category" value="#htmlEditFormat(thisItem.xmlAttributes.category)#" style="width:80%"></td>
					</tr>
					<tr>
						<td><strong>Task:</strong></td>
						<td colspan="3"><input type="text" name="task" value="#htmlEditFormat(thisItem.xmlAttributes.task)#" style="width:80%"></td>
					</tr>					
					<tr>
						<td colspan="4">
							<textarea name="description" rows="5" style="width:90%;">#thisItem.xmlText#</textarea>
						</td>
					</tr>
				</table>
				<div style="margin:10px;margin-left:0px;">
					<input type="button" value="Save Task" onclick="#Arguments.InstanceName#.saveItem(#arguments.index#,this.form)" <cfif not bIsContentOwner>disabled</cfif>>
					<input type="button" value="Cancel" onclick="#Arguments.InstanceName#.closeEdit('#Arguments.InstanceName#_items_#arguments.index#')">
				</div>
				</form>
			</cfsavecontent> 
			
			#tmpHTML#
			<cfcatch type="any">
				Error: #cfcatch.Message#<br>#cfcatch.Detail# 
			</cfcatch>
		</cftry>		
	</cffunction>	
	
	<!-------------------------------------->
	<!---                                --->
	<!--- getUserInfo                    --->
	<!---                                --->
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
	
</cfcomponent>
