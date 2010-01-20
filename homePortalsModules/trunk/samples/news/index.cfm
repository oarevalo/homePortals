<cfsetting enablecfoutputonly="true">

<!------------------------------>
<!--- Initialize Environment --->
<!------------------------------>
<cfset application.homePortals = createObject("component","homePortals.components.homePortals").init( getDirectoryFromPath(cgi.script_name) )>


<!------------------------------>
<!--- Register Plugin		 --->
<!------------------------------>
<cfset conf = application.homePortals.getConfig()>
<cfset conf.setPlugin("modules","homePortals.plugins.modules.plugin")>
<cfset application.homePortals.initEnv()>


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

<cfset feed2 = createObject("component","homePortals.components.moduleBean")
				.init()
				.setID("feed2")
				.setModuleType("module")
				.setTitle("OscarArevalo.com")
				.setProperty("name","RSSReader/rssReader")
				.setProperty("rss","http://www.oscararevalo.com/rss.cfm")>

<cfset oPage = createObject("component","homePortals.components.pageBean")
				.init()
				.setSkinID("rounded")
				.setTitle("HomePortals Modules Framework")
				.addLayoutRegion("col1","column")
				.addLayoutRegion("col2","column")
				.addModule(feed1,"col1")
				.addModule(feed2,"col2")>
				

<!------------------------------>
<!--- Render & Output Page	 --->
<!------------------------------>
<cfset oPageRenderer = application.homePortals.loadPageBean(oPage)>
<cfset html = oPageRenderer.renderPage()>
<cfoutput>#html#</cfoutput>
