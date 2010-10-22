<cfprocessingdirective pageencoding="utf-8">
<cfparam name="searchTerm" default="">

<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	
	stUser = this.controller.getUserInfo();
	siteOwner = stUser.username;
	qryResources = getResourcesForAccount(siteOwner,"feed");
	
	// get the moduleID
	moduleID = this.controller.getModuleID();	
</cfscript>

<!--- order resources --->
<cfquery name="qryResources" dbtype="query">
	SELECT *
		FROM qryResources
		<cfif searchTerm neq "">
			WHERE  upper(id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">
					OR upper(package) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">  
		</cfif>
		ORDER BY package, id
</cfquery>

<cfoutput query="qryResources" group="package">
	<cfquery name="qryResCount" dbtype="query">
		SELECT *
			FROM qryResources
			WHERE package = <cfqueryparam cfsqltype="cf_sql_varchar" value="#qryResources.package#">
	</cfquery> 

	<div class="rd_packageTitle">
		<a href="##" onclick="Element.toggle('cp_feedGroup#qryResources.currentRow#');return false;" style="color:##333;font-weight:bold;">&raquo; #qryResources.package# (#qryResCount.recordCount#)</a>
	</div>
	<div style="display:none;margin-left:10px;margin-bottom:8px;" id="cp_feedGroup#qryResources.currentRow#"> 
		<cfoutput>
			<cfset tmpName = qryResources.id>
			<a href="##" 
				onclick="#moduleID#.getView('contentInfo','cb_resourceInfo',{resourceID:'#jsstringFormat(qryResources.id)#'})" 
				style="color:##333;white-space:nowrap;">#tmpName#</a><br>
		</cfoutput>
	</div>
</cfoutput>
