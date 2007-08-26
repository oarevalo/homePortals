<cfparam name="resourceType" default="feed">
<cfset siteOwner = variables.oPage.getOwner()>
<cfset lstResourceTypes = "feed,content">
<cfset lstResourceTypeLabels = "Feeds,Content">

<cfset qryResources = getResourcesForAccount(resourceType)>

<cfquery name="qryResources" dbtype="query">
	SELECT *
		FROM qryResources
		WHERE owner = <cfqueryparam cfsqltype="cf_sql_varchar" value="#siteOwner#">
		ORDER BY package, id
</cfquery>

<!---- Styles --->
<style type="text/css">
	.rd_headBar {
		padding-right:10px;
		font-size:10px;
		border:1px solid #ccc;
		background-color:#ebebeb;
		border-bottom:0px;
		margin-left:10px;
		margin-right:10px;
		padding:5px;
	}
	.rd_headBar a, .rd_headBar a:active, .rd_headBar a:link, .rd_headBar a:hover {
		color:#333 !important;
	}
	#rd_mainArea {
		margin:10px;
		border:1px solid #ccc;
		height:300px;
		overflow:auto;
		background-color:#fff;
		line-height:18px;
		margin-top:0px;
	}
	#rd_mainArea table {
		font-size:10px;
	}
	#rd_mainArea th {
		background-color:#ebebeb;
		font-size:10px;
		line-height:11px;		
		border:1px solid silver;
	}
	#rd_footer {
		margin:10px;
		border:1px solid #ccc;
		background-color:#ebebeb;
	}
</style>


<cfset setControlPanelTitle("Resource Sharing","world")>

<div class="cp_sectionBox" 
	 style="padding:0px;margin:0px;width:475px;margin:10px;">
	<div style="margin:4px;">
		Modify your sharing settings for resources that you have created.
	</div>
</div>

<cfoutput>
	<div class="rd_headBar">
		<cfset i = 1>
		<cfloop list="#lstResourceTypes#" index="resType">
			<a href="##" 
				onclick="controlPanel.getView('Sharing',{resourceType:'#resType#'})"
				<cfif resType eq resourceType>style="font-weight:bold;"</cfif>>#listGetAt(lstResourceTypeLabels,i)#</a>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<cfset i = i + 1>
		</cfloop>
	</div>

	<div id="rd_mainArea">
	<table>
		<tr>
			<th align="left">Name</th>
			<th style="width:50px;">Public</th>
			<th style="width:50px;">Friends</th>
			<th style="width:50px;border-right:0px;">Private</th>
		</tr>
		<cfloop query="qryResources">
			<tr style="border-bottom:1px solid ##f5f5f5">
				<td>#qryResources.id#</td>
				<td align="center"><input type="radio" name="resAccess_#qryResources.currentRow#" value="general" <cfif qryResources.access eq "general">checked</cfif> onclick="controlPanel.setResourceAccess('#resourceType#','#jsStringFormat(qryResources.id)#',this.value)"></td>
				<td align="center"><input type="radio" name="resAccess_#qryResources.currentRow#" value="friend" <cfif qryResources.access eq "friend">checked</cfif> onclick="controlPanel.setResourceAccess('#resourceType#','#jsStringFormat(qryResources.id)#',this.value)"></td>
				<td align="center"><input type="radio" name="resAccess_#qryResources.currentRow#" value="owner" <cfif qryResources.access eq "owner">checked</cfif> onclick="controlPanel.setResourceAccess('#resourceType#','#jsStringFormat(qryResources.id)#',this.value)"></td>
			</tr>
		</cfloop>
	</table>
	</div>

	<fieldset id="rd_footer">
		<cfif resourceType eq "content">
			<input type="button" name="btnSave" value="Return To Content Directory" onclick="controlPanel.getView('Content')">
		<cfelseif resourceType eq "feed">
			<input type="button" name="btnSave" value="Return To Feed Directory" onclick="controlPanel.getView('Feeds')">
		</cfif>
	</fieldset>
	
</cfoutput>


