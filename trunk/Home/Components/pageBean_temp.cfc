<cfcomponent>

	<cfscript>
		variables.href = "";
		variables.title = "";
		variables.owner = "";
		variables.aStyles = ArrayNew(1);
		variables.aScripts = ArrayNew(1);
		variables.aEventListeners = ArrayNew(1);
		variables.stLayouts = StructNew();			// holds properties for layout sections
		variables.stModules = StructNew();		// holds modules			
	</cfscript>

	<cffunction name="init" access="public" returntype="page">
		<cfargument name="href" type="string" required="false" default="">
		
		<cfif arguments.href neq "">
			<cfset load(arguments.href)>
		</cfif>

		<cfreturn this>		
	</cffunction>
	
	
	<cffunction name="getTitle" access="public" returntype="string">
		<cfreturn variables.title>
	</cffunction>

	<cffunction name="getOwner" access="public" returntype="string">
		<cfreturn variables.owner>
	</cffunction>
	
	<cffunction name="getStylesheets" access="public" returntype="array">
		<cfset var aRet = arrayNew(1)>
		<cfloop collection="#variables.stStyles#" item="key">
			<cfset arrayAppend(aRet, variables.stStyles[key])>
		</cfloop>
		<cfreturn aRet>
	</cffunction>

	<cffunction name="getScripts" access="public" returntype="array">
		<cfset var aRet = arrayNew(1)>
		<cfloop collection="#variables.stScripts#" item="key">
			<cfset arrayAppend(aRet, variables.stScripts[key])>
		</cfloop>
		<cfreturn aRet>
	</cffunction>

	<cffunction name="getEventListeners" access="public" returntype="array">
		<cfreturn variables.aEventListeners>
	</cffunction>

	<cffunction name="getLayouts" access="public" returntype="array">
		<cfset var aRet = arrayNew(1)>
		<cfloop collection="#variables.stLayouts#" item="key">
			<cfset arrayAppend(aRet, variables.stLayouts[key])>
		</cfloop>
		<cfreturn aRet>
	</cffunction>

	<cffunction name="getModules" access="public" returntype="array">
		<cfset var aRet = arrayNew(1)>
		<cfloop collection="#variables.stModules#" item="key">
			<cfset arrayAppend(aRet, variables.stModules[key])>
		</cfloop>
		<cfreturn aRet>
	</cffunction>



	<cffunction name="setTitle" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.title = trim(arguments.data)>
	</cffunction>

	<cffunction name="setOwner" access="public" returnType="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.owner = trim(arguments.data)>
	</cffunction>

	<cffunction name="addStylesheet" access="public" returnType="void">
		<cfargument name="href" type="string" required="true">
		<cfset variables.stStyles[hash(arguments.href)] = arguments.href>
	</cffunction>
	
	<cffunction name="addScript" access="public" returnType="void">
		<cfargument name="href" type="string" required="true">
		<cfset variables.stScripts[hash(arguments.href)] = arguments.href>
	</cffunction>

	<cffunction name="addEventListener" access="public" returnType="void">
		<cfargument name="event" type="string" required="true">
		<cfargument name="action" type="string" required="true">
		<cfset var st = structNew()>
		<cfset st.event = arguments.event>
		<cfset st.action = arguments.action>
		<cfset ArrayAppend(variables.aEventHandlers, st)>
	</cffunction>

	<cffunction name="removeStylesheet" access="public" returnType="void">
		<cfargument name="href" type="string" required="true">
		<cfset structDelete(variables.stStyles, hash(arguments.href))>
	</cffunction>

	<cffunction name="removeScript" access="public" returnType="void">
		<cfargument name="href" type="string" required="true">
		<cfset structDelete(variables.stScripts, hash(arguments.href))>
	</cffunction>



</cfcomponent>