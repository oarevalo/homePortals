<!--- 
vwCatalogs

Display the view to manage site catalogs

** This file should be included from addContent.cfc

History:
5/31/06 - oarevalo - created
---->

<cfset initContext()>
<cfset aCatalogs = getCatalogs()>

<cfoutput>
<div class="cp_sectionTitle" style="width:340px;padding:0px;"><div style="margin:2px;">Site Catalogs</div></div>
<div class="cp_sectionBox" style="margin-top:0px;height:200px;padding:0px;margin-bottom:0px;width:340px;">
	<table class="cp_dataTable" cellspacing="0" style="border-bottom:0px;">
		<tr>
			<th>&nbsp;Name</th>
			<th>HREF</th>
			<th width="50" style="text-align:center;">Action</th>
		</tr>	
		<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
			<tr <cfif i mod 2>style="background-color:##f3f3f3;"</cfif>>
				<td>&nbsp;#aCatalogs[i].name#</td>
				<td>#aCatalogs[i].href#</td>
				<td style="text-align:center;">
					<a href="javascript:controlPanel.removeCatalog('#aCatalogs[i].href#');"><img src="#this.accountsRoot#/default/waste_small.gif" border="0" alt="Delete" title="Delete Catalog"></a>
				</td>
			</tr>
		</cfloop>	
		<cfif arrayLen(aCatalogs) eq 0>
			<tr>
				<td colspan="3"><em>No catalogs found!</em></td>
			</tr>
		</cfif>
	</table>
</div>
<div class="cp_sectionBox" style="margin-top:0px;height:20px;background-color:##ccc;border-top:0px;padding-bottom:0px;width:340px;padding:0px;">
	<b>Legend:</b> 
	&nbsp;&nbsp;
	<img src="#this.accountsRoot#/default/waste_small.gif" border="0" alt="Delete" align="absmiddle"> Remove Catalog
</div>



<div class="cp_sectionBox" style="width:340px;padding:0px;margin-top:10px;padding-bottom:10px;">
	<div style="margin:2px;">
		<h2>Subscribe to Catalog:</h2>
		<div style="font-size:12px;">
			Enter the URL address of the catalog you wish to subscribe to.
			You may use relative or full addresses for the catalog location.
		</div>
		
		<form name="frmAdd" action="##" method="post" onSubmit="return false;" style="margin:0px;padding:0px;">
			<input type="text" name="href"  value="" style="width:260px;">&nbsp;
			<input type="button" value="GO" style="width:auto;" onclick="controlPanel.addCatalog(this.form)"><br />
		</form>
	</div>
</div>

</cfoutput>
