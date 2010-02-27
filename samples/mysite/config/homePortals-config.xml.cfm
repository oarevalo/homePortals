<?xml version="1.0" encoding="UTF-8"?>
<homePortals>
	<defaultPage>index</defaultPage>
	<contentRoot>/mysite/content/pages/</contentRoot>
	<resourceLibraryPath>/mysite/content/resources/</resourceLibraryPath>
	
	<renderTemplates>
		<renderTemplate name="page" type="page" href="/mysite/content/templates/page.htm" default="true" />
	</renderTemplates>

	<plugins>
		<plugin name="cms" path="homePortals.plugins.cms.plugin" />
	</plugins>
</homePortals>
