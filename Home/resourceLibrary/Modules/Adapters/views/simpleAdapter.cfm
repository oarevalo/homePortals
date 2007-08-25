<cfscript>
	cfg =  this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	stUser = this.controller.getUserInfo();	

	// get module path
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	// get inputs 
	stInputs = getInputs();
	
	// get echo input flag
	bEchoInputs = cfg.getPageSetting("echoInputs",true);
</cfscript>

<cfoutput>
	<cfif bEchoInputs>
		<table cellpadding="1" cellspacing="0" border="1" style="border-collapse:collapse;font-size:9px;width:90%;" align="center">
			<tr style="background-color:##ebebeb;"><th colspan="2">Inputs:</th></tr>
			<tr style="background-color:##ebebeb;">
				<th>Name</th>
				<th>Value</th>
			</tr>
			<cfset inputCount = 0>
			<cfloop collection="#stInputs#" item="i">
				<tr>
					<td>#i#</td>
					<td>#stInputs[i]#</td>
				</tr>
				<cfset inputCount = inputCount + 1>
			</cfloop>
			<cfif inputCount eq 0>
				<tr><td colspan="2" align="center"><em>No inputs detected</em></td></tr>
			</cfif>
		</table>
		<br><br>
	</cfif>
	
	<cfif stUser.isOwner>
		<div id="toolbar">
			<a href="javascript:#moduleID#.getPopupView('simpleAdapterConfig');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getPopupView('simpleAdapterConfig');">Configure Adapter</a>
		</div>
	</cfif>		
		
	<cfsavecontent variable="tmpHead">
		<script>
			#moduleID#.setInput = function(args) {
				this.doAction('setInput', args);
			}
			#moduleID#.fireOutput = function() {
				this.doAction('fireOutput');
			}
		</script>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHead#">
</cfoutput>
	