<!--- 
vwPublishPage

Publish page to catalog

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
---->

<cfset aCatalogs = variables.oSite.getCatalogs()>

<cfoutput>
	<div class="cp_sectionTitle" style="width:340px;padding:0px;"><div style="margin:2px;">Publish Page</div></div>

	
	<div class="cp_sectionBox" style="margin-top:0px;padding:0px;width:340px;">
		<form name="frm" action="##" method="post" style="margin:10px;padding:0px;">
			<p>Publishing pages allows you to share your pages with other users. 
			Other users will be able to make a copy of the published page and add it
			to their sites.</p>
			
			<p><b>Page:</b> #ReplaceNoCase(arguments.pageHREF,".xml","")#</p>
			
			<cfif arrayLen(aCatalogs) gt 1>
				<p><strong>Select the catalog where to publish this page:</strong><br />
				<select name="catalog" style="width:300px;">
					<cfloop from="1" to="#arrayLen(aCatalogs)#" index="i">
						<option value="#aCatalogs[i].getHREF()#">#aCatalogs[i].getName()#</option>
					</cfloop>
				</select></p>
			<cfelse>
				<input type="hidden" name="catalog" value="#aCatalogs[1].getHREF()#" />
			</cfif>
			
			<p><strong>Enter a description for this page:</strong><br />
			<textarea name="description" rows="5" style="width:300px;"></textarea></p>
			
			<p align="center">
				<input type="button" value="Publish Page" onclick="controlPanel.publishPage(this.form)">
				<input type="button" value="Return" onclick="controlPanel.getView('Site')">
			
			</p>
			
			<input type="hidden" name="pageHREF" value="#arguments.pageHREF#">
		</form>
	</div>
</cfoutput>
