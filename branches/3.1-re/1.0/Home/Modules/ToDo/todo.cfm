<!--- ToDo.cfm
This module displays a to-do list, you can add, edit, delete
and set as complete/uncomplete items on the list.
All items are stored on an xml document, so that multiple
ToDo modules can coexist on a page.
--->

<!--- module parameters --->
<cfparam name="Attributes.moduleID">
<cfparam name="Attributes.module.xmlAttributes.URL">

<!--- client-side initialization --->
<cfset instanceName = Attributes.moduleID>
<cfsavecontent variable="tmpHead">
	<cfoutput>	
		<script type="text/javascript">
				#instanceName# = new toDoClient();
				#instanceName#.id = '#Attributes.moduleID#';
				#instanceName#.instanceName = '#instanceName#';
				#instanceName#.URL = '#Attributes.module.xmlAttributes.URL#';
		</script>
		<style type="text/css">
			###Attributes.moduleID#_BodyRegion {
				padding:0px;
				width:100%;
			}
			###Attributes.moduleID# input,
			###Attributes.moduleID# textarea,
			###Attributes.moduleID# select {
				font-size:11px;
				border:1px solid black;
				font-family:Arial, Helvetica, sans-serif;
			}
			###Attributes.moduleID# table {
				width: 100%;			
				font-size:10px;
				border-collapse:collapse;
			}
			.displayRow {
				display:tr;
			}			
			.hideRow {
				display:none;
			}	
			###Attributes.moduleID# form {
				background-color:##FFFF99;
				border:1px dashed silver;
			}
			.taskRowComplete {
				text-decoration:line-through;
				display:tr;
			}		
			.taskRowCompleteNoShow {
				display:none;
			}	
		</style>
	</cfoutput> 	
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">




