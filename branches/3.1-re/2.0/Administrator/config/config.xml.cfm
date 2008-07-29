<?xml version="1.0" encoding="ISO-8859-1"?>
<Config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:noNamespaceSchemaLocation="http://www.luismajano.com/projects/coldbox/schema/config.xsd">
	<Settings>
		<Setting name="AppName"					value="HomePortals Administrator"/>
		<Setting name="AppMapping" 				value="Home/Administrator" />
		<Setting name="AppDevMapping" 			value="Home/Administrator" />
		<Setting name="DebugMode" 				value="false" />
		<Setting name="DebugPassword" 			value="cfempire"/>
		<Setting name="DefaultEvent" 			value="ehGeneral.dspStart"/>
		<Setting name="RequestStartHandler" 	value="ehGeneral.onRequestStart"/>
		<Setting name="RequestEndHandler" 		value=""/>
		<Setting name="ApplicationStartHandler" value="ehGeneral.onApplicationStart"/>
		<Setting name="EnableBugReports" 		value="false"/>
		<Setting name="EnableColdfusionLogging"	value="false"/>
		<Setting name="EnableColdboxLogging"	value="true"/>
		<Setting name="EnableDumpVar"			value="false"/>
		<Setting name="ColdboxLogsLocation"		value="logs"/>
		<Setting name="UDFLibraryFile" 			value="" />
		<Setting name="ExceptionHandler"		value="" />
		<Setting name="CustomErrorTemplate"		value="" />
		<Setting name="MessageboxStyleClass"	value="" />
		<Setting name="HandlersIndexAutoReload" value="true" />
		<Setting name="ConfigAutoReload"        value="false" />
		<Setting name="OwnerEmail"          	value="support@cfempire.com" />
		<Setting name="MyPluginsLocation"       value="" />
	</Settings>

	<!--Your Settings can go here, if not needed, use <YourSettings />. You can use these for anything you like.
		<Setting name="MySetting"  				value="WOW" />
	 -->
	<YourSettings>
		<Setting name="HomeRoot"  				value="/Home" />
		<Setting name="HomePortalsRSS"			value="http://www.homeportals.net/Home/Modules/Blog/blog.cfc?method=getRSS&amp;url=/Accounts/wencho/blog.xml" />
	</YourSettings>

	<!--List url dev environments, this determines your dev/pro environment for the framework-->
	<DevEnvironments>
		<url>wencho.net</url>
		<url>cfempire.com</url>
		<url>homeportals.net</url>
	</DevEnvironments>

	<!--Declare Layouts for your application here-->
	<Layouts>
		<!--Declare the default layout, MANDATORY-->
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
		<Layout file="Layout.Clean.cfm" name="clean">
			<View>vwLogin</View>
			<View>vwLicense</View>
		</Layout>		
	</Layouts>

</Config>
