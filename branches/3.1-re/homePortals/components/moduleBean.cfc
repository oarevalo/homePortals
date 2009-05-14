<cfcomponent>
	
	<cfproperty name="id" type="string" required="true" displayname="ID" />
	<cfproperty name="moduleType" type="string" required="true" displayname="Module Template" />
	<cfproperty name="title" type="string" required="false" displayname="Title" />
	<cfproperty name="icon" type="string" required="false" displayname="Icon" />
	<cfproperty name="style" type="string" required="false" displayname="Style" />
	<cfproperty name="class" type="string" required="false" displayname="Class" />
	<cfproperty name="container" type="boolean" required="false" displayname="Container" />
	<cfproperty name="output" type="boolean" required="false" displayname="Output" />
	<cfproperty name="moduleTemplate" type="string" required="false" displayname="Module Template" />
	<cfproperty name="location" type="string" required="false" displayname="Location" />

	<cfscript>
		variables.instance = {
								id = "",
								moduleType = "",
								title = "",
								icon = "",
								style = "",
								class = "",
								container = true,
								output = true,
								moduleTemplate = "",
								location = "",
								stProperties = { }
							};
	</cfscript>	

	<cffunction name="init" access="public" returntype="moduleBean">
		<cfargument name="data" type="any" required="false" default="">
		<cfif isStruct(arguments.data)>
			<cfscript>
				for(item in arguments.data) {
					switch(item) {
						case "id": setID( arguments.data[item] ); break;
						case "moduleType": setModuleType( arguments.data[item] ); break;
						case "title": setTitle( arguments.data[item] ); break;
						case "icon": setIcon( arguments.data[item] ); break;
						case "style": setStyle( arguments.data[item] ); break;
						case "class": setCSSClass( arguments.data[item] ); break;
						case "container": setContainer( isBoolean(arguments.data[item]) and arguments.data[item] ); break;
						case "output": setOutput( isBoolean(arguments.data[item]) and arguments.data[item] ); break;
						case "moduleTemplate": setModuleTemplate( arguments.data[item] ); break;
						case "location": setLocation( arguments.data[item] ); break;
						default:
							setProperty(item, arguments.data[item]);
					}
				}
			</cfscript>
		</cfif>
		<cfreturn this>
	</cffunction>


	
	<!--- getters and setters --->

	<cffunction name="getID" access="public" returntype="string">
		<cfreturn variables.instance.id>
	</cffunction>

	<cffunction name="setID" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfif !len(trim(arguments.data))>
			<cfthrow message="Module ID cannot be empty" type="homePortals.moduleBean.missingModuleID">
		</cfif>
		<cfset variables.instance.id = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getModuleTemplate" access="public" returntype="string">
		<cfreturn variables.instance.ModuleTemplate>
	</cffunction>

	<cffunction name="setModuleTemplate" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.ModuleTemplate = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getModuleType" access="public" returntype="string">
		<cfreturn variables.instance.ModuleType>
	</cffunction>

	<cffunction name="setModuleType" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfif !len(trim(arguments.data))>
			<cfthrow message="Module Type cannot be empty" type="homePortals.moduleBean.missingModuleType">
		</cfif>
		<cfset variables.instance.ModuleType = arguments.data>
		<cfreturn this>
	</cffunction>
		
	<cffunction name="getTitle" access="public" returntype="string">
		<cfreturn variables.instance.title>
	</cffunction>

	<cffunction name="setTitle" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.title = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getIcon" access="public" returntype="string">
		<cfreturn variables.instance.icon>
	</cffunction>

	<cffunction name="setIcon" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.icon = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getStyle" access="public" returntype="string">
		<cfreturn variables.instance.style>
	</cffunction>

	<cffunction name="setStyle" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.style = arguments.data>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getCSSClass" access="public" returntype="string">
		<cfreturn variables.instance.class>
	</cffunction>

	<cffunction name="setCSSClass" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.class = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getContainer" access="public" returntype="boolean">
		<cfreturn variables.instance.Container>
	</cffunction>

	<cffunction name="setContainer" access="public" returntype="moduleBean">
		<cfargument name="data" type="boolean" required="true">
		<cfset variables.instance.Container = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getOutput" access="public" returntype="boolean">
		<cfreturn variables.instance.Output>
	</cffunction>

	<cffunction name="setOutput" access="public" returntype="moduleBean">
		<cfargument name="data" type="boolean" required="true">
		<cfset variables.instance.Output = arguments.data>
		<cfreturn this>
	</cffunction>		

	<cffunction name="getLocation" access="public" returntype="string">
		<cfreturn variables.instance.Location>
	</cffunction>

	<cffunction name="setLocation" access="public" returntype="moduleBean">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.Location = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getProperties" access="public" returntype="struct" hint="returns a struct with all custom properties">
		<cfreturn duplicate(variables.instance.stProperties)>
	</cffunction>

	<cffunction name="getProperty" access="public" returnType="string" hint="returns the value of a custom property">
		<cfargument name="name" type="string" required="true">
		<cfif structKeyExists(variables.instance.stProperties, arguments.name)>
			<cfreturn variables.instance.stProperties[arguments.name]>
		<cfelse>
			<cfthrow message="Property '#arguments.name#' is not defined" type="homePortals.moduleBean.invalidProperty">
		</cfif>
	</cffunction>

	<cffunction name="hasProperty" access="public" returnType="string" hint="returns whether a given custom property exists">
		<cfargument name="name" type="string" required="true">
		<cfreturn structKeyExists(variables.instance.stProperties, arguments.name)>
	</cffunction>

	<cffunction name="setProperty" access="public" returnType="moduleBean" hint="sets the value of a custom property">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfset variables.instance.stProperties[arguments.name] = arguments.value>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeProperty" access="public" returnType="moduleBean" hint="removes a custom property">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.instance.stProperties, arguments.name,false)>
		<cfreturn this>
	</cffunction>	
	
	
	<cffunction name="getMemento" access="public" returntype="struct">
		<cfreturn duplicate(variables.instance)>
	</cffunction>

	<cffunction name="toStruct" access="public" returntype="struct" hint="returns a flat struct with all properties (custom and standard) for this module">
		<cfset var st = duplicate(variables.instance)>
		<cfset structAppend(st, getProperties())>
		<cfset structDelete(st,"stProperties")>
		<cfreturn st>
	</cffunction>
			
</cfcomponent>