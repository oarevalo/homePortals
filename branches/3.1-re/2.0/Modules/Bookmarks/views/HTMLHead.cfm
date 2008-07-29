<cfset instanceName = this.controller.getModuleID()>

<cfif this.controller.isFirstInClass()>
	<style type="text/css">
		.BookmarksToolbar {
			border:1px solid silver;
			background-color:#fefcd8;
			margin:0px;
			color:#993300;
			margin-top:10px;
			padding:2px;
			font-size:12px;
		}
		.BookmarksToolbar a {
			color:#333333 !important;
			font-weight:bold !important;
			font-size:10px;
		}	
		.BookmarksSettings {
			background-color:#fefcd8;
			padding:10px;
			margin:0px;
			border:1px solid #cccccc;
		}
		.BookmarksSettings input {
			border:1px solid black;
			font-size:11px;
			padding:1px;
		}		
	</style>
</cfif>

<cfoutput>
	<style type="text/css">
		###instanceName# {
			font-size:11px;
			font-family:arial;
			text-align:left;
		}
		###instanceName# ul {
			margin-left:0px;
			margin-bottom:5px;
			padding:0px;
			list-style-type:none;
		}
		###instanceName# li {
			margin:0px;
			padding:0px;
		}
		###instanceName# li a {text-decoration:none;}
		###instanceName# li a:hover {text-decoration:underline;}
	</style>
</cfoutput>