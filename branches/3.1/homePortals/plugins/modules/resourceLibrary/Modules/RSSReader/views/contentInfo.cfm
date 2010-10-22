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

	<cfset oResourceBean = oHP.getCatalog().getResourceNode("feed", resourceID)>
	<cfset resHREF = oResourceBean.getHREF()>
						
	<cfoutput>
		<div style="font-size:16px;font-weight:bold;margin-bottom:6px;">
			#oResourceBean.getID()#
		</div>
		
		<div style="font-size:10px;">
			Package: #oResourceBean.getPackage()#<br>
		</div>
		<div style="margin-top:15px;margin-bottom:15px;">
			<input type="button" name="btnAdd" value="Add To My Page" onclick="#moduleID#.doAction('setRSS',{rssURL:'#jsstringformat(resHREF)#'})">
		</div>
		<div style="width:280px;border-top:1px solid ##ebebeb;padding:2px;font-size:10px;">
			<cfif oResourceBean.getDescription() eq "">
				<em style="font-size:10px;">No description available.</em>
			<cfelse>
				#oResourceBean.getDescription()#
			</cfif>
		</div>
	</cfoutput>
</cfif>
