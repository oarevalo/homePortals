<!--- 
vwAddModule

Display information about a single module to add to the page

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
---->

<cfset initContext()>

<cfif left(arguments.Catalog,4) neq "http">
	<!--- read catalog from local filesystem --->
	<cfif FileExists(expandPath(arguments.Catalog))>
		<cffile action="read" file="#expandPath(arguments.Catalog)#" variable="txtDoc">
	</cfif>
<cfelse>
	<!--- read catalog from remote server --->
	<cfhttp url="#arguments.Catalog#" resolveurl="yes">
	</cfhttp>
	<cfset txtDoc = cfhttp.FileContent>
</cfif>

<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>
<cfset xmlCatalog = xmlParse(txtDoc)>

<cfset selModule = xmlSearch(xmlCatalog,"//module[@id='#arguments.moduleID#']")>
<cfset aLocations = xmlDoc.Page.layout.xmlChildren>

<cfoutput>
	<form action="##" method="post" style="margin:0px;padding:0px;" name="frmCPAddModule">
		<input type="hidden" name="moduleID" value="#arguments.moduleID#">
		<input type="hidden" name="catalog" value="#arguments.catalog#">
		<input type="hidden" name="locationID" value="#aLocations[1].xmlAttributes.Name#">
	
		<h2>#selModule[1].xmlattributes.id#</h2>
		#selModule[1].description.xmlText#<br /><br />
	
		<a href="javascript:controlPanel.addModule(document.frmCPAddModule)"><b style="font-size:13px;color:##990000;">+ Add this module</b></a>
		&nbsp;&nbsp;&nbsp;
		<a href="javascript:controlPanel.closeAddModule()"><b style="font-size:13px;color:##990000;">Close</b></a>
	</form>		
</cfoutput>	

