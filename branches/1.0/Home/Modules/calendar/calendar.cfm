<!--- calendar 
This module displays a calendar
--->

<!--- module parameters --->
<cfparam name="Attributes.moduleID">
<cfparam name="Attributes.module.xmlAttributes.instanceName" default="">


<!--- client-side initialization --->
<cfset instanceName = Attributes.moduleID>


<cfoutput>	
<cfsavecontent variable="tmpHead">
	<script type="text/javascript">
		#instanceName# = new calendarClient();
		#instanceName#.id = '#Attributes.moduleID#';
		#instanceName#.instanceName = '#instanceName#';
	</script>

	<!--- define styles --->
	<style>
		###Attributes.moduleID#_BodyRegion {
			padding:0px;
		}
	
		.CalendarTable {
			font-family: Arial, Arial, Helvetica; 
			font-size : 11px;
			border-collapse:collapse;
			background-color:##FFFFFF;
			border:1px solid black;
			width:190px;
		}
		.CalendarTable td {
			border:1px solid silver;
			text-align:center;
		}
		A:LINK.DateLink,
		A:VISITED.DateLink {
			color:##996600;
			display:block;
			width:100%;
			text-decoration: none;
		}
		A:HOVER.DateLink {
			color:##FFFFFF;
			background-color:##99CC99;
			text-decoration: none;
		}
	</style>
	<!--[if IE]>
		<style>
			###Attributes.moduleID# {
				height:200px;
			}
			###Attributes.moduleID#_Body {
					height:100%;
			}
		</style>
	<![endif]-->

</cfsavecontent>
<cfhtmlhead text="#tmpHead#">
</cfoutput>

