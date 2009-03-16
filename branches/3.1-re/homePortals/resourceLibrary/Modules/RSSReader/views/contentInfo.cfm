<cfprocessingdirective pageencoding="utf-8">
<cfparam name="resourceID" default="">

<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
	
	stUser = this.controller.getUserInfo();
	siteOwner = stUser.username;
	qryResources = getResourcesForAccount(siteOwner,"feed");
	
	// get the moduleID
	moduleID = this.controller.getModuleID();	
</cfscript>

<cfif resourceID neq "">

	<cfquery name="qryThisResource" dbtype="query">
		SELECT *
			FROM qryResources
			WHERE UPPER(id) LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#ucase(resourceID)#">
	</cfquery>

	<cfif qryThisResource.name eq "">
		<cfset tmpName = qryThisResource.id>
	<cfelse>
		<cfset tmpName = qryThisResource.name>
	</cfif>
						
	<cfoutput>
		<div style="font-size:16px;font-weight:bold;margin-bottom:6px;">
			#tmpName#
		</div>
		
		<div style="font-size:10px;">
			Package: #qryThisResource.package#<br>
			Added By: #qryThisResource.owner#
		</div>
		<div style="margin-top:15px;margin-bottom:15px;">
			<input type="button" name="btnAdd" value="Add To My Page" onclick="#moduleID#.doAction('setRSS',{rssURL:'#jsstringformat(qryThisResource.href)#'})">
		</div>
		<div style="width:280px;border-top:1px solid ##ebebeb;padding:2px;font-size:10px;">
			<cfif qryThisResource.description eq "">
				<em style="font-size:10px;">No description available.</em>
			<cfelse>
				#qryThisResource.description#
			</cfif>
		</div>
	</cfoutput>
</cfif>
