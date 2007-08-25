<cfset targetID = this.controller.getModuleConfigBean().getPageSetting("targetID")>
<cfset moduleID = this.controller.getModuleID()>
<cfoutput>
	<script>
		#moduleID#.setURL = function(args) {
			this.getView('','',{url:args.url});
		};					
	</script>	

	<cfif this.controller.isFirstInClass()>
		<style type="text/css">
			.WebViewerSettings {
				background-color:##fefcd8;
				padding:10px;
				margin:0px;
				border:1px solid ##cccccc;
			}
			.WebViewerSettings input {
				border:1px solid black;
				font-size:11px;
				padding:1px;
			}	
		</style>
	</cfif>
</cfoutput>
