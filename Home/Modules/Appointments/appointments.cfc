<!--- appointments.cfc
	This component provides appointments editing functionality to the appointments module.
	Version: 1.12
	
	
	Changelog:
    - 1/24/06 - oarevalo - save owner when creating the datafile, only owner can add or change content
						 - show footnote with todo list owner and create date (if available)
						 - when owner is not signed in, do not show buttons to add or delete items
	- 1/27/06 - oarevalo - added views for daily, weekly and monthly appointments
						 - improved interface
						 - change delete icon
	- 2/24/06 - oarevalo - bug: date xml attribute not properly initialized
	- 2/28/06 - oarevalo - added more checks for session existence
--->
<cfcomponent displayname="appointments" extends="Home.Common.BaseRPC">

	<cfif StructKeyExists(session,"homeConfig")>
		<cfset this.baseDir = GetDirectoryFromPath(session.homeconfig.href)>
	</cfif>

	<!---------------------------------------->
	<!--- init                             --->
	<!---------------------------------------->
	<cffunction name="init" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="cal">
		<cfargument name="calendarURL" type="string" default="">
				
		<cfset var defContent = "<calendar />">
		<cfset var owner = "">

		<cftry>
			<cfif Not StructKeyExists(session,"homeConfig")>
				Your session has timed out. Please refresh this page.
				<cfexit>
			</cfif>

			<cfset owner = ListGetAt(session.homeConfig.href, 2, "/")>

			<!--- check that a data file is given --->
			<cfif arguments.calendarURL eq "">
				<cfset arguments.calendarURL = "/accounts/" & owner & "/myAppointments.xml">
			</cfif>

			<!--- get full path for the data file --->
			<cfset filePath = expandPath(arguments.calendarURL)>

			<!--- if the data file exists, then read it else create it --->
			<cfif FileExists(filePath)>
				<cffile action="read" file="#filePath#" variable="txtDoc">
			<cfelse>
				<cfset txtDoc = "<calendar owner=""#owner#"" createdOn=""#GetHTTPTimeString(now())#"" />">
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
				<cfset Session.Calendar[Arguments.InstanceName] = StructNew()>
				<cfset Session.Calendar[Arguments.InstanceName].xml = xmlParse(txtDoc)>
				<cfset Session.Calendar[Arguments.InstanceName].url = arguments.calendarURL>
				<cfset Session.Calendar[Arguments.InstanceName].isContentOwner = bIsContentOwner>
				<cfset Session.Calendar[Arguments.InstanceName].owner = tmpOwner>
				<cfset Session.Calendar[Arguments.InstanceName].createdOn = tmpcreatedOn>
				<cfset Session.Calendar[Arguments.InstanceName].viewMode = "day">
			<cfelse>
				<cfthrow message="The given document is not valid Appointments xml.">
			</cfif>

			<script>
				#Arguments.InstanceName#.getAppointments('#DateFormat(Now(),"mm/dd/yyyy")#');
			</script>
			
			<cfcatch type="any">
				#cfcatch.Message#<br>
				#cfcatch.Detail#
			</cfcatch>
		</cftry>
	</cffunction>


	<!---------------------------------------->
	<!--- getAppointments                  --->
	<!---------------------------------------->
	<cffunction name="getAppointments" access="remote" output="true">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="cal">
		<cfargument name="date" type="string" default="#Now()#">
		<cfargument name="viewMode" type="string" default="day" hint="day | week | month">

		<cfset var tmpHTML = "">
		<cfset var tmpDate = DateFormat(Arguments.date, "mm/dd/yyyy")>
		
		<cftry>
			<cfif Not StructKeyExists(session,"Calendar")>
				Your session has timed out. Please refresh this page.
				<cfexit>
			</cfif>
			
			<cfset xmlDoc = Session.Calendar[Arguments.InstanceName].xml>
			<cfset bIsContentOwner = Session.Calendar[Arguments.InstanceName].IsContentOwner>
			<cfset tmpURL = Session.Calendar[Arguments.InstanceName].url>
			<cfset tmpOwner = Session.Calendar[Arguments.InstanceName].owner>
			<cfset tmpCreatedOn = Session.Calendar[Arguments.InstanceName].createdOn>
			<cfset Session.Calendar[Arguments.InstanceName].viewMode = arguments.viewMode>

			<!--- put data in a query so it can be searched easier --->
			<cfset qryData = QueryNew("eventDate,eventDay,eventWeek,eventMonth,eventYear,eventTime,description")>
			
			<cfloop from="1" to="#ArrayLen(xmlDoc.xmlroot.xmlChildren)#" index="i">
				<cfset tmpNode = xmlDoc.xmlroot.xmlChildren[i]>
				<cfparam name="tmpNode.xmlAttributes.date" default="">
				<cfset tmpDate = tmpNode.xmlAttributes.date>
				
				<cfif IsDate(tmpDate)>
					<cfset QueryAddRow(qryData)>
					<cfset QuerySetCell(qryData,"eventDate",tmpDate)>
					<cfset QuerySetCell(qryData,"eventDay",day(tmpDate))>
					<cfset QuerySetCell(qryData,"eventWeek",week(tmpDate))>
					<cfset QuerySetCell(qryData,"eventMonth",month(tmpDate))>
					<cfset QuerySetCell(qryData,"eventYear",year(tmpDate))>
					<cfset QuerySetCell(qryData,"eventTime",tmpNode.xmlAttributes.time)>
					<cfset QuerySetCell(qryData,"description",tmpNode.xmlText)>
				</cfif>
			</cfloop> 
			
			<cfswitch expression="#arguments.viewMode#">
				<cfcase value="day">
					<cfset startDate = DateFormat(Arguments.date, "mm/dd/yyyy")>
					<cfset title = DayOfWeekAsString(DayOfWeek(startDate)) & " " & LSDateFormat(startDate)>
					<cfset delta = "d">
					<cfquery name="qryData" dbtype="query">
						SELECT *
							FROM qryData
							WHERE eventDate = '#startDate#'
					</cfquery>
				</cfcase>
				
				<cfcase value="week">
					<cfset startDate = DateFormat(Arguments.date, "mm/dd/yyyy")>
					<cfset title = "Week of " & startDate>
					<cfset delta = "ww">
					<cfquery name="qryData" dbtype="query">
						SELECT *
							FROM qryData
							WHERE eventWeek = #week(startDate)#
								AND eventYear = #Year(startDate)#
							ORDER BY eventDate
					</cfquery>
				</cfcase>
				
				<cfcase value="month">
					<cfset startDate = CreateDate(Year(arguments.date), month(arguments.date), 1)>
					<cfset startDate = DateFormat(startDate, "mm/dd/yyyy")>
					<cfset title = MonthAsString(Month(startDate)) & " " & Year(startDate)>
					<cfset delta = "m">
					<cfquery name="qryData" dbtype="query">
						SELECT *
							FROM qryData
							WHERE eventMonth = #Month(startDate)#
								AND eventYear = #Year(startDate)#
							ORDER BY eventDate
					</cfquery>
				</cfcase>
			</cfswitch>
			
			<cfset hasItems = (qryData.recordCount gt 0)>
			<cfset prevDate = DateFormat(DateAdd(delta,-1,startDate), "mm/dd/yyyy")>
			<cfset nextDate = DateFormat(DateAdd(delta,1,startDate), "mm/dd/yyyy")>

			<cfsavecontent variable="tmpHTML">		
				<table width="100%">
					<tr>
						<td colspan="2" style="font-weight:bold;font-size:14px;">#Title#</td>
					</tr>
					<tr>
						<td nowrap>
							<a href="javascript:#arguments.instanceName#.getAppointments('#prevDate#')" 
								><img src="/Home/Modules/Appointments/images/arrow_left.gif" border="0" alt="Previous" title="Previous"></a>
							<a href="javascript:#arguments.instanceName#.getAppointments('#nextDate#')"
								><img src="/Home/Modules/Appointments/images/arrow_right.gif" border="0" alt="Next" title="Next"></a>  
						</td>
						<cfif bIsContentOwner>
							<td align="right">
								<a href="javascript:#arguments.instanceName#.editAppointment('#startDate#',0)"><strong>New Appointment</strong></a>
							</td>
						</cfif>						
					</tr>
				</table>

				<table class="calendar_appointments" cellpadding="0" cellspacing="0">
					<cfoutput query="qryData" group="eventDate">
						<cfif arguments.viewMode neq "day">
							<tr><td colspan="3" style="font-weight:bold;color:##990000;">#DayOfWeekAsString(DayOfWeek(eventDate))# #lsDateFormat(eventDate)#</td></tr>
						</cfif>
						<cfset i = 1>
						<cfoutput>
							<cfset tmpItemId = "#Arguments.InstanceName#_items_#i#">
							<cfset tmpDescription = qryData.description>
							
							<tr valign="top">
								<td style="width:10px;padding-right:10px;"><strong>#qryData.eventTime#</strong>&nbsp;</td>
								<cfif bIsContentOwner>
									<td id="#tmpItemId#">
										<a href="javascript:#arguments.instanceName#.editAppointment('#DateFormat(qryData.eventDate, "mm/dd/yyyy")#',#i#)">#tmpDescription#</a>
									</td>
									<td align="right" style="width:20px;">
										<a href="javascript:#arguments.instanceName#.deleteAppointment('#DateFormat(qryData.eventDate, "mm/dd/yyyy")#',#i#)" title="Delete Appointment" alt="Delete Appointment"><img src="/Home/Modules/Appointments/Images/delete2.gif" border="0" align="absmiddle"></a>
									</td>
								<cfelse>
									<td colspan="2" id="#tmpItemId#">#qryData.description#</td>
								</cfif>
							</tr>					
							<cfset i = i + 1>
						</cfoutput>
						<tr><td colspan="3" style="border:0px;">&nbsp;</td></tr>
					</cfoutput>
					<cfif qryData.recordCount eq 0>
						<tr><td colspan="3" style="border:0px;"><em><strong>No Appointments for this #arguments.viewMode#.</strong></em></td></tr>
					</cfif>
				</table>
				

								
				<cfif tmpOwner neq "">
					<div style="font-size:10px;padding:2px;text-align:center;margin-top:10px;">
						Appointments list created by <a href="/Accounts/#tmpOwner#"><b>#tmpOwner#</b></a>
						<cfif tmpCreatedOn neq "">
						 on #tmpCreatedOn#
						</cfif>
						<!---
						<a href="#tmpURL#" target="_blank"><img src="/Home/Modules/Appointments/Images/xml.gif" border="0" align="absmiddle"></a>
						--->
					</div>
				</cfif>				
			</cfsavecontent>

			#tmpHTML#
			
			<cfcatch type="any">
				#cfcatch.Message#<br>
				#cfcatch.Detail#
			</cfcatch>
		</cftry>
	</cffunction>


	<!---------------------------------------->
	<!--- saveAppointment                  --->
	<!---------------------------------------->
	<cffunction name="saveAppointment" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="cal">
		<cfargument name="index" type="numeric" default="1">
		<cfargument name="description" type="string" default="">
		<cfargument name="time" type="string" default="">
		<cfargument name="date" type="string" default="">
		
		<cfset var tmpHTML = "">
		<cfset var tmpDate = DateFormat(Arguments.date, "mm/dd/yyyy")>

		<cftry>
			<cfif Not StructKeyExists(session,"Calendar")>
				Your session has timed out. Please refresh this page.
				<cfexit>
			</cfif>
					
			<cfset xmlDoc = Evaluate("Session.Calendar.#Arguments.InstanceName#.xml")>
			<cfset xmlURL = Evaluate("Session.Calendar.#Arguments.InstanceName#.url")>

			<cfif arguments.description eq "">
				<cfthrow message="Please enter a description for your appointment">
			</cfif>


			<cfif arguments.index gt 0>
				<cfset j = 0>
				<cfloop from="1" to="#ArrayLen(xmlDoc.calendar.xmlChildren)#" index="i">
					<cfif xmlDoc.calendar.xmlChildren[i].xmlAttributes.date eq tmpDate>
						<cfset j=j+1>
						<cfif j eq index>
							<cfset nodeIndex = i>
							<cfset i = ArrayLen(xmlDoc.calendar.xmlChildren) + 1>
						</cfif>
					</cfif>
				</cfloop>			
	
				<cfset xmlDoc.calendar.xmlChildren[nodeIndex].xmlText = arguments.description>
				<cfset xmlDoc.calendar.xmlChildren[nodeIndex].xmlAttributes["time"] = arguments.time>
				<cfset xmlDoc.calendar.xmlChildren[nodeIndex].xmlAttributes["date"] = tmpDate>
			<cfelse>
				<cfset newIndex = ArrayLen(xmlDoc.calendar.xmlChildren)+1>
				<cfset xmlDoc.calendar.xmlChildren[newIndex] = xmlElemNew(xmlDoc,"item")>
				<cfset xmlDoc.calendar.xmlChildren[newIndex].xmlText = arguments.description>
				<cfset xmlDoc.calendar.xmlChildren[newIndex].xmlAttributes["time"] = arguments.time>
				<cfset xmlDoc.calendar.xmlChildren[newIndex].xmlAttributes["date"] = tmpDate>
			</cfif>

			<cffile action="write" file="#expandpath(xmlURL)#" output="#toString(xmlDoc)#">
	
			#buildOutput(tmpHTML,Arguments.guid,Arguments.section)#
			
			<script>
				#Arguments.InstanceName#.getAppointments('#tmpDate#');
			</script>
			
			<cfcatch type="any">
				<script>
					alert("#JSStringFormat(cfcatch.Message)#");
					#Arguments.InstanceName#.getAppointments('#tmpDate#');
				</script>
			</cfcatch>
		</cftry>		
	</cffunction>	



	<!---------------------------------------->
	<!--- deleteAppointment                --->
	<!---------------------------------------->
	<cffunction name="deleteAppointment" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="date" type="string" default="1/1/1800">
		<cfargument name="index" type="numeric" default="1">
		
		<cfset var tmpHTML = "">
		<cfset var tmpDate = DateFormat(Arguments.date, "mm/dd/yyyy")>
		
		<cftry>
			<cfif Not StructKeyExists(session,"Calendar")>
				Your session has timed out. Please refresh this page.
				<cfexit>
			</cfif>		
			<cfset xmlDoc = Evaluate("Session.calendar.#Arguments.InstanceName#.xml")>
			<cfset xmlURL = Evaluate("Session.calendar.#Arguments.InstanceName#.url")>
			
			<cfset j = 0>
			<cfloop from="1" to="#ArrayLen(xmlDoc.calendar.xmlChildren)#" index="i">
				<cfif xmlDoc.calendar.xmlChildren[i].xmlAttributes.date eq tmpDate>
					<cfset j=j+1>
					<cfif j eq index>
						<cfset ArrayClear(xmlDoc.calendar.xmlChildren[i])>
						<cfbreak>
					</cfif>
				</cfif>
			</cfloop>

			<cffile action="write" file="#expandpath(xmlURL)#" output="#toString(xmlDoc)#">

			#buildOutput(tmpHTML,Arguments.guid,Arguments.section)#
			
			<script>
				#Arguments.InstanceName#.getAppointments('#tmpDate#');
			</script>
	
			<cfcatch type="any">
				#buildErrorOutput(Arguments.guid, Arguments.section, cfcatch)# 
			</cfcatch>
		</cftry>		
	</cffunction>	



	<!---------------------------------------->
	<!--- editAppointment                  --->
	<!---------------------------------------->
	<cffunction name="editAppointment" access="remote" output="true">
		<cfargument name="guid" default="-1">
		<cfargument name="section" default="" type="string">
		<cfargument name="instanceName" type="string" default="td">
		<cfargument name="date" type="string" default="1/1/1800">
		<cfargument name="index" type="numeric" default="0">
		
		<cfset var tmpHTML = "">
		<cfset var tmpDate = DateFormat(Arguments.date, "mm/dd/yyyy")>

		<cftry>
			<cfif Not StructKeyExists(session,"Calendar")>
				Your session has timed out. Please refresh this page.
				<cfexit>
			</cfif>	
			<cfset xmlDoc = Evaluate("Session.calendar.#Arguments.InstanceName#.xml")>

			<cfset aItems = xmlSearch(xmlDoc,"//item[@date='#tmpDate#']")>
			<cfif arguments.index gt 0>
				<cfset thisItem = aItems[arguments.index]>
			<cfelse>
				<cfset thisItem = StructNew()>
				<cfset thisItem.xmlText = "">
				<cfset thisItem.xmlAttributes = StructNew()>
			</cfif>
			

			<cfparam name="thisItem.xmlText" default="">
			<cfparam name="thisItem.xmlAttributes.date" default="#DateFormat(Now(),"mm/dd/yyyy")#">
			<cfparam name="thisItem.xmlAttributes.time" default="">
			
			<cfsavecontent variable="tmpHTML">
				<form action="##" method="post" name="frmEditAppointment" style="padding:5px;margin:0px;">
					<input type="hidden" name="date" value="#tmpDate#">
					
					<div style="font-weight:bold;color:##990000;font-size:14px;">#DayOfWeekAsString(DayOfWeek(tmpDate))# #lsDateFormat(tmpDate)#</div>

					<div style="margin-top:10px;margin-bottom:10px;">
						Time:
						<input type="text" name="time" value="#thisItem.xmlAttributes.time#" style="width:90px;">
					</div>
					
					<textarea rows="3" name="description" style="width:90%;">#thisItem.xmlText#</textarea>

					<p>
						<input type="button" value="Save Appointment" onclick="#Arguments.InstanceName#.saveAppointment(#arguments.index#,this.form)">
						<input type="button" value="Cancel" onclick="#Arguments.InstanceName#.getAppointments('#tmpDate#')">
					</p>
				</form>
			</cfsavecontent> 
			
			#buildOutput(tmpHTML,Arguments.guid,Arguments.section)#
			<cfcatch type="any">
				#buildErrorOutput(Arguments.guid, Arguments.section, cfcatch)# 
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
	
</cfcomponent>