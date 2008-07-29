<cfcomponent name="baseModule" displayname="baseModule" hint="Base component for all modules">

	<!--- this will provide a reference to the moduleController that invokes this module --->
	<cfset this.controller = 0>

	<!---------------------------------------->
	<!--- init		                       --->
	<!---------------------------------------->	
	<cffunction name="init" access="public" returntype="void"
				hint="overload this method to add initialization code for a module. This method is executed for each module instance.">
		<!--- overload this method  --->
	</cffunction>

	<!---------------------------------------->
	<!--- renderInclude	                   --->
	<!---------------------------------------->		
	<cffunction name="renderInclude" access="public" returntype="string" 
				hint="Returns the output of an included file. The included file is executed under the context of the current module.">
		<cfargument name="fileToInclude" type="any" required="true">
		<cfset var tmpHTML = "">
		<cfset var moduleRoot = this.controller.getModuleConfigBean().getModuleRoot()>
		<cfsavecontent variable="tmpHTML">
			<cfinclude template="#moduleRoot##arguments.fileToInclude#">	
		</cfsavecontent>
		<cfreturn tmpHTML>
	</cffunction>	
</cfcomponent>