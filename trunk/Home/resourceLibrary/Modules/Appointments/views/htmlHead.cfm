<!-- HTML Head code for the fileBrowser module -->
<cfset moduleID = this.controller.getModuleID()>

<style type="text/css">
	.appointmentsToolbar {
		border:1px solid silver;
		background-color:#fefcd8;
		margin:0px;
		color:#993300;
		margin-top:10px;
		padding:2px;
		font-size:12px;
	}
	.appointmentsToolbar a {
		color:#333333 !important;
		font-weight:bold !important;
		font-size:10px;
	}	
	.appointmentsSettings {
		background-color:#fefcd8;
		padding:10px;
		margin:0px;
		border:1px solid #cccccc;
	}
	.appointmentsSettings input {
		border:1px solid black;
		font-size:11px;
		padding:1px;
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
		background-color:#B5EF65;
	}

	<cfoutput>

		###moduleID#_addItem {
			margin-top:20px;
		}
		###moduleID# input {
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border:1px solid black;
			padding:2px;
		}
		###moduleID# textarea  {
			padding:2px;
			font-family:Arial, Helvetica, sans-serif;
			font-size:11px;
			border:1px solid black;
		}	
	</cfoutput>
</style>

<cfoutput>
	<script type="text/javascript">
		#moduleID#.getAppointmentsByDate = function(date) {
			#moduleID#.getView('main','',{viewBy:"day",date:date})
		};
	</script>
</cfoutput>
