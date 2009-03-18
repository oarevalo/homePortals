<cfscript>
	cfg =  this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	stUser = this.controller.getUserInfo();	

	stPageSettings = cfg.getPageSettings();

	stInputs = structNew();
	stOutputs = structNew();
	
	// get inputs and outputs
	for(s in stPageSettings) {
		if(left(s,7) eq "inputs_" and listLen(s,"_") gt 1) {
			argName = listRest(s,"_");
			if(not ListFindNoCase("METHOD,MODULEID,FIELDNAMES,_",argName))
				stInputs[argName] = stPageSettings[s];
		}

		if(left(s,8) eq "outputs_" and listLen(s,"_") gt 1) {
			argName = listRest(s,"_");
			stOutputs[argName] = stPageSettings[s];
		}
		
	}
	
	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";

</cfscript>


<cfoutput>
	<form name="frmSettings" action="##" method="post">
		<cfif Not stUser.isOwner>
			<div style="font-weight:bold;color:red;width:90%;margin:0 auto;">Only the owner of this page can make changes.</div><br>
		</cfif>
		
		<div style="width:90%;margin:0 auto;margin-top:10px;margin-bottom:20px;">
			<b>Configure Simple Adapter</b><br><br>
			This adapter allows you to transform input received from an event into a different message that can be fed
			into another module. Everytime an input is received by invoking the adapter's  "setInput", the adapter will
			raise an "onInputSet" event, that can be used to trigger methods in other modules. This event will be raised
			with the transformed message.
		</div>
		
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
		
		<table cellpadding="1" cellspacing="0" border="1" style="border-collapse:collapse;font-size:9px;width:90%;" align="center">
			<tr style="background-color:##ebebeb;"><th colspan="2">Outputs:</th></tr>
			<tr style="background-color:##ebebeb;">
				<th>Name</th>
				<th>Expression</th>
			</tr>
			<cfloop collection="#stOutputs#" item="i">
				<tr>
					<td><input type="text" name="outputName_#i#" value="#i#"></td>
					<td><input type="text" name="outputExpr_#i#" value="#stOutputs[i]#"></td>
				</tr>
			</cfloop>
			<tr>
				<td><input type="text" name="outputName" value=""></td>
				<td><input type="text" name="outputExpr" value=""></td>
			</tr>
		</table>
		<div style="font-size:9px;margin-left:20px;"><b>Note:</b> To erase an output member just clear the name and click on Save</div>

		<br>
		
		<p align="center">
			<input type="button" value="Save" onclick="#moduleID#.doFormAction('setOutput',this.form)" #tmpDisabled#>
			<input type="button" value="Close" onclick="#moduleID#.closeWindow()">
		</p>
	</form>
</cfoutput>
	