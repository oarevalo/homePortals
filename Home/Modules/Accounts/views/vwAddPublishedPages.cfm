<!--- 
vwAddPublishedPage

Allows user to select a published page to add to his site

** This file should be included from addContent.cfc

History:
6/1/06 - oarevalo - created
---->

<cfset aCatalogs = ArrayNew(1)>

<cfset initContext()>
<cfset aCatalogs = getCatalogs()>

<cfoutput>
	<div class="cp_sectionTitle" style="padding:0px;width:340px;">
		<table style="margin:2px;border-collapse:collapse;width:330px;" cellpadding="0" cellspacing="0">
			<td class="cpSectionTitleLabel">Add Published Page</td>
			<td align="right">
				<!--- Display menu with available catalogs --->
				<cfif arrayLen(aCatalogs) gt 1>
					<select name="selCatalog" onchange="controlPanel.getCatalogPages(this.value)">
						<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
							<option value="#aCatalogs[i].href#">"#aCatalogs[i].name#" catalog</option>
						</cfloop>
					</select>
					<a href="javascript:;" onclick="alert('Select the catalog from which to add the page.')"><img src="#this.accountsRoot#/default/info.gif" border="0" align="absmiddle" /></a>
				</cfif>
			</td> 
		</table>
	</div>
	
	<div class="cp_sectionBox" style="margin-top:0px;height:330px;width:340px;padding:0px;">
	<div id="catalogPages_BodyRegion" style="margin:10px;margin-top:5px;">
		<!--- by default display modules in first catalog --->
		<cfif arrayLen(aCatalogs) gt 0>
			<cfset arguments.catalog = aCatalogs[1].href>
		<cfelse>
			<cfset arguments.catalog = "">
		</cfif>
		<cfinclude template="vwCatalogPages.cfm">
	</div>	
	</div>
</cfoutput>
