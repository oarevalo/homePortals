<cfoutput>		
	<cfset instanceName = this.controller.getModuleID()>
	<style type="text/css">
		###instanceName#_BodyRegion,
		###instanceName#_BodyRegion table {
			font-size:11px;
			font-family:arial;
			text-align:left;
		}	
		.#instanceName#_showRow {display:tr;}
		.#instanceName#_hideRow {display:none;}
		###instanceName#_editItemTable input,
		###instanceName#_editItemTable select {
			border:1px solid silver;
			font-size:11px;
			width:100%;
			height:100%;
			//width:auto;
			//height:auto;
			padding:1px;
		}
	</style>
	
	<script type="text/javascript">
		#instanceName#.showMoreAttribs = function() {
			var rl = document.getElementById("#instanceName#_editMoreLabel");	
			var tb = document.getElementById("#instanceName#_editMoreBody");	
			if(rl) rl.className = "#instanceName#_hideRow";
			if(tb) tb.className = "#instanceName#_showRow";
		};
		
		#instanceName#.addItem = function(args) {
			#instanceName#.doAction('saveItem',args);
		}
	</script>	
</cfoutput>
