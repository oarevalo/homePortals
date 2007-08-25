<cfprocessingdirective pageencoding="utf-8">
<cfparam name="resourceID" default="">

<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
	
	stUser = this.controller.getUserInfo();
	siteOwner = stUser.username;
	qryResources = getResourcesForAccount(siteOwner,"content");
	
	// get the moduleID
	moduleID = this.controller.getModuleID();	
</cfscript>

<cfif resourceID neq "">

	<cfquery name="qryThisResource" dbtype="query">
		SELECT *
			FROM qryResources
			WHERE UPPER(id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(resourceID)#">
	</cfquery>

	<cfoutput>
		<div style="font-size:16px;font-weight:bold;margin-bottom:6px;">
			#qryThisResource.id#
		</div>
		
		<div style="font-size:10px;">
			Package: #qryThisResource.package#<br>
			Created By: #qryThisResource.owner#
		</div>
		<br>
		<hr>
		<b>Description:</b><br>
		<div style="width:280px;border:1px solid ##ebebeb;height:220px;overflow:auto;padding:2px;">
			<cfif qryThisResource.description eq "">
				<em style="font-size:10px;">No description available.</em>
			<cfelse>
				#qryThisResource.description#
			</cfif>
		</div>
		<br>
		<input type="button" name="btnAdd" value="Select This" onclick="#moduleID#.doAction('setContentID',{contentID:'#resourceID#'})">
	</cfoutput>
</cfif>
