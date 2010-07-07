<?xml version="1.0" encoding="UTF-8"?>
<homePortals>

	<!-- The following resources are included in every page rendered. -->
	<baseResources>
		<resource href="/homePortals/plugins/skins/resourceLibrary/Skins/basic/basic.css" type="style"/>	
		<resource href="/homePortals/plugins/modules/common/CSS/modules.css" type="style"/>	
		<resource href="/homePortals/plugins/modules/common/JavaScript/prototype-1.4.0.js" type="script"/>	
		<resource href="/homePortals/plugins/modules/common/JavaScript/Main.js" type="script"/>	
		<resource href="/homePortals/plugins/modules/common/JavaScript/moduleClient.js" type="script"/>	
	</baseResources>

	<!-- The following are the different types of modules or content renderers that will be supported on a page -->
	<contentRenderers>
		<contentRenderer moduleType="module" path="homePortals.plugins.modules.components.contentTagRenderers.module" />
	</contentRenderers>
	
	<!-- This section declares the available resource types -->
	<resourceTypes>
		<resourceType name="module">
			<folderName>Modules</folderName>
			<description>Modules are reusable components that allow you page to perform particular tasks. Modules act as mini applications that can do things like displaying calendars, blogs, rss feed contents, etc.</description>
			<resBeanPath>homePortals.plugins.modules.components.moduleResourceBean</resBeanPath>
		</resourceType>
	</resourceTypes>
	
	<pageProperties>
		<property name="plugins.modules.defaults.bundledReosurceLibraryPath" value="/homePortals/plugins/modules/resourceLibrary/" />
		<property name="plugins.modules.defaults.loadBundledResourceLibrary" value="true" />
		<property name="plugins.modules.defaults.accountsDataPath" value="{appRoot}/accountsData" />
	</pageProperties>
	
</homePortals>
