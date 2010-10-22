<!-- HTML Head code for the appointments module -->
<cfset moduleID = this.controller.getModuleID()>

<style type="text/css">
	.calendar_appointments {
		width:100%;
		border-collapse:collapse;
		margin-top:10px;
	}
	.calendar_appointments td {
		font-size:11px;
		padding:2px;
		border-bottom:1px solid #ebebeb;
		padding-left:5px;
	}
	.calendar_appointments th {
		font-size:11px;
		padding:2px;
		padding-left:5px;
		font-weight:bold;
		color:#990000;
		text-align:left;
		border-bottom:1px solid silver;
	}
	#frmEditAppointment {
		padding:0px;
		margin:0px;
	}
	#frmEditAppointment input {
		font-family:Arial, Helvetica, sans-serif;
		font-size:11px;
		border:1px solid black;
		padding:2px;
	}
	#frmEditAppointment textarea  {
		font-family:Arial, Helvetica, sans-serif;
		font-size:11px;
		width:475px;
		border:1px solid silver;
		padding:2px;
		height:320px;
		margin:5px;
	}		
</style>

<cfoutput>
	<script type="text/javascript">
		#moduleID#.getAppointmentsByDate = function(date) {
			#moduleID#.getView('main','',{viewBy:"day",date:date})
		};
	</script>
</cfoutput>
