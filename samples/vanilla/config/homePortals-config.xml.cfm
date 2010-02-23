<?xml version="1.0" encoding="UTF-8"?>
<homePortals>
	<contentRoot>
		/vanilla/content/pages/
	</contentRoot>
	<defaultPage>
		index
	</defaultPage>
	<plugins>
		<plugin name="cms" path="homePortals.plugins.cms.plugin"/>
		<plugin name="theme" path="vanilla.theme.plugin"/>
	</plugins>
	<resourceLibraryPaths>
		<resourceLibraryPath>
			/vanilla/content/resources/
		</resourceLibraryPath>
	</resourceLibraryPaths>
	<pageProperties>
		<property name="siteTagline" value="Amazing Stuff Everyday"/>
		<property name="siteCopyright" value="&amp;copy; Copyright 2010 Goes Here"/>
		<property name="siteTitle" value="Your Site"/>
		<property name="plugins.cms.cmsLinkFormat" value="{appRoot}{page}.cfm"/>
	</pageProperties>
</homePortals>
