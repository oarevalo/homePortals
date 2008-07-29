<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();

	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();
		
	// url to rss feed
	rssURL = "http://" & cgi.SERVER_NAME & getDirectoryFromPath(tmpModulePath) & "rss?blog=" & myContentStore.getURL();

	// get blog title
	if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "title"))
		blogTitle = xmlDoc.xmlRoot.xmlAttributes.title;
	else
		blogTitle = rssURL; 
</cfscript>

<cfif this.controller.isFirstInClass()>
<style type="text/css">
	.BlogPostBar {
		font-size:11px;
		font-weight:bold;
		border:1px solid silver;
		background-color:#fefcd8;
	}	
	.BlogPostContent {
		border:0px;
		border-left:1px solid silver;
		border-right:1px solid silver;
		padding:2px;
		height:390px;
		width:100%;
		background-color:#fff;
	}	
</style>
</cfif>

<cfoutput>
<link rel="alternate" type="application/rss+xml" title="#blogTitle#" href="#rssURL#" />
</cfoutput>
