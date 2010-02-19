<cfset hp = variables.homePortals>
<cfset p = variables.oPage>
<cfset stTemplates = hp.getTemplateManager().getTemplates("page")>
<cfset mt = p.getMetaTags()>
<cfset pageName = getFileFromPath(variables.pageHREF)>

<cfset metadescription = "">
<cfset metakeywords = "">
<cfloop from="1" to="#arrayLen(mt)#" index="i">
	<cfif mt[i].name eq "description">
		<cfset metadescription = mt[i].content>
	</cfif>
	<cfif mt[i].name eq "keywords">
		<cfset metakeywords = mt[i].content>
	</cfif>
</cfloop>

<cfoutput>
	<form name="frm" method="post" action="##">
		<div class="cms-panelTitle">
			<div style="float:right;">
				<a href='##' onclick='navCmdDeletePage()'><img 
					src='#variables.cmsRoot#/images/omit-page-orange.gif' 
					border='0' align='absmiddle' alt='Click to delete page' 
					title='click to delete page'> <span style="color:red;">Delete Page</span></a>
			</div>
			Page Settings
		</div>
		<table>
			<tr valign="top">
				<td><strong>Name:</strong></td>
				<td><input type="text" name="name" value="#pageName#" class="cms-formField"></td>
				<td style="width:20px;" rowspan="3">&nbsp;</td>
				<td rowspan="3">
					<strong>Description:</strong><br />
					<textarea name="description" rows="2" class="cms-formField" style="width:180px;">#trim(metadescription)#</textarea>
				</td>
				<td style="width:20px;" rowspan="3">&nbsp;</td>
				<td rowspan="3">
					<strong>Keywords:</strong><br />
					<textarea name="keywords" rows="2" class="cms-formField" style="width:180px;">#trim(metakeywords)#</textarea>
				</td>
			</tr>
			<tr>
				<td><strong>Title:</strong></td>
				<td><input type="text" name="title" value="#p.getTitle()#" class="cms-formField"></td>
			</tr>
			<tr>
				<td><b>Template:</b></td>
				<td>
					<select name="template" class="cms-formField">
						<option value="">(Default)</option>
						<cfloop collection="#stTemplates#" item="key">
							<option value="#stTemplates[key].name#" 
									<cfif stTemplates[key].name eq p.getPageTemplate()>selected</cfif>>#stTemplates[key].name# <cfif stTemplates[key].isdefault eq true>*</cfif></option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		<br />
		<input type="button" value="Apply Changes" onclick="controlPanel.updatePage(this.form)">
		&nbsp;
		<a href="##" onclick="controlPanel.closePanel();">Close</a>
	</form>
</cfoutput>