<?xml version="1.0" encoding="UTF-8"?>
<homePortals>

	<baseResources>
		<resource href="{pluginPath}/lib/jHtmlArea/jHtmlArea-0.7.0.min.js" type="script"/>
		<resource href="{pluginPath}/lib/jHtmlArea/jHtmlArea.ColorPickerMenu-0.7.0.min.js" type="script"/>
		<resource href="{pluginPath}/lib/jHtmlArea/jHtmlArea.css" type="style"/>
		<resource href="{pluginPath}/lib/jHtmlArea/jHtmlArea.ColorPickerMenu.css" type="style"/>
		<resource href="{pluginPath}/main.js" type="script"/>
		<resource href="{pluginPath}/style.css" type="style"/>
		<resource href="{pluginPath}/adminBar.cfm" type="HTMLHEAD"/>
	</baseResources>

	<resourceTypes>
		<resourceType name="cmsUser">
			<description>This resource is used to store all users allowed to use the CMS functionality</description>
			<property name="password" type="string" label="Password" />
		</resourceType>
	</resourceTypes>
		
	<pageProperties>
		<property name="plugins.cms.cmsRoot" value="{pluginPath}"/>
		<property name="plugins.cms.defaults.cmsGateway" value="cms-gateway.cfm"/>
		<property name="plugins.cms.defaults.cmsLinkFormat" value="{appRoot}/index.cfm?page={page}"/>
	</pageProperties>
		
</homePortals>
