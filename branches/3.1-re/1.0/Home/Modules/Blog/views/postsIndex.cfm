<cfscript>
	// get the moduleID
	moduleID = this.controller.getModuleID();	
	
	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();
	
	// get posts
	aEntries = xmlSearch(xmlDoc, "//entry");

</cfscript>

<cfloop from="#ArrayLen(aEntries)#" to="1" index="i" step="-1">
	<cfset timestamp = trim(aEntries[i].created.xmlText)>
	<li><a href="javascript:#moduleID#.getView('post','',{timestamp:#timestamp#'})">#aEntries[i].title.xmlText#</a></li>
</cfloop>
<cfif ArrayLen(aEntries) eq 0>
	<em>There are no entries in this blog.</em>
</cfif>