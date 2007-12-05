<cfsetting showdebugoutput="false">

<cfset thisModule = getValue("stModule")>
<cfset lstAttribs = "Name,location,id,Title,Container,Output,Display,ShowPrint,style,moduleHREF">
<cfset lstAllAttribs = structKeyList(thisModule)>

<cfparam name="thisModule.ID" default="">
<cfparam name="thisModule.title" default="">
<cfparam name="thisModule.container" default="true">

<cfoutput>
	<div style="border-bottom:1px solid black;background-color:##ccc;text-align:right;line-height:22px;">
		<a href="?event=ehPage.dspEditModuleProperties&moduleID=#thisModule.id#"><img src="images/edit-page-yellow.gif" align="absmiddle" border="0"></a>
		<a href="?event=ehPage.dspEditModuleProperties&moduleID=#thisModule.id#" style="font-weight:normal;">Edit</a>&nbsp;&nbsp;

		<a href="javascript:doDeleteModule('#thisModule.ID#');"><img src="images/waste_small.gif" align="absmiddle" border="0"></a>
		<a href="javascript:doDeleteModule('#thisModule.ID#');" style="font-weight:normal;">Delete</a>&nbsp;&nbsp;
	</div>

	<div style="width:188px;margin-top:2px;">
		<table width="100%">
			<tr>
				<th width="10">ID:</th>
				<td>#thisModule.ID#</td>
			</tr>
			<tr>
				<th>Title:</th>
				<td>#thisModule.Title#</td>
			</tr>
			<tr>
				<th>Container:</th>
				<td>#YesNoFormat(thisModule.container)#</td>
			</tr>
		</table>
</div>
</cfoutput>


