<cfparam name="arguments.viewBy" default="">
<cfparam name="arguments.date" default="#now()#">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	
	stUser = this.controller.getUserInfo();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	bFailed = false;
	errorMessage = "";
	startDate = now();
	
	try {	
		// get content store
		setContentStoreURL();
		myContentStore = this.controller.getContentStore();
	
		// check if current user is owner
		bIsContentOwner = (stUser.username eq myContentStore.getOwner());

		if(arguments.viewBy eq "") arguments.viewBy = "agenda";
		if(arguments.date eq "") arguments.date = now();
		if(arguments.viewBy eq "agenda") arguments.date = now();
		
		arguments.date = DateFormat(Arguments.date, "mm/dd/yyyy");
		startDate = arguments.date;
		
		// get the appointments to display
		qryData = getAppointments(arguments.date, arguments.viewBy);
	
		switch(arguments.viewBy) {
			case "agenda": {
				startDate = DateFormat(Arguments.date, "mm/dd/yy");
				title = "Next 45 Days";
				delta = "";
				break;
			}
			case "day": {
				startDate = DateFormat(Arguments.date, "mm/dd/yy");
				title = DayOfWeekAsString(DayOfWeek(startDate)) & " " & LSDateFormat(startDate);
				delta = "d";
				break;
			}
			case "week": {
				startDate = DateFormat(dateAdd("d",dayofWeek(startDate)*-1,arguments.date), "mm/dd/yy");
				title = "Week of " & startDate ;
				delta = "ww";
				break;
			}
			case "month": {
				startDate = CreateDate(Year(arguments.date), month(arguments.date), 1);
				startDate = DateFormat(startDate, "mm/dd/yy");
				title = MonthAsString(Month(startDate)) & " " & Year(startDate);
				delta = "m";
				break;
			}
			default: {
				throw("view type not recognized");
			}
		}
			
		hasItems = (qryData.recordCount gt 0);
		if(delta neq "") {
			prevDate = DateFormat(DateAdd(delta,-1,startDate), "mm/dd/yyyy");
			nextDate = DateFormat(DateAdd(delta,1,startDate), "mm/dd/yyyy");	
		}
			
	} catch(any e) {
		aGroups = ArrayNew(1);
		bFailed = true;
		bIsContentOwner = stUser.isOwner;   // since we can't read the content store, 
											// assume the page owner is the content owner
		errMessage = e.message & "<br>" & e.detail;
	}	
</cfscript>

<cfoutput>
<!--- Display header ---->
<div style="border:1px solid silver;background-color:##ebebeb;padding:3px;">
	<a href="javascript:#moduleID#.getView('','',{viewBy:'agenda',date:'#Arguments.date#'});"><img src="#imgRoot#/date.png" align="absmiddle" border="0"></a>
	<cfif arguments.viewBy eq "agenda">
		<b>Agenda</b>
	<cfelse>
		<a href="javascript:#moduleID#.getView('','',{viewBy:'agenda',date:'#Arguments.date#'});">Agenda</a>
	</cfif>
	&nbsp;&nbsp;
	
	<a href="javascript:#moduleID#.getView('','',{viewBy:'day',date:'#Arguments.date#'});"><img src="#imgRoot#/date.png" align="absmiddle" border="0"></a>
	<cfif arguments.viewBy eq "day">
		<b>Day</b>
	<cfelse>
		<a href="javascript:#moduleID#.getView('','',{viewBy:'day',date:'#Arguments.date#'});">Day</a>
	</cfif>
	&nbsp;&nbsp;

	<a href="javascript:#moduleID#.getView('','',{viewBy:'week',date:'#Arguments.date#'});"><img src="#imgRoot#/application_view_columns.png" align="absmiddle" border="0"></a>
	<cfif arguments.viewBy eq "week">
		<b>Week</b>
	<cfelse>
		<a href="javascript:#moduleID#.getView('','',{viewBy:'week',date:'#Arguments.date#'});">Week</a>
	</cfif>
	&nbsp;&nbsp;

	<a href="javascript:#moduleID#.getView('','',{viewBy:'month',date:'#Arguments.date#'});"><img src="#imgRoot#/calendar.png" align="absmiddle" border="0"></a>
	<cfif arguments.viewBy eq "month">
		<b>Month</b>
	<cfelse>
		<a href="javascript:#moduleID#.getView('','',{viewBy:'month',date:'#Arguments.date#'});">Month</a>
	</cfif>
