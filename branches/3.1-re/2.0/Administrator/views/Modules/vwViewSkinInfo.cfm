<cfset xmlResNode = getValue("xmlResNode",0)>
<cfset id = getValue("id","")>

<style type="text/css">
	h2.title {
		margin-top:30px;
		background-color:#edf2f2;
		border-top:1px solid #dddddd;
		border-bottom:1px solid #dddddd;
		line-height:30px;
		font-size:14px;
		color:#666666;
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
		border-bottom:2px solid #666666;
		background-color:#dddddd;
		border-top:1px solid white;
		color:black;
	}
</style>

<h2>Module Library > View Skin Information</h2>

<cfoutput>
	<table width="100%" style="margin-top:10px;margin-bottom:0px;border-top:1px solid black;">
		<tr valign="top">
			<td><h1 style="margin-top:0px;">#xmlResNode.xmlAttributes.id#</h1></td>
		</tr>
	</table>

	<h2 style="margin-top:0px;" class="title">HREF:</h2>
	<a href="#xmlResNode.xmlAttributes.href#" target="_blank">#xmlResNode.xmlAttributes.href#</a>

	<h2 class="title">Description:</h2>
	<cfif xmlResNode.xmlText neq "">
		#xmlResNode.xmlText#
	<cfelse>
		N/A
	</cfif>

	<cfif StructKeyExists(xmlResNode,"images")>
		<h2 class="title">Images:</h2>
		<cfloop from="1" to="#arrayLen(xmlResNode.images.xmlChildren)#" index="i">
			<cfset tmpNode = xmlResNode.images.xmlChildren[i]>
			<cfparam name="tmpNode.xmlAttributes.url" default="">
			<cfparam name="tmpNode.xmlAttributes.label" default="">
			<cfparam name="tmpNode.xmlAttributes.thumbURL" default="#tmpNode.xmlAttributes.url#">

			<div style="display:inline;">
				<a href="#tmpNode.xmlAttributes.url#" target="_blank">
					<img src="#tmpNode.xmlAttributes.thumbURL#" 
							alt="#tmpNode.xmlAttributes.label#" 
							title="#tmpNode.xmlAttributes.label#" 
							border="0"></a><br>
				#tmpNode.xmlAttributes.label#
			</div>
		</cfloop>
	</cfif>
</cfoutput>

<p>
	<input type="button" 
			name="btnCancel" 
			value="Return To Module Library" 
			onClick="document.location='?event=ehModules.dspMain'">
</p>
	