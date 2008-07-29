<cfcomponent hint="This is the main controller for the application">

	<!------------------------------------------------->
	<!--- Private Methods                          ---->
	<!------------------------------------------------->
	<cffunction name="dump" access="private">
		<cfargument name="var" type="any">
		<cfdump var="#arguments.var#">
	</cffunction>

	<cffunction name="warn" access="private">
		<cfargument name="message" type="string">
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="warning">
	</cffunction>

	<cffunction name="throw" access="private">
		<cfargument name="message" type="string">
		<cfargument name="detail" type="string" default=""> 
		<cfargument name="type" type="string" default="custom"> 
		<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#">
	</cffunction>

	<cffunction name="createInstance" returntype="Any" access="private">
		<cfargument name="path" type="String" required="true">
		<cfargument name="type" type="String" required="no" default="">

		<cfscript>
			/****************************************************************
			 UDF:    component(path, type)
			 Author: Dan G. Switzer, II
			 Date:   5/26/2004
			
			 Arguments:
			  path - the path to the component. can be standard 
			         dot notation, relative path or absolute path
			  type - the type of path specified. "component" uses
			         the standard CF dot notation. "relative" uses
			         a relative path the the CFC (including file
			         extension.) "absolute" indicates your using
			         the direct OS path to the CFC. By default
			         this tag will either be set to "component"
			         (if no dots or no slashes and dots are found)
			         or it'll be set to "relative". As a shortcut,
			         you can use just the first letter of the type.
			         (i.e. "c" for "component, etc.)
			 Notes:
			  This is based upon some code that has floated around the
			  different CF lists.
			****************************************************************/
				var sPath=Arguments.path;var oProxy="";var oFile="";var sProxyPath = "";
				var sType = lcase(Arguments.type);
			
				// determine a default type	
				if( len(sType) eq 0 ){
					if( (sPath DOES NOT CONTAIN ".") OR ((sPath CONTAINS ".") AND (sPath DOES NOT CONTAIN "/") AND (sPath DOES NOT CONTAIN "\")) ) sType = "component";
					else sType = "relative";
				}
				
				// create the component
				switch( left(sType,1) ){
					case "c":
						return createObject("component", sPath);
					break;
			
					default:
						if( left(sType, 1) neq "a" ) sPath = expandPath(sPath);
						// updated to work w/CFMX v6.1 and v6.0
						// if this code breaks, MACR has either moved the TemplateProxy
						// again or simply prevented it from being publically accessed
						if( left(server.coldFusion.productVersion, 3) eq "6,0") sProxyPath = "coldfusion.runtime.TemplateProxy";
						else sProxyPath = "coldfusion.runtime.TemplateProxyFactory";
						try {
							oProxy = createObject("java", sProxyPath);
							oFile = createObject("java", "java.io.File");
							oFile.init(sPath);
							return oProxy.resolveFile(getPageContext(), oFile);
						}
						catch(Any exception){
							throw("An error occured initializing the component #arguments.path#.");
							return;
						}
					break;
				}
		</cfscript>
	</cffunction>


</cfcomponent>
