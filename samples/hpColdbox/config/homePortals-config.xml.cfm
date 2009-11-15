<?xml version="1.0" encoding="UTF-8"?>
<homePortals>
	<contentRoot>/hpColdbox/pages/</contentRoot>
	<defaultPage>index</defaultPage>

	<baseResources>
		<resource href="/hpColdbox/style.css" type="style"/>
	</baseResources>
	
	<renderTemplates>
		<renderTemplate name="page" type="page" href="/hpColdbox/layouts/Layout.Page.htm" default="true" />
	</renderTemplates>
	
	<contentRenderers>
		<contentRenderer moduleType="widget" path="hpColdbox.widgetEventHandler" />
	</contentRenderers>

	<resourceLibraryPaths>
		<resourceLibraryPath>/hpColdbox/resourceLibrary/</resourceLibraryPath>
	</resourceLibraryPaths>

</homePortals>
