<cfparam name="arguments.path" default="">

<cfset hp = variables.homePortals>
<cfset p = variables.oPage>
<cfset appRoot = hp.getConfig().getAppRoot()>
<cfset pageName = getFileFromPath(variables.pageHREF)>

<cfif arguments.path eq "">
	<cfset currentPath = getDirectoryFromPath(variables.pageHREF)>
<cfelse>
	<cfset currentPath = arguments.path>
</cfif>
<cfset currentPath = replace(currentPath,"\","/","ALL")>
<cfset currentPath = replace(currentPath, "//", "/", "ALL")> 

<cfif listlen(currentPath,"/") gt 1>
	<cfset parentPath = listDeleteAt(currentPath,listLen(currentPath,"/"),"/")>
<cfelse>
	<cfset parentPath = "/">
</cfif>



<cfset qryPages = hp.getPageProvider().listFolder(currentPath)>
<cfquery name="qryPages" dbtype="query">
	SELECT *
		FROM qryPages
		ORDER BY type,name
</cfquery>

<cfoutput>
	<div class="cms-panelTitle">
		<div style="font-size:12px;float:right;width:300px;text-align:right;">
			<b>Create Folder:</b>
			<input type="text" name="folder" value="" class="cms-formField" id="cms-folderName">
			<input type="button" name="btnGo" value="Go" onclick="cms.createFolder('#currentPath#',jQuery('##cms-folderName').attr('value'))">
		</div>
		Site Pages
		<div style="clear:both;"></div>
	</div>
	<b>Path: #currentPath#</b><br />

	<div class="cms-lightPanel">
		<cfif currentPath neq "/">
			<img src="#variables.cmsRoot#/images/folder.png" align="absmiddle">
			<a href="##" onclick="cms.getView('Sitemap',{path:'#parentPath#'});">..</a>
		</cfif>
		<cfloop query="qryPages">
			<span style="white-space:nowrap;">
				<cfif qryPages.type eq "page">
					<cfset thisPageHREF = buildLink(currentPath & "/" & qryPages.name,false)>
					<cfset thisPageHREF = replace(thisPageHREF, "//", "/", "ALL")> <!--- get rid of duplicate forward slash (will cause problems for sites at webroot)--->
					<img src="#variables.cmsRoot#/images/page.png" align="absmiddle">
					<cfif qryPages.name eq pageName>
						<strong style="font-size:12px;">#qryPages.name#</strong>
					<cfelse>
						<a href="#thisPageHREF#">#qryPages.name#</a>
					</cfif>
				<cfelse>
					<img src="#variables.cmsRoot#/images/folder.png" align="absmiddle">
					<a href="##" onclick="cms.getView('Sitemap',{path:'#currentPath#/#qryPages.name#'});">#qryPages.name#</a>
				</cfif>
			</span>
			&nbsp;&nbsp;&nbsp;
		</cfloop>
	</div>
	
	<br />
	<p>
		<input type="button" name="btnAdd" value="Add Page" onclick="navCmdAddPage('#currentPath#')">
		<input type="button" name="btnDelPage" value="Delete Page" onclick="navCmdDeletePage()">
		<input type="button" name="btnDelFolder" value="Delete Folder" onclick="cms.deleteFolder('#currentPath#')"
				<cfif currentPath eq "/">disabled="true"</cfif>>
		&nbsp;&nbsp;
		<input type="button" value="Close" onclick="cms.closePanel()">
	</p>
</cfoutput>