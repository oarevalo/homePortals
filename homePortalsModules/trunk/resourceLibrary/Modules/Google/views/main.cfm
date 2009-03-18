<cfscript>
	cfg = this.controller.getModuleConfigBean();
	searchers = cfg.getPageSetting("searchers","Web");
	localSearchCenterPoint = cfg.getPageSetting("localSearchCenterPoint","");
	
	// get the moduleID
	moduleID = this.controller.getModuleID();

	// get user info
	stUser = this.controller.getUserInfo();	

	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
</cfscript>


<cfoutput>
	<div id="#moduleID#_searchcontrol">Loading...</div>
	<cfif stUser.isOwner>
		<div class="SectionToolbar">
			<a href="javascript:#moduleID#.getView('config','#moduleID#');"><img src="#imgRoot#/edit-page-yellow.gif" border="0" align="absmiddle"></a>
			<a href="javascript:#moduleID#.getView('config','#moduleID#');">Settings</a>
		</div>
	</cfif>

	<script type="text/javascript">
		#moduleID#.setTitle("Google Search");
		#moduleID#.setIcon("http://www.google.com/favicon.ico");
	</script>

	<cfif this.controller.getExecMode() eq "remote">
		<script>
			// Create a search control
			var searchControl = new google.search.SearchControl();
			
			// Add searchers
			<cfloop list="#searchers#" index="item">
				<cfif item eq "local">
				  	var localSearch = new google.search.LocalSearch();
				  	searchControl.addSearcher(localSearch);
					localSearch.setCenterPoint("#jsstringFormat(localSearchCenterPoint)#");
			   	<cfelse>
					searchControl.addSearcher(new google.search.#item#Search());
			   	</cfif>
			</cfloop>
			
			// Tell the searcher to draw itself and tell it where to attach
			searchControl.draw(document.getElementById("#moduleID#_searchcontrol"));
		</script>
	</cfif>
</cfoutput>