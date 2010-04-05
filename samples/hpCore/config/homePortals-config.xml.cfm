<?xml version="1.0" encoding="UTF-8"?>
<homePortals>
	<contentRoot>pages/</contentRoot>
	<defaultPage>index</defaultPage>

	<baseResources>
		<resource href="style.css" type="style"/>
	</baseResources>
	
	<renderTemplates>
		<renderTemplate name="page" type="page" href="layouts/Layout.Page.htm" default="true" />
	</renderTemplates>
	
	<contentRenderers>
		<contentRenderer moduleType="widget" path=".widgetEventHandler" />
	</contentRenderers>

	<resourceLibraryPaths>
		<resourceLibraryPath>resourceLibrary/</resourceLibraryPath>
	</resourceLibraryPaths>

</homePortals>
