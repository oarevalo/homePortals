<!--- Appointments 
This module is used to maintain a list of appointments organized
by dates
--->
<cfset baseDir = GetDirectoryFromPath(session.homeconfig.href)>

<!--- module parameters --->
<cfparam name="Attributes.moduleID">
<cfparam name="Attributes.module.xmlAttributes.instanceName" default="">
<cfparam name="Attributes.module.xmlAttributes.CalendarURL" default="#baseDir#/../mycalendar.xml">


<!--- client-side initialization --->
<cfset instanceName = Attributes.moduleID>

<cfoutput>	
	<cfsavecontent variable="tmpHead">
		<script type="text/javascript">
			#instanceName# = new appointmentsClient();
			#instanceName#.id = '#Attributes.moduleID#';
			#instanceName#.instanceName = '#instanceName#';
			#instanceName#.contentID = '#Attributes.moduleID#_content';
			#instanceName#.calendarURL = '#Attributes.module.xmlAttributes.CalendarURL#';
		</script>
		
		<style type="text/css">
			###Attributes.moduleID#_BodyRegion {
				padding:0px;
				width:100%;
			}
			.calendar_appointments {
				width:100%;
				border-collapse:collapse;
				margin-top:10px;
			}
			.calendar_appointments td {
				font-size:11px;
				padding:2px;
				border-bottom:1px solid silver;
				padding-left:5px;
			}
			.calendar_appointments th {
				font-size:11px;
				background-color:##B5EF65
			}
			###Attributes.moduleID#_addItem {
				margin-top:20px;
			}
			###Attributes.moduleID# input {
				font-family:Arial, Helvetica, sans-serif;
				font-size:11px;
				border:1px solid black;
				padding:2px;
			}
			###Attributes.moduleID# textarea  {
				padding:2px;
				font-family:Arial, Helvetica, sans-serif;
				font-size:11px;
				border:1px solid black;
			}	
			.AppointmentsToolbar {
				margin-bottom:8px;
				margin-top:5px;
			} 
			.AppointmentsToolbar_cell {
				background-image:url(/Home/Modules/Appointments/images/bar_bg.gif);
				padding-left:8px;
				padding-right:8px;
				text-align:center;
			}
			.AppointmentsToolbar_link {
				font-family:Geneva, Arial, Helvetica, sans-serif !important;
				font-weight:bold;
				font-size:11px !important;
				text-decoration:none;
				color:##333333 !important;
			}
			.AppointmentsToolbar_link:hover {
				color:##990000 !important;
				text-decoration:none;
			}
		</style>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHead#">

	<!--- client-side static interface ---->
	<table cellpadding="0" cellspacing="0" class="AppointmentsToolbar" align="center">
		<tr>
			<td><img src="/Home/Modules/Appointments/images/bar_left.gif"></td>
			<td class="AppointmentsToolbar_cell"><a href="javascript:#instanceName#.setView('day');" class="AppointmentsToolbar_link">Day</a></td>
			<td><img src="/Home/Modules/Appointments/images/bar_separator.gif"></td>
			<td class="AppointmentsToolbar_cell"><a href="javascript:#instanceName#.setView('week');" class="AppointmentsToolbar_link">Week</a></td>
			<td><img src="/Home/Modules/Appointments/images/bar_separator.gif"></td>
			<td class="AppointmentsToolbar_cell"><a href="javascript:#instanceName#.setView('month');" class="AppointmentsToolbar_link">Month</a></td>
			<td><img src="/Home/Modules/Appointments/images/bar_right.gif"></td>
		</tr>
	</table>
	<div id="#Attributes.moduleID#_content_BodyRegion"></div>
</cfoutput> 	
