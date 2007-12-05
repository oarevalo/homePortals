<cfparam name="arguments.dir" default="">
<cfscript>
	// get the general settings
	cfg = this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	execMode = this.controller.getExecMode();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
	stUser = this.controller.getUserInfo();
	tmpFilter = cfg.getPageSetting("filter");
	tmpStructName = "_" & moduleID;
	bFailed = false;
	errorMessage = "";
	tmpCurrentRoot = "";


	try {
		// initialize session structure for holding temporary values
		// this is done while generating the page (or when the session expires)
		if(execMode eq 'local' or Not StructKeyExists(session,tmpStructName)) {
			tmpRootPath = cfg.getPageSetting("root");
			if(tmpRootPath eq "") tmpRootPath = "/Accounts/" & stUser.owner;
	
			session[tmpStructName] = structNew();
			session[tmpStructName].root = tmpRootPath;
			session[tmpStructName].depth = 0;
		}
	
		// process changes on the directory sent from the module client
		if(execMode eq 'remote' and arguments.dir neq "") {
			if(arguments.dir eq ".." and session[tmpStructName].depth gt 0) {
				// handle going "up" on the directory tree
				tmp = session[tmpStructName].root;
				if(listLen(tmp,"/") gt 0) tmp = listDeleteAt(tmp,listLen(tmp,"/"),"/");
				
				session[tmpStructName].depth = session[tmpStructName].depth - 1;
				session[tmpStructName].root = tmp; 
			} else {
				// handle going "down" on the directory tree
				session[tmpStructName].depth = session[tmpStructName].depth + 1;
				session[tmpStructName].root = listAppend(session[tmpStructName].root, arguments.dir, "/");
			}
		}
	
		tmpCurrentRoot = session[tmpStructName].root;
		tmpCurrentDepth = session[tmpStructName].depth;
	
		// fix path if needed
		if(left(tmpCurrentRoot,1) neq "/") tmpCurrentRoot = "/" & tmpCurrentRoot;
		tmpCurrentRoot = REReplace(tmpCurrentRoot, "[/]{2,}","/","ALL");
	
		// check that current directory exists	
		if(Not DirectoryExists(expandPath(tmpCurrentRoot))) 
			throw("The given path does not exist on this server. [#tmpCurrentRoot#]");

	} catch (any e) {
		bFailed = true;
		errorMessage = e.message;
	}
</cfscript>

<cfif not bFailed>
	<cfdirectory action="list" directory="#expandPath(tmpCurrentRoot)#" name="qryDir" filter="#tmpFilter#">
	<cfquery name="qryDir" dbtype="query">
		SELECT *
			FROM qryDir
			ORDER BY Type, Name
	</cfquery>
</cfif>


<cfoutput>
	<cfif not bFailed>
		<div style="line-height:20px;">
			<cfif tmpCurrentDepth gt 0>
				<cfset tmpHREF = "javascript:#moduleID#.getView('','',{dir:'..'});">
				<a href="#tmpHREF#"><img src="#imgRoot#/folder.png" border="0" align="absmiddle" alt="Folder"></a>
				<a href="#tmpHREF#">..</a><br>
			</cfif>
			<cfloop query="qryDir">
				<cfif qryDir.type eq "Dir">
					<cfset tmpHREF = "javascript:#moduleID#.getView('','',{dir:'#qryDir.name#'});">
					<a href="#tmpHREF#"><img src="#imgRoot#/folder.png" border="0" align="absmiddle" alt="Folder"></a>
					<a href="#tmpHREF#">#qryDir.name#</a>
				<cfelse>
					<a href="#tmpCurrentRoot#/#qryDir.name#"><img src="#imgRoot#/page_white.png" border="0" align="absmiddle" alt="File"></a>
					<a href="#tmpCurrentRoot#/#qryDir.name#">#qryDir.name#</a>
				</cfif>
				<br>
			</cfloop>
		</div>
	<cfelse>
		<b>Error:</b> #errorMessage#
	</cfif>
	<cfif stUser.isOwner>
		<div class="fileBrowserToolbar">
			<a href="javascript:#moduleID#.getView('config');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getView('config');">Change Root</a>
			&nbsp;&nbsp;
			<a href="javascript:alert('#jsstringformat(tmpCurrentRoot)#');"><img src="#imgRoot#/help.png" border="0" align="absmiddle"></a>
			<a href="javascript:alert('#jsstringformat(tmpCurrentRoot)#');">Where am I?</a>
		</div>	
	</cfif>
</cfoutput>