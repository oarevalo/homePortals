<cfcomponent hint="This component is responsible for managing the plugins">

	<cfset variables.pluginsMap = structNew()>
	<cfset variables.homePortals = 0>
	<cfset variables.ALLOWED_EVENTS = "appInit,beforePageLoad,afterPageLoad">

	<cffunction name="init" access="public" returntype="pluginManager" hint="constructor">
		<cfargument name="homePortals" type="homePortals" required="true">
		<cfscript>
			var i = 0;
			var aPlugins = arguments.homePortals.getConfig().getPlugins();
			
			variables.homePortals = arguments.homePortals;
			
			for(i=1;i lte arrayLen(aPlugins);i++) {
				registerPlugin(aPlugins[i].name, aPlugins[i].path);
			}
			
			return this;
		</cfscript>
	</cffunction>

	<cffunction name="notifyPlugins" access="public" returntype="any" hint="notify registered plugins that an event has taken place">
		<cfargument name="eventType" type="string" required="true">
		<cfargument name="eventArg" type="any" required="false" default="">
		<cfset var retVal = arguments.eventArg>		
		
		<cfloop collection="#variables.pluginsMap#" item="key">
			<cfset retVal = notifyPlugin(key, arguments.eventType, retVal)>
		</cfloop>	

		<cfreturn retVal>
	</cffunction>

	<cffunction name="getPlugin" access="public" returntype="plugin" hint="return an instance of a registered plugin object">
		<cfargument name="pluginName" type="string" required="true">
		<cfif not structKeyExists(variables.pluginsMap, arguments.pluginName)>
			<cfthrow message="The requested plugin [#arguments.pluginName#] has not been registered." type="homePortals.pluginManager.invalidPluginName">
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

	<cffunction name="registerPlugin" access="public" returntype="void" hint="registers a plugin">
		<cfargument name="pluginName" type="string" required="true">
		<cfargument name="pluginPath" type="string" required="true">
		<cfif left(arguments.pluginPath,1) eq ".">
			<cfset arguments.pluginPath = variables.homePortals.getConfig().getAppRoot() & arguments.pluginPath>
			<cfset arguments.pluginPath = replace(arguments.pluginPath,"/",".","ALL")>
			<cfset arguments.pluginPath = replace(arguments.pluginPath,"..",".","ALL")>
			<cfif left(arguments.pluginPath,1) eq "/">
				<cfset arguments.pluginPath = right(arguments.pluginPath,len(arguments.pluginPath)-1)>
			</cfif>
		</cfif>
		<cfset variables.pluginsMap[arguments.pluginName] = createObject("component", arguments.pluginPath).init(variables.homePortals)>
	</cffunction>

	<cffunction name="notifyPlugin" access="public" returntype="any" hint="notify a registered plugin that an event has taken place">
		<cfargument name="pluginName" type="string" required="true">
		<cfargument name="eventType" type="string" required="true">
		<cfargument name="eventArg" type="any" required="false" default="">
		<cfset var retVal = arguments.eventArg>		
		
		<cfif not listFindNoCase(variables.ALLOWED_EVENTS, arguments.eventType)>
			<cfthrow message="The requested event type is not a valid event type" type="homePortals.pluginManager.invalidEventType">
		</cfif>
		
		<cfinvoke component="#variables.pluginsMap[arguments.pluginName]#" method="on#arguments.eventType#" returnvariable="retVal">
			<cfinvokeargument name="eventArg" value="#retVal#">
		</cfinvoke> 
		<cfif not isDefined("retVal")>
			<cfset retVal = "">
		</cfif>

		<cfreturn retVal>
	</cffunction>


</cfcomponent>