<cfparam name="arguments.accountName" default="">
<cfparam name="arguments.refresh" default="false">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	bFeedReadOK = true;
	errMessage = "";
	execMode = this.controller.getExecMode();	

	// reader settings
	theAccount = cfg.getPageSetting("accountName");
	maxItems = cfg.getPageSetting("maxItems");
	
	// user info
	stUser = this.controller.getUserInfo();

	// this is to allow overriding of the page setting
	if(arguments.accountName neq "") theAccount = arguments.accountName;

	// get images path
	imgRoot = tmpModulePath & "/images";
	
	// check that the feed refresh argument is boolean
	if(not isBoolean(arguments.refresh)) arguments.refresh = false;

	if(theAccount neq "") {
		// read feed
		try {
			accountURL = "http://twitter.com/" & theAccount;
			xmlDoc = retrieveData(theAccount, arguments.refresh);
			bFeedReadOK = true;
			
		} catch(any e) {
			bFeedReadOK = false;
			errMessage = "<b>Error:</b> " & e.message & e.detail;
		}
	}
</cfscript>

<cfif theAccount neq "">
	<cfoutput>
		<img src="#imgRoot#/latestFromTwitter.gif">
		<cfif bFeedReadOK>
			<cfset aItems = xmlSearch(xmlDoc,"//status")>
			<cfloop from="1" to="#min(arrayLen(aItems),val(maxItems))#" index="i">
				<cfset text = aItems[i].text.xmlText>
				<cfset text = reReplace(text, "((http|ftp|https)://[A-Za-z0-9._/]+)", "<a href=""\1"" style='color:blue;'>\1</a>","ALL")>
				<div style="font-size:12px;margin-bottom:10px;padding-bottom:10px;border-bottom:1px dotted silver;">
					&raquo;	#text#<br />
				</div>
			</cfloop>
			
			<div>
				<a href="#accountURL#" style="font-weight:bold;font-size:14px;color:blue;">Follow @#theAccount#</a>
			</div>
			
			<script>
				#moduleID#.setIcon("#imgRoot#/favicon.ico");
				#moduleID#.setTitle("#jsstringformat('Latest from @#theAccount#')#");
			</script>
		<cfelse>
			<div class="rssf_body">
				<div class="rssf_item">
					#errMessage#
				</div>
			</div>
		</cfif>
		<cfif stUser.isOwner>
			<div class="SectionToolbar">
				<a href="javascript:#moduleID#.getView('config','',{useLayout:false});"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
				<a href="javascript:#moduleID#.getView('config','',{useLayout:false});">Settings</a>
			</div>
		</cfif>
	</cfoutput>
<cfelse>
	<cfoutput>
		<cfif stUser.isOwner>
			#this.controller.renderView(view = 'config', useLayout=false)#
		<cfelse>
			<em>No account name has been set.</em>
		</cfif>
	</cfoutput>
</cfif>
