<!--- Modules.cfm

This module displays a list of available modules on the default catalog
--->
<cfset defaultCatalog = "catalog.xml">

<cffile action="read" file="#expandpath(defaultCatalog)#" variable="txtDoc">
<cfset xmlCatalog = xmlParse(txtDoc)>
<cfset aModules = xmlSearch(xmlCatalog,"//module")>

<cfoutput>
	<cfloop from="1" to="#arrayLen(aModules)#" index="i">
		<li><a href="javascript:controlPanel.getAddModule('#aModules[i].xmlAttributes.id#','#defaultCatalog#')">#aModules[i].xmlAttributes.id#</a></li>
	</cfloop>
</cfoutput>