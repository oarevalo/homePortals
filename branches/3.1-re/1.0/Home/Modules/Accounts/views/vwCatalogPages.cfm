<!--- 
vwCatalogPages

This is the view for CatalogPages screen. Displays a list
of all pages in the selected catalog for the user to add.

History:
1/20/06 - oarevalo - created
---->

<cfset catalogIndex = 0>
<cfset txtDoc = "">
<cfset xmlCatalog = "">
<cfset aPages = ArrayNew(1)>
<cfset aCatalogs = ArrayNew(1)>
<cfset qryPages = QueryNew("href,name,description,createdOn,accountName,title")>
<cfset i = 0>
<cfset tmpRowsPerPage = 9>
<cfparam name="arguments.startRow" default="1">

<cftry>
	<cfset initContext()>
	<cfset aCatalogs = getCatalogs()>

	<!--- get accounts root --->
	<cfset accountsRoot = this.accountsRoot>
	
	<cfparam name="arguments.catalog" default="">
	
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
			<cfset aPages = xmlSearch(xmlCatalog,"//page")>
			
			<cfif ArrayLen(aPages) gt 0>
				<!--- put all published pages in a query --->
				<cfloop from="1" to="#arrayLen(aPages)#" index="j">
					<cfset QueryAddRow(qryPages,1)>
					<cfset QuerySetCell(qryPages, "href", aPages[j].xmlAttributes.href)>
					<cfset QuerySetCell(qryPages, "name", aPages[j].xmlAttributes.name)>
					<cfset QuerySetCell(qryPages, "description", aPages[j].xmlText)>
					<cfif StructKeyExists(aPages[j].xmlAttributes, "createdOn")>
						<cfset QuerySetCell(qryPages, "createdOn", aPages[j].xmlAttributes.createdOn)>
					</cfif>
					<cfif StructKeyExists(aPages[j].xmlAttributes, "title")>
						<cfset QuerySetCell(qryPages, "title", aPages[j].xmlAttributes.title)>
					<cfelse>
						<cfset QuerySetCell(qryPages, "title", aPages[j].xmlAttributes.name)>
					</cfif>
					<cfset QuerySetCell(qryPages, "accountName", ListGetAt(aPages[j].xmlAttributes.href, 2, "/"))>
				</cfloop>
				
				<!--- sort pages to show first the most recent --->
				<cfquery name="qryPages" dbtype="query">
					SELECT *
						FROM qryPages
						ORDER BY createdOn DESC
				</cfquery>
			</cfif>
			
			<cfset tmpEndRow = min(arguments.startRow+tmpRowsPerPage-1, qryPages.RecordCount)>
	
			<cfoutput>
				<Cfif arrayLen(aCatalogs) gt 1>
					<h2>Published pages in "#selCatalog.name#" catalog: </h2>
				</Cfif>
		
				<br /><b>Displaying pages #arguments.startRow# to #tmpEndRow# of #qryPages.recordCount#</b>
				<table cellpadding="0" cellspacing="0" style="margin-top:5px;width:100%;" border="0">
					<tr valign="top">
						<cfloop query="qryPages" startrow="#arguments.startRow#" endrow="#tmpEndRow#">
							<td style="padding:0px;width:33%;padding-bottom:5px;">
								<a href="javascript:controlPanel.addPageFromCatalog('#qryPages.href#','#selCatalog.href#','#qryPages.title#')" 
									><span style="color:##990000;font-weight:bold;">#qryPages.title#</span></a>
								<span style="font-size:9px;color:##999999;">
									by <a href="#accountsRoot#/#accountName#">#qryPages.accountName#</a>
									<cfif qryPages.createdOn neq "">
										<br>Published on #DateFormat(qryPages.createdOn,"mmm d")#
									</cfif>
									<cfif qryPages.description neq "">
										<br>#qryPages.description#
									</cfif>
								</span>
							</td>
							<cfif not qryPages.currentRow mod 3></tr><tr></cfif>
						</cfloop>
					</tr>
					<cfif qryPages.RecordCount eq 0>
						<tr><td colspan="3"><em>There are no published pages in this catalog.</em></td></tr>
					<cfelse>
						<tr><td colspan="3">&nbsp;</td></tr>
						<tr>
							<td align="center">
								<cfif arguments.startRow gt 1>
									<a href="javascript:controlPanel.getCatalogPages('#arguments.catalog#',#arguments.startRow-tmpRowsPerPage#);"><strong><< Previous</strong></a>
								</cfif>
							</td>
							<td>&nbsp;</td>
							<td align="center">
								<cfif tmpEndRow lt qryPages.recordCount>
									<a href="javascript:controlPanel.getCatalogPages('#arguments.catalog#',#arguments.startRow+tmpRowsPerPage#);"><strong>Next >></strong></a>
								</cfif>
							</td>
						</tr>
					</cfif>
				</table>
			</cfoutput>
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
		<cfoutput>
			<br><b>Error:</b> #cfcatch.Message#
		</cfoutput>
	</cfcatch>
</cftry>
