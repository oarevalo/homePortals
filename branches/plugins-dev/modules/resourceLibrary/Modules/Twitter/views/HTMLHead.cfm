
<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
</cfscript>	
	
<cfoutput>
    <script language="Javascript" type="text/javascript">
		#moduleID#.getTweets = function(args) {
			this.getView('','',{account:arguments[0]});
		};		
    </script>

</cfoutput>
