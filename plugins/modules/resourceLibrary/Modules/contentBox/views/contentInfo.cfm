<cfprocessingdirective pageencoding="utf-8">
<cfparam name="resourceID" default="">

<cfscript>
	// get module path
	oHP = this.controller.getHomePortals();
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/Images";
	
	stUser = this.controller.getUserInfo();
	siteOwner = stUser.username;
	
	// get the moduleID
	moduleID = this.controller.getModuleID();	
</cfscript>

<cfif resourceID neq "">

	<cfset oResourceBean = oHP.getCatalog().getResource("content", resourceID)>
	<cfset resHREF = oResourceBean.getHREF()>
						
	<cfoutput>
		<div style="font-size:16px;font-weight:bold;margin-bottom:6px;">
			#oResourceBean.getID()#
		</div>
		
		<div style="font-size:10px;">
			Package: #oResourceBean.getPackage()#<br>
		</div>
		<br>
		<hr>
		<b>Description:</b><br>
		<div style="width:280px;border:1px solid ##ebebeb;height:220px;overflow:auto;padding:2px;">
			<cfif oResourceBean.getDescription() eq "">
				<em style="font-size:10px;">No description available.</em>
			<cfelse>
				#oResourceBean.getDescription()#
			</cfif>
		</div>
		<br>
		<input type="button" name="btnAdd" value="Select This" onclick="#moduleID#.doAction('setResourceID',{resourceID:'#resourceID#'})">
	</cfoutput>
</cfif>
