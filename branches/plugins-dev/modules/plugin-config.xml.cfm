<?xml version="1.0" encoding="UTF-8"?>
<homePortals>

	<!-- The following resources are included in every page rendered. -->
	<baseResources>
		<resource href="{pluginPath}/common/CSS/modules.css" type="style"/>	
		<resource href="{pluginPath}/common/JavaScript/Main.js" type="script"/>	
		<resource href="{pluginPath}/common/JavaScript/moduleClient.js" type="script"/>	
		<resource href="{pluginPath}/common/htmlhead.cfm" type="HTMLHEAD"/>
	</baseResources>

	<!-- The following are the different types of modules or content renderers that will be supported on a page -->
	<contentRenderers>
		<contentRenderer moduleType="module" path="homePortals.plugins.modules.components.contentTagRenderers.module" />
	</contentRenderers>
	
	<!-- This section declares the available resource types -->
	<resourceTypes>
		<resourceType name="module">
			<description>Modules are reusable components that allow you page to perform particular tasks. Modules act as mini applications that can do things like displaying calendars, blogs, rss feed contents, etc.</description>
			<resBeanPath>homePortals.plugins.modules.components.moduleResourceBean</resBeanPath>
		</resourceType>
	</resourceTypes>
	
	<pageProperties>
		<property name="plugins.modules.defaults.modulesGateway" value="gateway.cfm"/>
		<property name="plugins.modules.defaults.bundledReosurceLibraryPath" value="{pluginPath}/resourceLibrary/" />
		<property name="plugins.modules.defaults.loadBundledResourceLibrary" value="true" />
		<property name="plugins.modules.defaults.accountsDataPath" value="{appRoot}/accountsData" />
		<property name="plugins.modules.initialEvent" value="Framework.onPageLoaded" />
	</pageProperties>
	
</homePortals>
