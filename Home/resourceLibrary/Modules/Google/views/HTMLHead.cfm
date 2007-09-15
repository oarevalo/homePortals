
<cfscript>
	moduleID = this.controller.getModuleID();
	cfg = this.controller.getModuleConfigBean();
	apiKey = "ABQIAAAApTjBmvL3t1VBf5hErPyVOBTsDXqvWLao-xzK903YvE-VUVmXqxTVQtd7DTjNRQ4_3Z9AOHqhBMf5PA";

	searchers = cfg.getPageSetting("searchers","Web");
	localSearchCenterPoint = cfg.getPageSetting("localSearchCenterPoint","");
</cfscript>	
	
<cfoutput>
	<cfif this.controller.isFirstInClass()>
	    <script src="http://www.google.com/jsapi?key=#apiKey#" type="text/javascript"></script>
	    <script language="Javascript" type="text/javascript">
		    google.load("search", "1");
	    </script>
	</cfif>

    <script language="Javascript" type="text/javascript">

		// create function for setup google search widget	
		#moduleID#.setupGoogleSearch = function() {

	      // Create a search control
	      var searchControl = new google.search.SearchControl();
	
	      // Add searchers
	      <cfloop list="#searchers#" index="item">
	      	<cfif item eq "local">
		    	var localSearch = new google.search.LocalSearch();
		    	searchControl.addSearcher(localSearch);

				// Set the Local Search center point
				localSearch.setCenterPoint("#jsstringFormat(localSearchCenterPoint)#");
	      	<cfelse>
				searchControl.addSearcher(new google.search.#item#Search());
	      	</cfif>
	      </cfloop>
	
	      // Tell the searcher to draw itself and tell it where to attach
	      searchControl.draw(document.getElementById("#moduleID#_searchcontrol"));
	    }
	    google.setOnLoadCallback(#moduleID#.setupGoogleSearch);


		#moduleID#.submitSettingsForm = function(frm) {
		
			var aElm = document.getElementsByName("cb_searchers");
			var searchers = "";
			
			for(i=0;i<aElm.length;i++) {
				if(aElm[i].checked) searchers = searchers + aElm[i].value + ",";	
			}
			if(searchers=="") {
				alert("Please select at least one search service");
				return;
			}
		
			frm.searchers.value = searchers;
			
			#moduleID#.doFormAction('saveSettings',frm)
		}
    </script>

</cfoutput>
