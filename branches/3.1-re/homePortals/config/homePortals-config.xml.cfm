<?xml version="1.0" encoding="UTF-8"?>
<homePortals version="3.1.475">

	<!-- base path for the HomePortals installation -->
	<homePortalsPath>/homePortals/</homePortalsPath>

	<!-- base path for the current application -->
	<appRoot>/homePortals/</appRoot>

	<!-- Directory where content pages will be stored -->
	<contentRoot>/homePortals/contentRoot/</contentRoot>

	<!-- HomePortals page to load when no page has been provided -->
	<defaultPage>default</defaultPage>

	<!-- Event raised when a HomePortals page finishes loading -->
	<initialEvent>Framework.onPageLoaded</initialEvent>

	<!-- The maximum number of homeportals pages to cache at any given time -->
	<pageCacheSize>50</pageCacheSize>

	<!-- The maximum amount in minutes before an unchanged page is expelled from the cache. -->
	<pageCacheTTL>60</pageCacheTTL>

	<!-- The maximum number of items to hold in the catalog cache -->
	<catalogCacheSize>50</catalogCacheSize>

	<!-- Default TTL in minutes for content items on the catalog cache. -->
	<catalogCacheTTL>60</catalogCacheTTL>

	<!-- Path in dot notation for the class responsible for storing/retrieving HomePortals pages -->
	<pageProviderClass>homePortals.components.defaultPageProvider</pageProviderClass>

	<!-- List with allowed types of base resources -->
	<baseResourceTypes>script,style,header,footer</baseResourceTypes>
	
	<!-- The following resources are included in every page rendered. -->
	<baseResources>
		<!-- <resource href="/path/to/resource/file.xxx" type="style"/> -->	
	</baseResources>

	<!-- The following templates determine how homeportals will render the html content -->
	<renderTemplates>
		<renderTemplate name="module" type="module" default="true" href="/homePortals/templates/module.htm" />
		<renderTemplate name="moduleNoContainer" type="module" href="/homePortals/templates/moduleNoContainer.htm" />
		<renderTemplate name="page" type="page" default="true" href="/homePortals/templates/page.htm" />
	</renderTemplates>
	
	<!-- The following are the different types of modules or content renderers that will be supported on a page -->
	<contentRenderers>
		<contentRenderer moduleType="content" path="homePortals.components.contentTagRenderers.content" />
		<contentRenderer moduleType="view" path="homePortals.components.contentTagRenderers.view" />
		<contentRenderer moduleType="image" path="homePortals.components.contentTagRenderers.image" />
		<contentRenderer moduleType="navMenu" path="homePortals.components.contentTagRenderers.navMenu" />
		<contentRenderer moduleType="rss" path="homePortals.components.contentTagRenderers.rss" />
	</contentRenderers>
	
	<!-- The following section is used to declare plugins to extend the functionality of HomePortals -->
	<plugins>
		<!--<plugin name="sample" path="homePortals.components.plugin" />-->
	</plugins>		

	<!-- This section declares the available resource types -->
	<resourceTypes>
		<resourceType name="content">
			<folderName>Contents</folderName>
			<description>Content resources are blocks of formatted text that can be reused across a site</description>
			<fileTypes>htm</fileTypes>
		</resourceType>
						
		<resourceType name="feed">
			<folderName>Feeds</folderName>
			<description>Feeds are either RSS or Atom feeds from external sources that you can use with feed-enabled modules to display their contents on your site</description>
			<property name="rssurl" type="string" hint="Location of the source of the feed" label="Feed URL" />
			<property name="htmlurl" type="string" hint="Location of the website associated with this feed" label="Website URL" />
		</resourceType>
		
		<resourceType name="skin">
			<folderName>Skins</folderName>
			<description>Skins are a way to customize the look and feel of a page. Skins dictate things like colors, fonts, margins and other visual attributes of the page</description>
			<fileTypes>css</fileTypes>
		</resourceType>

		<resourceType name="image">
			<folderName>Images</folderName>
			<description>This resource type is used to represent an image document</description>
			<property name="label" type="string" hint="Image title" />
			<property name="url" type="string" hint="An URL address associated to this image" />
		</resourceType>
		
	</resourceTypes>
	
	<!-- Directories where HomePortals will look for resources  -->
	<resourceLibraryPaths>
		<resourceLibraryPath>/homePortals/resourceLibrary/</resourceLibraryPath>
	</resourceLibraryPaths>
	
</homePortals>