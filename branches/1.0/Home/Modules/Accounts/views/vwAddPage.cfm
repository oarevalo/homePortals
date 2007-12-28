<!--- 
vwAddPage

Allows user to enter the name of the new page to add,
also displays the list of published pages

** This file should be included from addContent.cfc

History:
1/19/06 - oarevalo - created
---->

<cfset aCatalogs = ArrayNew(1)>

<cfset initContext()>
<cfset aCatalogs = getCatalogs()>
<cfset xmlSite = xmlParse(expandpath(this.siteURL))>
<cfset aPages = xmlSite.xmlRoot.pages.xmlChildren>


<cfoutput>
	<div class="cp_sectionTitle" style="padding:0px;width:340px;">
		<div style="margin:2px;">Add New Page</div>	
	</div>
		
	<div class="cp_sectionBox" style="margin-top:0px;height:330px;padding:0px;width:340px;">	
		<div style="margin:2px;">
			<p>
				<img src="#this.accountsRoot#/default/cp_bullet.gif" border="0" alt=">">
				<strong>Add a blank page</strong><br>
				<form name="frm1" action="##" method="post" style="margin-left:20px;">
					Name: 
					<input type="text" name="pageName" value="" style="width:150px;">
					<input type="button" value="Go" onclick="controlPanel.addPage(this.form.pageName.value)">
				</form>
			</p><br>
			<p>
				<img src="#this.accountsRoot#/default/cp_bullet.gif" border="0" alt=">">
				<strong>Copy existing page:</strong><br>
				<form name="frm2" action="##" method="post" style="margin-left:20px;">
					Select page to copy:
					<select name="pageHREF">
						<cfloop from="1" to="#arrayLen(aPages)#" index="i">
							<option value="#aPages[i].xmlAttributes.href#">#aPages[i].xmlAttributes.title#</option>
						</cfloop>
					</select>
					<input type="button" value="Go" onclick="controlPanel.addPage('',this.form.pageHREF.value)">
				</form>
			</p><br>
			<p>
				<img src="#this.accountsRoot#/default/cp_bullet.gif" border="0" alt=">">
				<strong>Add a published page:</strong><br>
				<div style="margin-top:10px;margin-left:10px;">
				<a href="javascript:controlPanel.getView('AddPublishedPages')" style="color:##ccc;font-weight:normal;">Click here to browse published pages</a>
			</p>
		</div>		
	</div>

</cfoutput>
