<cfcomponent hint="This component is responsible for managing the plugins">

	<cfset variables.pluginsMap = structNew()>
	<cfset variables.ALLOWED_EVENTS = "appInit,beforePageLoad,afterPageLoad">

	<cffunction name="init" access="public" returntype="pluginManager" hint="constructor">
		<cfargument name="homePortals" type="homePortals" required="true">
		<cfscript>
			var key = "";
			var stPlugins = arguments.homePortals.getConfig().getPlugins();
			
			for(key in stPlugins) {
				variables.pluginsMap[key] = createObject("component", stPlugins[key]).init(arguments.homePortals);
			}
			
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="notifyPlugins" access="public" returntype="any" hint="notify registered plugins that an event has taken place">
		<cfargument name="eventType" type="string" required="true">
		<cfargument name="eventArg" type="any" required="false" default="">
		<cfset var retVal = arguments.eventArg>		
		
		<cfif not listFindNoCase(variables.ALLOWED_EVENTS, arguments.eventType)>
			<cfthrow message="The requested event type is not a valid event type" type="homePortals.pluginManager.invalidEventType">
		</cfif>
		
		<cfloop collection="#variables.pluginsMap#" item="key">
			<cfinvoke component="#variables.pluginsMap[key]#" method="on#arguments.eventType#" returnvariable="retVal">
				<cfinvokeargument name="eventArg" value="#retVal#">
			</cfinvoke> 
			<cfif not isDefined("retVal")>
				<cfset retVal = "">
			</cfif>
		</cfloop>	

		<cfreturn retVal>
	</cffunction>

	<cffunction name="getPlugin" access="public" returntype="plugin" hint="return an instance of a registered plugin object">
		<cfargument name="pluginName" type="string" required="true">
		<cfif not structKeyExists(variables.pluginsMap, arguments.pluginName)>
			<cfthrow message="The requested plugin has not been registered" type="homePortals.pluginManager.invalidPluginName">
		</cfif>
		<cfreturn variables.pluginsMap[arguments.pluginName]>	
	</cffunction>

	<cffunction name="getPlugins" access="public" returntype="array" hint="returns an array with names of the registered plugins">
		<cfreturn listToArray(structKeyList(variables.pluginsMap))>
	</cffunction>

	<cffunction name="hasPlugin" access="public" returntype="boolean" hint="checks whether a given plugin has been registered">
		<cfargument name="pluginName" type="string" required="true">
		<cfreturn structKeyExists(variables.pluginsMap, arguments.pluginName)>
	</cffunction>

</cfcomponent>