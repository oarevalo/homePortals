<cfcomponent hint="I represent a reusable resource" output="false">

	<cfproperty name="Name" type="string" hint="resource name" />
	<cfproperty name="Href" type="string" />
	<cfproperty name="Type" type="string" hint="Resource type" />
	<cfproperty name="Package" type="string" hint="The package to which this resource belongs to" />
	<cfproperty name="Owner" type="string" hint="Resource owner, must identify an account" />
	<cfproperty name="AccessType" type="string" />
	<cfproperty name="ID" type="string" />
	<cfproperty name="Description" type="string" />
	<cfproperty name="AuthorName" type="string" />
	<cfproperty name="AuthorEmail" type="string" />
	<cfproperty name="AuthorURL" type="string" />
	<cfproperty name="Screenshot" type="string" hint="URL of an image of the resource" />
	<cfproperty name="Methods" type="array" hint="For module resources, this represents a list of available operations" />
	<cfproperty name="Events" type="array" hint="For module resources, this represents a list of events raised by the module" />
	<cfproperty name="Attributes" type="array" hint="For module resources, this represent a list of attributes that can be used to configure this module" />

	<cffunction name="Init" access="public" output="false" returntype="Any">
		<cfargument name="resourceNode" type="XML" hint="XML node from a descriptor document that represents the resource" required="false" />

	<cfdump var="#arguments#">

		<cfscript>
			if(isXmlNode(arguments.resourceNode)) {
			
				// populate bean
			
			}
		</cfscript>
		
		<cfreturn this />
	</cffunction>

	<cffunction name="toXML" hint="Returns the xml representation of this resource" access="public" output="false" returntype="xml">
		<!--- TODO: Implement Method --->
		<cfreturn />
	</cffunction>
	

	<cffunction name="getName" access="public" output="false" returntype="string">
		<cfreturn Name />
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void">
		<cfargument name="Name" type="string" required="true" />
		<cfset Name = arguments.Name />
		<cfreturn />
	</cffunction>

	<cffunction name="getHref" access="public" output="false" returntype="string">
		<cfreturn Href />
	</cffunction>

	<cffunction name="setHref" access="public" output="false" returntype="void">
		<cfargument name="Href" type="string" required="true" />
		<cfset Href = arguments.Href />
		<cfreturn />
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="string">
		<cfreturn Type />
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="void">
		<cfargument name="Type" type="string" required="true" />
		<cfset Type = arguments.Type />
		<cfreturn />
	</cffunction>

	<cffunction name="getPackage" access="public" output="false" returntype="string">
		<cfreturn Package />
	</cffunction>

	<cffunction name="setPackage" access="public" output="false" returntype="void">
		<cfargument name="Package" type="string" required="true" />
		<cfset Package = arguments.Package />
		<cfreturn />
	</cffunction>

	<cffunction name="getOwner" access="public" output="false" returntype="string">
		<cfreturn Owner />
	</cffunction>

	<cffunction name="setOwner" access="public" output="false" returntype="void">
		<cfargument name="Owner" type="string" required="true" />
		<cfset Owner = arguments.Owner />
		<cfreturn />
	</cffunction>

	<cffunction name="getAccessType" access="public" output="false" returntype="string">
		<cfreturn AccessType />
	</cffunction>

	<cffunction name="setAccessType" access="public" output="false" returntype="void">
		<cfargument name="AccessType" type="string" required="true" />
		<cfset AccessType = arguments.AccessType />
		<cfreturn />
	</cffunction>

	<cffunction name="getID" access="public" output="false" returntype="string">
		<cfreturn ID />
	</cffunction>

	<cffunction name="setID" access="public" output="false" returntype="void">
		<cfargument name="ID" type="string" required="true" />
		<cfset ID = arguments.ID />
		<cfreturn />
	</cffunction>

	<cffunction name="getDescription" access="public" output="false" returntype="string">
		<cfreturn Description />
	</cffunction>

	<cffunction name="setDescription" access="public" output="false" returntype="void">
		<cfargument name="Description" type="string" required="true" />
		<cfset Description = arguments.Description />
		<cfreturn />
	</cffunction>

	<cffunction name="getAuthorName" access="public" output="false" returntype="string">
		<cfreturn AuthorName />
	</cffunction>

	<cffunction name="setAuthorName" access="public" output="false" returntype="void">
		<cfargument name="AuthorName" type="string" required="true" />
		<cfset AuthorName = arguments.AuthorName />
		<cfreturn />
	</cffunction>

	<cffunction name="getAuthorEmail" access="public" output="false" returntype="string">
		<cfreturn AuthorEmail />
	</cffunction>

	<cffunction name="setAuthorEmail" access="public" output="false" returntype="void">
		<cfargument name="AuthorEmail" type="string" required="true" />
		<cfset AuthorEmail = arguments.AuthorEmail />
		<cfreturn />
	</cffunction>

	<cffunction name="getAuthorURL" access="public" output="false" returntype="string">
		<cfreturn AuthorURL />
	</cffunction>

	<cffunction name="setAuthorURL" access="public" output="false" returntype="void">
		<cfargument name="AuthorURL" type="string" required="true" />
		<cfset AuthorURL = arguments.AuthorURL />
		<cfreturn />
	</cffunction>

	<cffunction name="getScreenshot" access="public" output="false" returntype="string">
		<cfreturn Screenshot />
	</cffunction>

	<cffunction name="setScreenshot" access="public" output="false" returntype="void">
		<cfargument name="Screenshot" type="string" required="true" />
		<cfset Screenshot = arguments.Screenshot />
		<cfreturn />
	</cffunction>

	<cffunction name="getMethods" access="public" output="false" returntype="array">
		<cfreturn Methods />
	</cffunction>

	<cffunction name="getEvents" access="public" output="false" returntype="array">
		<cfreturn Events />
	</cffunction>

	<cffunction name="getAttributes" access="public" output="false" returntype="any">
		<cfreturn Attributes />
	</cffunction>


</cfcomponent>