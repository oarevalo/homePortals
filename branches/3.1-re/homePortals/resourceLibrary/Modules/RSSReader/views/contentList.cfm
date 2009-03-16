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
					OR upper(name) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%#ucase(searchTerm)#%">  
		</cfif>
		ORDER BY package, name
</cfquery>

<!--- get owner's resources--->
<cfquery name="qryMyResources" dbtype="query">
	SELECT *
		FROM qryResources
		WHERE owner = <cfqueryparam cfsqltype="cf_sql_varchar" value="#siteOwner#">
</cfquery> 

<cfif qryMyResources.recordCount gt 0>
	<div class="rd_packageTitle" style="color:#990000;">
		<cfoutput><a href="##" onclick="Element.toggle('cp_feedGroup0');return false;" style="color:##990000;font-weight:bold;">&raquo; My Feeds (#qryMyResources.recordCount#)</a></cfoutput>
	</div>
	<div id="cp_feedGroup0" style="display:none;margin-left:10px;margin-bottom:8px;">
		<cfoutput query="qryMyResources">
			<cfif qryMyresources.name eq "">
				<cfset tmpName = qryMyResources.id>
			<cfelse>
				<cfset tmpName = qryMyResources.name>
			</cfif>
			<a href="##" 
				onclick="#moduleID#.getView('contentInfo','cb_resourceInfo',{resourceID:'#jsstringFormat(qryMyResources.id)#'})" 
				style="color:##333;white-space:nowrap;">#tmpName#</a><br>
		</cfoutput>
	</div>
</cfif>

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
			<cfif qryResources.name eq "">
				<cfset tmpName = qryResources.id>
			<cfelse>
				<cfset tmpName = qryResources.name>
			</cfif>
			<a href="##" 
				onclick="#moduleID#.getView('contentInfo','cb_resourceInfo',{resourceID:'#jsstringFormat(qryResources.id)#'})" 
				style="color:##333;white-space:nowrap;">#tmpName#</a><br>
		</cfoutput>
	</div>
</cfoutput>
