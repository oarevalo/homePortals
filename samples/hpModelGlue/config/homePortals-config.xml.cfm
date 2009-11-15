<?xml version="1.0" encoding="UTF-8"?>
<homePortals>
	<contentRoot>/hpModelGlue/pages/</contentRoot>
	<defaultPage>index</defaultPage>

	<baseResources>
		<resource href="/hpModelGlue/style.css" type="style"/>
	</baseResources>
	
	<renderTemplates>
		<renderTemplate name="page" type="page" href="/hpModelGlue/layouts/Layout.Page.htm" default="true" />
	</renderTemplates>
	
	<contentRenderers>
		<contentRenderer moduleType="widget" path="hpModelGlue.widgetEventHandler" />
	</contentRenderers>

	<resourceLibraryPaths>
		<resourceLibraryPath>/hpModelGlue/resourceLibrary/</resourceLibraryPath>
	</resourceLibraryPaths>

</homePortals>
