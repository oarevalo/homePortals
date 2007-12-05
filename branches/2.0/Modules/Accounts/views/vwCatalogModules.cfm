<!--- 
vwCatalogModules

This is the view for CatalogModules screen. Displays a list
of all modules in the selected catalog for the user to add.
This file should be included from addContent.cfc

History:
1/19/06 - oarevalo - created
2/19/06 - oarevalo - added nessage when catalgo xml is not found / not valid xml
---->

<cfset txtDoc = "">
<cfset aModules = ArrayNew(1)>
<cfset i = 0>

<cftry>
	<!--- Display modules in catalog --->
	<cfset aModules = variables.oCatalog.getModules()>
					
	<!--- put modules into a query and sort them --->
	<cfset lstModules = "">
	<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
		<cfset lstModules = ListAppend(lstModules, aModules[j].id)>
	</cfloop>
	<cfset lstModules = ListSort(lstModules, "textnocase")>

	<cfoutput>
		<ul id="ModulesList">
		<cfloop from="1" to="#ListLen(lstModules)#" index="j">
			<cfset tmpItem = ListGetAt(lstModules, j)>
			<li id="#tmpItem#_add">
				<div>
					<a href="javascript:controlPanel.getAddModule('#tmpItem#')" 
						class="cpListLink" 
						style="font-weight:normal;" 
						>
					<img src="#imgRoot#/add.png" align="absmiddle" border="0">
					#tmpItem#</a>
				</div>
			</li>
		</cfloop>
		</ul>
	</cfoutput>
	
	<cfcatch type="any">
		<cfoutput>
			<br><b>Error:</b> #cfcatch.Message#
		</cfoutput>
	</cfcatch>
</cftry>
