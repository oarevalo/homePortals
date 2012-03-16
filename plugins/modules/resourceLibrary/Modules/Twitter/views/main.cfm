<cfparam name="arguments.accountName" default="">
<cfparam name="arguments.refresh" default="false">

<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	execMode = this.controller.getExecMode();	
	
	// get default values
	theAccount = cfg.getPageSetting("accountName");
	maxItems = cfg.getPageSetting("maxItems");

	// get current user info
	stUser = this.controller.getUserInfo();

 	// make sure only owner can make changes 
	if(Not stUser.isOwner)
		tmpDisabled = "disabled";
	else
		tmpDisabled = "";

	// this is to allow overriding of the page setting
	if(arguments.accountName neq "") theAccount = arguments.accountName;

	// get images path
	imgRoot = tmpModulePath & "/images";

	accountURL = "http://twitter.com/" & theAccount;
</cfscript>

<cfoutput>
	<cfif theAccount neq "">
		<cfif execMode neq "local">
			#this.controller.renderView(view = 'feed', useLayout=false)#
		<cfelse>
			<img src="#imgRoot#/latestFromTwitter.gif">

			<p style="font-size:10px;">Loading tweets. Please wait...</p>
			
			<script>
				#moduleID#.setTitle("#jsstringformat('Latest from @#theAccount#')#");
				#moduleID#.getView("feed");
				#moduleID#.attachIcon("#imgRoot#/refresh.gif","#moduleID#.getView('feed','',{refresh:true})","Refresh content");
			</script>
	
			<cfif stUser.isOwner>
				<div class="SectionToolbar">
					<a href="javascript:#moduleID#.getView('config');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
					<a href="javascript:#moduleID#.getView('config');">Settings</a>
				</div>
			</cfif>
		</cfif>
	<cfelse>
		<cfif stUser.isOwner>
			#this.controller.renderView(view = 'config', useLayout=false)#
		<cfelse>
			<em>No account name has been set.</em>
		</cfif>
	</cfif>
</cfoutput>


