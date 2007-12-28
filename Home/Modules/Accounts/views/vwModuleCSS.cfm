<!--- 
vwModuleCSS

CSS settings for a module

** This file should be included from addContent.cfc

History:
5/29/06 - oarevalo - created
---->

<cfset xmlDoc = "">
<cfset hasModuleInfo = false>

<cfset initContext()>
<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>
<cfset aModule = xmlSearch(xmlDoc,"//modules/module[@id='#Arguments.ModuleID#']")>
<cfset lstAttribs = "id,style">

<cfif ArrayLen(aModule) gt 0>
	<cfset thisModule = aModule[1].xmlAttributes>
<cfelse>
	<cfset thisModule = StructNew()>
</cfif>

<cfparam name="thisModule.ID" default="">
<cfparam name="thisModule.style" default="">
<cfparam name="thisModule.moduleHREF" default="">

<cfif thisModule.moduleHREF neq "" >
	<cfset txtDoc = "">
	<cfset pathCatalog = ExpandPath(ListFirst(thisModule.moduleHREF, "##"))>
	<cfset catalogModuleID = ListLast(thisModule.moduleHREF, "##")>
	
	<cfif left(pathCatalog,4) neq "http">
		<cfif FileExists(pathCatalog)>
			<cffile action="read" file="#pathCatalog#" variable="txtDoc">
		</cfif>
	<cfelse>
		<cfhttp url="#thisModule.moduleHREF#" resolveurl="yes">
		</cfhttp>
		<cfset txtDoc = cfhttp.FileContent>
	</cfif>
	<cfif txtDoc neq "" and isXML(txtDoc)>
		<cfset xmlCatalog = xmlParse(txtDoc)>
		<cfset aModuleInfo = xmlSearch(xmlCatalog,"//module[@id='#catalogModuleID#']")>
		<cfset hasModuleInfo = (ArrayLen(aModuleInfo) gt 0)>
	</cfif>
</cfif>

<cfoutput>
	<form name="frmModule" action="##" method="post">
		
		Use this space to enter CSS rules to manipulate the appearance of the module.
		
		<textarea name="style" style="width:100%;font-size:10px;" rows="5">#thisModule.style#</textarea>
	
		<div style="text-align:center;margin-top:10px;">
			<input type="hidden" name="id" value="#thisModule.ID#">
			<input type="hidden" name="_attribs" id="_attribs" value="#lstAttribs#">
			<input type="button" value="Save" onclick="controlPanel.saveModule(this.form)">
		</div>
	</form>
</cfoutput>
