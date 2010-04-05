<?xml version="1.0" encoding="ISO-8859-1"?>
<config>
	<!-- This section describes application-specific settings -->
	<settings>
		<!-- 
		<setting name="some_name" value="some_value" />
		-->
	</settings>


	<!-- This section describes all services that will be loaded into the application -->
	<services>
		<service name="homePortals" class="homePortals.components.homePortals">
			<init-param name="appRoot">$APP_PATH</init-param>
		</service>
	</services>
</config>

