<cfsetting enablecfoutputonly="true">

<!------------------------------>
<!--- Initialize Environment --->
<!------------------------------>
<cfset application.homePortals = createObject("component","homePortals.components.homePortals").init("/homePortalsModules")>

<cfset pm = application.homePortals.getPluginManager()>
<cfset pm.registerPlugin("modules","homePortalsModules.components.modulesPlugin")>
<cfset pm.registerPlugin("accounts","homePortalsAccounts.components.accountsPlugin")>
<cfset pm.notifyPlugin("accounts","appInit")>
<cfset pm.notifyPlugin("modules","appInit")>


<!------------------------------>
<!--- Assemble Page			 --->
<!------------------------------>
<cfset feed1 = createObject("component","homePortals.components.moduleBean")
				.init()
				.setID("feed1")
				.setModuleType("module")
				.setTitle("HomePortals News")
				.setProperty("name","RSSReader/rssReader")
				.setProperty("rss","http://www.homeportals.net/blog/rss.cfm")>

<cfset st = {
				id = "feed2",
				moduleType = "module",
				name="RSSReader/rssReader",
				title="OscarArevalo.com",
				rss="http://www.oscararevalo.com/rss.cfm"
			}>
<cfset feed2 = createObject("component","homePortals.components.moduleBean").init(st)>

<cfset oPage = createObject("component","homePortals.components.pageBean")
				.init()
				.setSkinID("rounded")
				.setTitle("HomePortals Modules Framework")
				.addLayoutRegion("col1","column")
				.addLayoutRegion("col2","column")
				.addModule(feed1,"col1")
				.addModule(feed2,"col2")
				>
				

<!------------------------------>
<!--- Render & Output Page	 --->
<!------------------------------>
<cfset oPageRenderer = application.homePortals.loadPageBean(oPage)>
<cfset html = oPageRenderer.renderPage()>
<cfoutput>#html#</cfoutput>
