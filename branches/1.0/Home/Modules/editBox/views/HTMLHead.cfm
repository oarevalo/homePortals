<cfset moduleID = this.controller.getModuleID()>
<cfoutput>
	<style type="text/css">
		###moduleID# textarea {
			font-size:10px;
			border:1px solid silver;
			width:99%;
			height:200px;
			font-family:Arial, Helvetica, sans-serif;
		}		
		###moduleID#_toolbar {
			border:1px solid silver;
			background-color:##fefcd8;
			margin:0px;
			color:##993300;
			margin-top:10px;
			padding:2px;
			font-size:12px;
		}
		###moduleID#_toolbar select{
			font-size:10px;
			padding:1px;
			color:##333333;
		}	
		###moduleID#_toolbar a {
			color:##333333 !important;
			font-weight:bold;
			font-size:10px;
		}
	</style>
</cfoutput>