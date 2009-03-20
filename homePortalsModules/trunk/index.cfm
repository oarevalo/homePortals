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

<cfset application.homePortals.getConfig().setResourceLibraryPath("/homePortalsModules/resourceLibrary")>


<!------------------------------>
<!--- Assemble Page			 --->
<!------------------------------>
<cfset feed1 = {
				moduleType = "module",
				name="RSSReader/RSSReader",
				title="HomePortals News",
				rss="http://www.homeportals.net/blog/rss.cfm"
			}>

<cfset feed2 = {
				moduleType = "module",
				name="RSSReader/RSSReader",
				title="OscarArevalo.com",
				rss="http://www.oscararevalo.com/rss.cfm"
			}>

<cfset oPage = createObject("component","homePortals.components.pageBean")
				.init()
				.addStylesheet("/homePortals/resourceLibrary/Skins/silver/silver.css")
				.setTitle("HomePortals Modules Framework")
				.addLayoutRegion("col1","column")
				.addLayoutRegion("col2","column")
				.addModule("feed1","col1",feed1)
				.addModule("feed2","col2",feed2)
				>
				

<!------------------------------>
<!--- Render & Output Page	 --->
<!------------------------------>
<cfset oPageRenderer = application.homePortals.loadPageBean(oPage)>
<cfset html = oPageRenderer.renderPage()>
<cfoutput>#html#</cfoutput>
