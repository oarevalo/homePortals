<?xml version="1.0" encoding="UTF-8"?>
<homePortals>

	<baseResources>
		<resource href="/homePortals/plugins/cms/lib/jHtmlArea/jHtmlArea-0.7.0.min.js" type="script"/>
		<resource href="/homePortals/plugins/cms/lib/jHtmlArea/jHtmlArea.ColorPickerMenu-0.7.0.min.js" type="script"/>
		<resource href="/homePortals/plugins/cms/lib/jHtmlArea/jHtmlArea.css" type="style"/>
		<resource href="/homePortals/plugins/cms/lib/jHtmlArea/jHtmlArea.ColorPickerMenu.css" type="style"/>
		<resource href="/homePortals/plugins/cms/main.js" type="script"/>
		<resource href="/homePortals/plugins/cms/style.css" type="style"/>
		<resource href="/homePortals/plugins/cms/adminBar.cfm" type="HTMLHEAD"/>
	</baseResources>

	<resourceTypes>
		<resourceType name="cmsUser">
			<description>This resource is used to store all users allowed to use the CMS functionality</description>
			<property name="password" type="string" label="Password" />
		</resourceType>
	</resourceTypes>
		
	<pageProperties>
		<property name="plugins.cms.cmsRoot" value="/homePortals/plugins/cms"/>
		<property name="plugins.cms.defaults.cmsGateway" value="cms-gateway.cfm"/>
		<property name="plugins.cms.defaults.cmsLinkFormat" value="{appRoot}/index.cfm?page={page}"/>
	</pageProperties>
		
</homePortals>
