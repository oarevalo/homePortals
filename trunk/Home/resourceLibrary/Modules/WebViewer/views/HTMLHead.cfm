<cfset targetID = this.controller.getModuleConfigBean().getPageSetting("targetID")>
<cfset moduleID = this.controller.getModuleID()>
<cfoutput>
	<script>
		#moduleID#.setURL = function(args) {
			this.getView('','',{url:args.url});
		};					
	</script>	
</cfoutput>
