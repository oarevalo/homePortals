<!--- 
vwModuleProperties

Configuration settings for a module

** This file should be included from addContent.cfc

History:
5/26/06 - oarevalo - created
---->

<cfset xmlDoc = "">
<cfset hasModuleInfo = false>

<cfset initContext()>
<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>
<cfset aModule = xmlSearch(xmlDoc,"//modules/module[@id='#Arguments.ModuleID#']")>
<cfset aLocations = xmlDoc.Page.layout.xmlChildren>

<cfset lstAttribs = "Name,location,id,Title,Container,Output,Display,ShowPrint,style,moduleHREF">

<cfif ArrayLen(aModule) gt 0>
	<cfset thisModule = aModule[1].xmlAttributes>
<cfelse>
	<cfset thisModule = StructNew()>
</cfif>

<cfparam name="thisModule.Name" default="">
<cfparam name="thisModule.Location" default="">
<cfparam name="thisModule.ID" default="">
<cfparam name="thisModule.title" default="">
<cfparam name="thisModule.container" default="true">
<cfparam name="thisModule.output" default="true">
<cfparam name="thisModule.Display" default="normal">
<cfparam name="thisModule.ShowPrint" default="true">
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

<cfset attributeInfo = StructNew()>
<cfset attributeInfo.title = "Enter a title for this module.">
<cfset attributeInfo.location = "The area on the page in which to display this module.">
<cfset attributeInfo.container = "Toggles between displaying the module inside a container or not.">
<cfset attributeInfo.toolbar = "Indicates whether to display the module toolbar icons or not.">
<cfset attributeInfo.styles = "Use this space to enter CSS rules to manipulate the appearance of the module.">

<cfoutput>
	<form name="frmModule" action="##" method="post">
		<input type="hidden" name="display" value="#thisModule.Display#" />
		<input type="hidden" name="output" value="#thisModule.output#" />
		<input type="hidden" name="name" value="#thisModule.name#" />
		<input type="hidden" name="moduleHREF" value="#thisModule.moduleHREF#" />
		<input type="hidden" name="location" value="#thisModule.location#" />
		<input type="hidden" name="style" value="#thisModule.style#" />
		<cfloop collection="#thisModule#" item="thisAttr">
			<cfif Not ListFindNoCase(lstAttribs,thisAttr)>
				<cfset tmpAttrValue = thisModule[thisAttr]>
				<input type="hidden" name="#thisAttr#" value="#tmpAttrValue#" style="width:130px;">
			</cfif>
		</cfloop>
				
		<div style="whitespace:nowrap;">		
			Title: 
			<input type="text" name="title" value="#thisModule.Title#" style="width:100px;">
		</div>
				
		<div style="margin-top:5px;margin-bottom:5px;">		
			<input type="checkbox" name="container" 
					style="border:0px;"
					value="true" 
					<cfif thisModule.container>checked</cfif> style="width:15px;"> 
				Show Container
		</div>

		<div style="margin-top:5px;margin-bottom:5px;">		
			<input type="checkbox" name="showPrint" 
					style="border:0px;"
					value="true" 
					<cfif thisModule.showPrint>checked</cfif> style="width:15px;"> 
				Show Toolbar
		</div>
	
		<div style="text-align:center;margin-top:10px;">
			<input type="hidden" name="id" value="#thisModule.ID#">
			<input type="hidden" name="_attribs" id="_attribs" value="#lstAttribs#">
			<input type="button" value="Save" onclick="controlPanel.saveModule(this.form)">
			<input type="button" value="Delete" onclick="if(confirm('Are you sure you wish to delete this module?')) controlPanel.deleteModule('#arguments.moduleID#')">
		</div>
		<p align="center">
			<a href="javascript:controlPanel.getModuleCSS('#thisModule.ID#');">[CSS Style]</a>
		</p>
	</form>
</cfoutput>
