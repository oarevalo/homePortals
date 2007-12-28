<!--- 
vwCatalogModules

This is the view for CatalogModules screen. Displays a list
of all modules in the selected catalog for the user to add.
This file should be included from addContent.cfc

History:
1/19/06 - oarevalo - created
2/19/06 - oarevalo - added nessage when catalgo xml is not found / not valid xml
---->

<cfset catalogIndex = 0>
<cfset txtDoc = "">
<cfset xmlCatalog = "">
<cfset aModules = ArrayNew(1)>
<cfset aCatalogs = ArrayNew(1)>
<cfset i = 0>

<cftry>
	<cfset initContext()>
	<cfset aCatalogs = getCatalogs()>
	
	<cfparam name="arguments.catalog" default="">

	<cfif arguments.catalog eq "">
		<cfif arrayLen(aCatalogs) gt 0>
			<cfset arguments.catalog = aCatalogs[1].href>
		<cfelse>
			<cfset arguments.catalog = "">
		</cfif>
	</cfif>
	
	<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
		<cfif aCatalogs[i].href eq arguments.catalog>
			<cfset catalogIndex = i>
			<cfbreak>
		</cfif>
	</cfloop>

	<cfif catalogIndex gt 0>
		<!--- Display modules in selected catalog --->
		<cfset selCatalog = aCatalogs[catalogIndex]>
		<cfset txtDoc = "">
		
		<cfif left(selCatalog.href,4) neq "http">
			<!--- read catalog from local filesystem --->
			<cfif FileExists(expandPath(selCatalog.href))>
				<cffile action="read" file="#expandPath(selCatalog.href)#" variable="txtDoc">
			</cfif>
		<cfelse>
			<!--- read catalog from remote server --->
			<cfhttp url="#selCatalog.href#" resolveurl="yes">
			</cfhttp>
			<cfset txtDoc = cfhttp.FileContent>
		</cfif>
		
		<!--- only display modules when catalog has been read --->
		<cfif txtDoc neq "" and isXML(txtDoc)>
			<cfset xmlCatalog = xmlParse(txtDoc)>
			<cfset aModules = xmlSearch(xmlCatalog,"//module")>
			
			<!--- put modules into a query and sort them --->
			<cfset lstModules = "">
			<cfloop from="1" to="#ArrayLen(aModules)#" index="j">
				<cfset lstModules = ListAppend(lstModules, aModules[j].xmlAttributes.id)>
			</cfloop>
			<cfset lstModules = ListSort(lstModules, "textnocase")>
	
			<cfoutput>
				<cfloop from="1" to="#ListLen(lstModules)#" index="j">
					<cfset tmpItem = ListGetAt(lstModules, j)>
					<img src="/Accounts/default/package.png" align="absmiddle">
					<a href="javascript:controlPanel.getAddModule('#tmpItem#','#selCatalog.href#')" 
						class="cpListLink" style="font-weight:normal;" 
						>#tmpItem#</a><br>
				</cfloop>
			</cfoutput>
		<cfelse>
			The catalog file was not found or is not a valid XML document.
		</cfif>		
	<cfelse>
		<h2>Subscribe to Catalog:</h2>
		
		<p style="font-size:12px;">Catalogs are lists of modules that you can add to a page.
		Enter the address of the catalog you wish to subscribe to.
		You may use relative or full addresses for the catalog location.</p>
		
		<form name="frmAdd" action="#" method="post" onSubmit="return false;" style="margin:0px;padding:0px;">
			<input type="text" name="href"  value="" style="width:260px;">&nbsp;
			<input type="button" value="GO" style="width:auto;" onclick="controlPanel.addCatalog(this.form)"><br />
		</form>
		
	</cfif>
	
	<cfcatch type="any">
		<br><b>Error:</b> #cfcatch.Message#
	</cfcatch>
</cftry>
