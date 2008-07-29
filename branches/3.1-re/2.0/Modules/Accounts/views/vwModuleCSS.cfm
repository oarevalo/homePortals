<!--- 
vwModuleCSS

CSS settings for a module

** This file should be included from addContent.cfc

History:
5/29/06 - oarevalo - created
---->

<cfset thisModule = variables.oPage.getModule(Arguments.ModuleID)>
<cfset lstAttribs = "id,style">
<cfset lstAllAttribs = structKeyList(thisModule)>

<cfparam name="thisModule.ID" default="">
<cfparam name="thisModule.style" default="">
<cfparam name="thisModule.moduleHREF" default="">

<cfoutput>
	<form name="frmModule" action="##" method="post">
		
		Use this space to enter CSS properties to change the appearance of the module.
		
		<textarea name="style" style="width:100%;font-size:10px;margin-top:5px;" rows="4">#thisModule.style#</textarea>
	
		<div style="text-align:center;margin-top:10px;">
			<input type="hidden" name="id" value="#thisModule.ID#">
			<input type="hidden" name="_attribs" id="_attribs" value="#lstAttribs#">
			<input type="hidden" name="_allAttribs" id="_allAttribs" value="#lstAttribs#">

			<a href="javascript:controlPanel.saveModule(document.frmModule);"><img src="#imgRoot#/disk.png" align="absmiddle" border="0"></a>
			<a href="javascript:controlPanel.saveModule(document.frmModule);" style="font-weight:normal;">Save</a>&nbsp;&nbsp;

			<a href="javascript:controlPanel.getPartialView('ModuleProperties',{moduleID: '#thisModule.ID#'},'cp_pd_moduleProperties');"><img src="#imgRoot#/cross.png" align="absmiddle" border="0"></a>
			<a href="javascript:controlPanel.getPartialView('ModuleProperties',{moduleID: '#thisModule.ID#'},'cp_pd_moduleProperties');" style="font-weight:normal;">Cancel</a>&nbsp;&nbsp;
		</div>
	</form>
</cfoutput>
