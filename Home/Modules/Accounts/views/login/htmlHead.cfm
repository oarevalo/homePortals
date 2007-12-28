<cfset moduleID = this.controller.getModuleID()>

<cfoutput>
	<!--- instantiate client object --->
	<script type="text/javascript">
		loginClient = new loginClient();
		loginClient.contentID = '#moduleID#';
	</script>
	
	<!--- styles --->
	<style type="text/css">
		###moduleID# table,
		###moduleID# input {
			font-size:11px;
		}
	</style>
</cfoutput>
