<cfcomponent extends="homePortals.components.contentTagRenderer">
		
	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">

		<cfscript>
			var moduleID = getContentTag().getAttribute("id");

			try {
				arguments.headContentBuffer.set( renderOutput( getContent("head") ) );
				arguments.bodyContentBuffer.set( renderOutput( getContent("body") ) );
				
			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while processing module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set( tmpHTML );
			}
		</cfscript>
	</cffunction>

	<cffunction name="getHead" access="public" returntype="string">
		<cfreturn getContent("head")>
	</cffunction>

	<cffunction name="getBody" access="public" returntype="string">
		<cfreturn getContent("body")>
	</cffunction>
	

	<cffunction name="renderOutput" access="private" returntype="string">
		<cfargument name="source" required="true" type="string">
		<cfscript>
			var src = arguments.source;
			var index = 1;
			var finished = false;
			var mb = getContentTag().getModuleBean();
			var stNodeData = mb.getMemento();
			var stResult = 0;
			var token = "";
			var arg1 = "";
			var argDef = "";
			var rendered = "";
			
			while(Not finished) {
				stResult = reFindNoCase("\$MODULE_([A-Za-z0-9_|]*)\$", src, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(src,stResult.pos[1],stResult.len[1]);
					arg1 = mid(src,stResult.pos[2],stResult.len[2]);
					rendered = "";
					argDef = "";
					
					rendered = resolveResourceProperty(arg1);
					
					if(rendered eq "") {
						if(arg1.contains("|")) {
							argDef = listGetAt(arg1,2,"|");
							arg1 = listFirst(arg1,"|");
						}
						
						rendered = getContentTag().getAttribute(arg1,argDef);
						if(not isSimpleValue(rendered)) rendered = "";
					}
						
					src = replace(src, token, rendered, "ALL");
					index = stResult.pos[1] + len(rendered);
					
				} else {
					finished = true;
				}
			}
			
			return src;
		</cfscript>
	</cffunction>	
	
	<cffunction name="getContent" access="private" returntype="string" output="true">
		<cfargument name="type" required="true" type="string">
		<cfset var tmpHTML = "">
		<cfset var md = getMetaData(this)>
		<cfset var fname = replaceNoCase(md.path,".cfc","_#arguments.type#.inc")>
		<cfif fileExists(fname)>
			<cffile action="read" file="#fname#" variable="tmpHTML">
		</cfif>
		<cfreturn tmpHTML>	
	</cffunction>		

	<cffunction name="resolveResourceProperty" access="private" returntype="string">
		<cfargument name="name" required="true" type="string">
		<cfset var md = getMetaData(this)>
		<cfset var arg1 = arguments.name>	<!--- prop name --->
		<cfset var arg2 = "">				<!--- resource property --->
		<cfset var arg3 = "">				<!--- default value --->
		<cfset var type = "">
		<cfset var resourceID = "">
		<cfset var resourceType = "">
		<cfset var oResourceBean = "">
		<cfset var stProps = "">
		<cfset var stMemento = "">
		<cfset var oCatalog = getPageRenderer().getHomePortals().getCatalog()>
		
		<cfif arg1.contains("|")>
			<cfif listLen(arg1,"|") gt 2>
				<cfset arg3 = listGetAt(arg1,3,"|")>
			</cfif>
			<cfset arg2 = listGetAt(arg1,2,"|")>
			<cfset arg1 = listFirst(arg1,"|")>
		</cfif>
		
		<cfif getContentTag().getAttribute(arg1) eq "">
			<cfreturn arg3>
		</cfif>
		
		<cfif structKeyExists(md,"properties")>
			<cfloop from="1" to="#arrayLen(md.properties)#" index="i">
				<cfset type = md.properties[i].type>
				<cfif md.properties[i].name eq arg1
						and type.contains(":") 
						and listfirst(type,":") eq "resource">
					<cfset resourceType = listLast(type,":")>
					<cfset resourceID = getContentTag().getAttribute(arg1)>
					<cfif arg2 eq "">
						<cfreturn resourceID>
					<cfelse>
						<cfset oResourceBean = oCatalog.getResourceNode(resourceType, resourceID)>
						<cfset stProps = oResourceBean.getProperties()>
						<cfset stMemento = oResourceBean.getMemento()>

						<cfif arg2 eq "href" or arg2 eq "fullhref">
							<cfreturn oResourceBean.getFullHref()>

						<cfelseif structKeyExists(stProps,arg2) and isSimpleValue(stProps[arg2])>
							<cfreturn stProps[arg2]>

						<cfelseif structKeyExists(stMemento,arg2) and isSimpleValue(stMemento[arg2])>
							<cfreturn stMemento[arg2]>
							
						<cfelse>
							<cfreturn arg3>
						</cfif>
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
		
		<cfreturn arg3>
	</cffunction>

</cfcomponent>