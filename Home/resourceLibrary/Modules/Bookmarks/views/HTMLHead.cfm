

<cfif this.controller.isFirstInClass()>
<style type="text/css">
	.Bookmarks2Settings {
		background-color:#fefcd8;
		padding:10px;
		margin:0px;
		border:1px solid #cccccc;
	}
	.Bookmarks2Settings input {
		border:1px solid black;
		font-size:11px;
		padding:1px;
	}	
</style>
</cfif>

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

<!---
		###instanceName#_BodyRegion td a {
			display:block;
			width:100%;
			
			text-decoration:none;
			padding:2px;
			border:1px solid ##e5e5e5;
		}
		###instanceName#_BodyRegion td a:hover {
			border:1px solid ##999999;
			background-color:##E7F8FE;
			text-decoration:none;
		}

---->		