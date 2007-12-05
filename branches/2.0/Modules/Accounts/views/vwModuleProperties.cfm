<!--- 
vwModuleProperties

Configuration settings for a module

** This file should be included from addContent.cfc

History:
5/26/06 - oarevalo - created
---->

<cfset thisModule = variables.oPage.getModule(Arguments.ModuleID)>
<cfset lstAttribs = "id,Title,Container">

<cfparam name="thisModule.ID" default="">
<cfparam name="thisModule.title" default="">
<cfparam name="thisModule.container" default="true">

<cfset attributeInfo = StructNew()>
<cfset attributeInfo.title = "Enter a title for this module.">
<cfset attributeInfo.container = "Toggles between displaying the module inside a container or not.">

<cfoutput>
	<form name="frmModule" action="##" method="post">
		<input type="hidden" name="id" value="#thisModule.ID#">
		<input type="hidden" name="_allAttribs" id="_allAttribs" value="#lstAttribs#">

		<table width="100%">
			<tr>
				<td>ID:</td>
				<td><b>#thisModule.ID#</b></td>
			</tr>
			<tr>
				<td>Title:</td>
				<td>
					<input type="text" name="title" 
							value="#thisModule.Title#" 
							onkeyup="h_setModuleContainerTitle('#thisModule.ID#',this.value)"
							onblur="controlPanel.saveModule(document.frmModule)"
							style="width:100px;">
				</td>
			</tr>
			<tr>
				<td colspan="2">
					<input type="checkbox" name="container" 
							style="border:0px;"
							value="true" 
							onchange="controlPanel.saveModule(document.frmModule);"
							<cfif thisModule.container>checked</cfif> style="width:15px;"> 
						Show Container
				</td>
			</tr>				
		</table>
		
		<div style="text-align:center;margin-top:65px;border-top:1px solid black;padding-top:10px;font-family:arial;font-size:9px;">
			<a href="javascript:controlPanel.deleteModule('#arguments.moduleID#');"><img src="#imgRoot#/waste_small.gif" align="absmiddle" border="0"></a>
			<a href="javascript:controlPanel.deleteModule('#arguments.moduleID#');" style="font-weight:normal;">Delete</a>&nbsp;&nbsp;
			
			<a href="javascript:controlPanel.getModuleCSS('#thisModule.ID#');"><img src="#imgRoot#/css.png" align="absmiddle" border="0"></a>
			<a href="javascript:controlPanel.getModuleCSS('#thisModule.ID#');" style="font-weight:normal;">css</a>
		</div>
	</form>
</cfoutput>
