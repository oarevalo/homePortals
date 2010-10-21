<cfcomponent hint="This component describes a resource type">
	<cfscript>
		variables.DEFAULT_RES_BEAN_PATH = "homePortals.components.resourceBean";

		variables.instance = structNew();
		variables.instance.name = "";
		variables.instance.description = "";
		variables.instance.properties = structNew();
		variables.instance.resBeanPath = variables.DEFAULT_RES_BEAN_PATH;
		variables.instance.fileTypes = "";
	</cfscript>
	
	<cffunction name="init" access="public" returntype="resourceType" hint="Constructor">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="createBean" access="public" returntype="resourceBean" hint="Factory method that creates an empty bean for this resource type">
		<cfargument name="resLib" type="homePortals.components.resourceLibrary" required="true">
		<cfscript>
			var oResBean = createObject("component", getResBeanPath()).init( arguments.resLib );
			var stProps = getProperties();
			
			oResBean.setType ( variables.instance.name );
			
			for(p in stProps) {
				oResBean.setProperty( p, stProps[p]["default"] );
			}
		
			return oResBean;
		</cfscript>
	</cffunction>
	
	<cffunction name="getName" access="public" returntype="string" hint="Returns the resource type name">
		<cfreturn variables.instance.Name>
	</cffunction>

	<cffunction name="setName" access="public" returntype="resourceType" hint="Sets the resource type name">
		<cfargument name="data" type="string" required="true">
		<cfif arguments.data eq "">
			<cfthrow message="resource type name cannot be empty" type="homePortals.resourceType.validation">
		</cfif>
		<cfset variables.instance.Name = arguments.data>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getDescription" access="public" returntype="string" hint="Returns the resource type description">
		<cfreturn variables.instance.Description>
	</cffunction>

	<cffunction name="setDescription" access="public" returntype="resourceType" hint="Sets a description for this resource type">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.Description = arguments.data>
		<cfreturn this>
	</cffunction>
		
	<cffunction name="getProperties" access="public" returntype="struct" hint="Returns a copy of the structure containing all the custom properties for this resource type">
		<cfreturn duplicate(variables.instance.Properties)>
	</cffunction>

	<cffunction name="getProperty" access="public" returntype="struct" hint="Returns the value of the given custom property for this resource type">
		<cfargument name="name" type="string" required="true">
		<cfreturn duplicate(variables.instance.Properties[arguments.name])>
	</cffunction>

	<cffunction name="setProperty" access="public" returntype="resourceType" hint="Sets the value of a custom resource type property">
		<cfargument name="name" type="string" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="type" type="string" required="false" default="">
		<cfargument name="values" type="string" required="false" default="">
		<cfargument name="required" type="boolean" required="false" default="false">
		<cfargument name="default" type="string" required="false" default="">
		<cfargument name="label" type="string" required="false" default="">

		<cfif arguments.name eq "">
			<cfthrow message="Resource type property name cannot be empty" type="homePortals.resourceType.validation">
		</cfif>
		<cfif arguments.type eq "">
			<cfset arguments.type = "string">
		</cfif>

		<cfset variables.instance.Properties[arguments.name] = structNew()>
		<cfset variables.instance.Properties[arguments.name].name = arguments.name>
		<cfset variables.instance.Properties[arguments.name].description = arguments.description>
		<cfset variables.instance.Properties[arguments.name].type = arguments.type>
		<cfset variables.instance.Properties[arguments.name].values = arguments.values>
		<cfset variables.instance.Properties[arguments.name].required = arguments.required>
		<cfset variables.instance.Properties[arguments.name].default = arguments.default>
		<cfset variables.instance.Properties[arguments.name].label = arguments.label>
		<cfreturn this>
	</cffunction>

	<cffunction name="removeProperty" access="public" returntype="resourceType" hint="Deletes a resource type property">
		<cfargument name="name" type="string" required="true">
		<cfset structDelete(variables.instance.properties,arguments.name,false)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getResBeanPath" access="public" returntype="string" hint="Returns the path to the component that defines a resource bean for this type. This is provided so that resource types can have their own resourceBean implementations with custom behavior. By default all resources are implemented by homePortals.components.resourceBean">
		<cfreturn variables.instance.ResBeanPath>
	</cffunction>

	<cffunction name="setResBeanPath" access="public" returntype="resourceType" hint="Sets the path to the component that defines a resource bean for this type.">
		<cfargument name="data" type="string" required="true">
		<cfif arguments.data eq "">
			<cfthrow message="Resource type bean path cannot be empty" type="homePortals.resourceType.validation">
		</cfif>
		<cfset variables.instance.ResBeanPath = arguments.data>
		<cfreturn this>
	</cffunction>

	<cffunction name="getFileTypes" access="public" returntype="string" hint="Returns a list of file extensions that should be associated with this resource type. The extensions are used when creating new resource files or when trying to determine the type of a resource by just looking at a file.">
		<cfreturn variables.instance.FileTypes>
	</cffunction>

	<cffunction name="setFileTypes" access="public" returntype="resourceType" hint="Sets a list of file extensions associated with this resource type.">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.FileTypes = arguments.data>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>