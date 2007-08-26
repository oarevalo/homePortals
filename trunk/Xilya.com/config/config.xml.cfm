<?xml version="1.0" encoding="ISO-8859-1"?>
<Config>
	<Settings>
		<Setting name="AppName" 					value="Xilya"/>
		<Setting name="AppMapping" 					value=""/>
		<Setting name="AppDevMapping" 				value="xilyaweb"/>
		<Setting name="DebugMode" 					value="false"/>
		<Setting name="DebugPassword" 				value="Textus"/>
		<Setting name="DefaultEvent" 				value="ehGeneral.dspHome"/>
		<Setting name="RequestStartHandler" 		value=""/>
		<Setting name="RequestEndHandler" 			value=""/>
		<Setting name="OwnerEmail" 					value="info@cfempire.com"/>
		<Setting name="EnableBugReports" 			value="true"/>
		<Setting name="UDFLibraryFile" 				value="" />
		<Setting name="CustomErrorTemplate"			value="" />
		<Setting name="MessageboxStyleClass"		value="mymessagebox" />
		<Setting name="HandlersIndexAutoReload"		value="true" />
	</Settings>
	
	<!--Optional,if blank it will use the CFMX administrator settings.-->
	<MailServerSettings>
		<MailServer></MailServer>
		<MailUsername></MailUsername>
		<MailPassword></MailPassword>
	</MailServerSettings>
	
	<BugTracerReports>
		<BugEmail>info@xilya.com</BugEmail>
	</BugTracerReports>

	<DevEnvironments>
		<url>localhost</url>
		<url>dev1</url>
		<url>dev</url>
	</DevEnvironments>

	<Layouts>
		<DefaultLayout>Layout.Main.cfm</DefaultLayout>
	</Layouts>
</Config>
