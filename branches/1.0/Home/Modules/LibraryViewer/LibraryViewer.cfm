<!--- Displays information about a given Catalog resource --->

<!--- Init variables and Params --->
<cfparam name="attributes.Module" default="#StructNew()#">

<cfset args = Attributes.Module.XMLAttributes>
<cfset instanceName = Attributes.moduleID>

<!--- initialize server-side component --->
<cfset oModuleViewer = CreateObject("component","LibraryViewer")>
<cfset qryCatalogs = oModuleViewer.getCatalogs()>


<!--- client-side initialization --->
<cfoutput>	
	<cfsavecontent variable="tmpHead">
		<script type="text/javascript">
			#instanceName# = new libraryViewerClient();
			#instanceName#.instanceName = '#instanceName#';
			#instanceName#.contentID = '#instanceName#_content';
			#instanceName#.resourcesID = '#instanceName#_resourceList';
		</script>
		
		<style type="text/css">
			.resSelectorTable {
				border-bottom:2px solid black;
			}
			
			###instanceName#_content_BodyRegion {
				font-size:13px;
				font-family:verdana,sans-serif;
			}
			
			###instanceName#_content_BodyRegion h1 {
				color:##666666;
			}
			
			###instanceName#_content_BodyRegion h2 {
				margin-top:30px;
				background-color:##edf2f2;
				border-top:1px solid ##dddddd;
				border-bottom:1px solid ##dddddd;
				line-height:30px;
				font-size:14px;
				color:##666666;
				padding-left:5px;
			}
			.tblGrid {
				width:100%;
				border-collapse:collapse;
			}
			.tblGrid td {
				font-size:11px;
				border:1px solid silver;
				padding:2px;
			}
			.tblGrid th {
				font-size:12px;
				border-bottom:2px solid ##666666;
				background-color:##dddddd;
				border-top:1px solid white;
			}
		</style>
	</cfsavecontent>
	<cfhtmlhead text="#tmpHead#">	

	<table width="100%" class="resSelectorTable">
		<tr>
			<td>
				<select name="catalog" onchange="#instanceName#.getCatalogResources(this.value)">
					<option value="">--- Select a Catalog ---</option>
					<cfloop query="qryCatalogs">
						<option value="#index#">#label#</option>
					</cfloop>
				</select>
			</td>
			<td align="right" id="#instanceName#_resourceList_BodyRegion">&nbsp;</td>
		</tr>
	</table>
	
	<div id="#instanceName#_content_BodyRegion"></div>
</cfoutput>



	