</div>

</cfoutput>

<cfif not bFailed>
	<cfoutput>
		<div style="font-weight:bold;font-size:13px;text-align:left;margin-top:10px;white-space:nowrap;">
			<cfif delta neq "">
				<a href="javascript:#moduleID#.getView('','',{date:'#prevDate#',viewBy:'#arguments.viewBy#'})" 
					><img src="#imgRoot#/arrow_left.gif" border="0" alt="Previous" title="Previous" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getView('','',{date:'#nextDate#',viewBy:'#arguments.viewBy#'})"
					><img src="#imgRoot#/arrow_right.gif" border="0" alt="Next" title="Next" align="absmiddle"></a>  
				| 
			</cfif>
			#Title#
		</div>
	</cfoutput>

	<table class="calendar_appointments" cellpadding="0" cellspacing="0" style="border-top:1px solid silver;">
		<cfoutput query="qryData" group="eventDate">
			<cfif arguments.viewBy neq "day">
				<tr><th colspan="3">#DayOfWeekAsString(DayOfWeek(eventDate))# #lsDateFormat(eventDate)#</th></tr>
			</cfif>
			<cfset i = 1>
			<cfoutput>
				<cfset tmpItemId = "#moduleID#_items_#i#">
				<cfset tmpDescription = qryData.description>
				<cfset tmpDate = dateFormat(qryData.eventDate,"mm/dd/yyyy")>
				<cfset tmpTime = qryData.eventTime>
				<cfset tmpSubject = qryData.subject>
				<cfset tmpEditJS = "#moduleID#.getPopupView('edit',{date:'#tmpDate#',id:'#qryData.id#'})">
				<cfset tmpDeleteJS = "if(confirm('Delete Appointment?')) #moduleID#.doAction('deleteAppointment',{date:'#tmpDate#',id:'#qryData.id#'})">
	
				<cftry>
					<cfset tmpTime = LSTimeFormat(tmpTime)>
					<cfcatch type="any">
					</cfcatch>
				</cftry>

				<cfif tmpSubject eq "">
					<cfset tmpSubject = left(tmpDescription,30)>
				</cfif>
				
				<cfif tmpSubject eq "">
					<cfset tmpSubject = "<em>No Description</em>">
				</cfif>

				<tr valign="top">
					<td style="width:10px;padding-right:10px;" nowrap="true"><strong>#tmpTime#</strong>&nbsp;</td>
					<cfif bIsContentOwner>
						<td id="#tmpItemId#">
							<a href="javascript:#tmpEditJS#">#tmpSubject#</a>
						</td>
						<td align="right" style="width:20px;">
							<a href="javascript:#tmpDeleteJS#" title="Delete Appointment" alt="Delete Appointment"><img src="#imgRoot#/delete2.gif" border="0" align="absmiddle"></a>
						</td>
					<cfelse>
						<td colspan="2" id="#tmpItemId#">#tmpSubject#</td>
					</cfif>
				</tr>					
				<cfset i = i + 1>
			</cfoutput>
			<tr><td colspan="3" style="border:0px;">&nbsp;</td></tr>
		</cfoutput>
		<cfif qryData.recordCount eq 0>
			<cfoutput>
				<tr><td colspan="3" style="border:0px;"><em><strong>No Appointments for this #arguments.viewBy#.</strong></em></td></tr>
			</cfoutput>
		</cfif>
	</table>

<cfelse>
	<b>Error:</b><br>
	<cfoutput>#errMessage#</cfoutput>
</cfif>

<cfif bIsContentOwner>
	<cfoutput>
	<div class="SectionToolbar">
		<a href="javascript:#moduleID#.getPopupView('edit',{date:'#startDate#'})"><img src="#imgRoot#/add-page-orange.gif" border="0" align="absmiddle" alt="Add New Appointment"></a>
		<a href="javascript:#moduleID#.getPopupView('edit',{date:'#startDate#'})"><strong>Add Event</strong></a>
		&nbsp;&nbsp;
		<a href="javascript:#moduleID#.getView('config')"><img src="#imgRoot#/check-orange.gif" border="0" align="absmiddle" alt="Change Settings"></a>
		<a href="javascript:#moduleID#.getView('config')"><strong>Settings</strong></a>
	</div>
	</cfoutput>
</cfif>

