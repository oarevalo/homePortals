<cfcomponent hint="This manages the different templates used to render content">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.stTemplates = structNew()>
	<cfset variables.instance.stTemplateDefaults = structNew()>
	<cfset variables.stRenderTemplatesCache = structNew()>

	<cffunction name="init" access="public" returntype="templateManager">
		<cfargument name="config" type="homePortalsConfigBean" required="true">
		<cfset var st = arguments.config.getRenderTemplates()>
		
		<cfloop collection="#st#" item="key">
			<cfset setTemplate(argumentCollection = st[key])>
		</cfloop>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="setTemplate" access="public" returntype="void">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="isDefault" type="boolean" required="false" default="false">
		
		<cfif not structKeyExists(variables.instance.stTemplates, arguments.type)>
			<cfset variables.instance.stTemplates[arguments.type] = structNew()>
		</cfif>
		
		<cfset variables.instance.stTemplates[arguments.type][arguments.name] = {
																					name = arguments.name,
																					type = arguments.type,
																					href = arguments.href,
																					description = arguments.description,
																					isDefault = arguments.isdefault
																				}>
	
		<!--- set default template for type --->																				
		<cfif arguments.isDefault or not structKeyExists(variables.instance.stTemplateDefaults, arguments.type)>
			<cfset variables.instance.stTemplateDefaults[arguments.type] = arguments.name>
		</cfif>										
										
	</cffunction>
	
	<cffunction name="getTemplate" access="public" returntype="struct">
		<cfargument name="type" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfreturn duplicate(variables.instance.stTemplates[arguments.type][arguments.name])>
	</cffunction>

	<cffunction name="getDefaultTemplate" access="public" returntype="struct">
		<cfargument name="type" type="string" required="true">
		<cfset var t = variables.instance.stTemplates[arguments.type]>
		<cfset var td = variables.instance.stTemplateDefaults[arguments.type]>
		<cfreturn duplicate(t[td])>
	</cffunction>

	<cffunction name="getTemplateBody" access="public" returntype="string" hint="returns the contents of a rendertemplate">
		<cfargument name="type" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfset var key = "">	
		<cfset var templateBody = "">
		<cfset var st = structNew()>
			
		<cfif arguments.name eq "">
			<cfset st = getDefaultTemplate(arguments.type)>
		<cfelse>
			<cfset st = getTemplate(arguments.type, arguments.name)>
		</cfif>	
			
		<cfset key = arguments.type & "-" & arguments.name>	
			
		<cfif Not StructKeyExists(variables.stRenderTemplatesCache, key)>
			<cffile action="read" file="#expandPath(st.href)#" variable="templateBody">
			<cfset variables.stRenderTemplatesCache[key] = templateBody>
		<cfelse>
			<cfset templateBody = variables.stRenderTemplatesCache[key]>
		</cfif>

		<cfreturn templateBody>
	</cffunction>

	<cffunction name="getLayoutSections" access="public" returntype="string">
		<cfargument name="pageTemplate" type="string" required="false" default="">
		<cfscript>
			var index = 1;
			var finished = false;
			var renderTemplateBody = "";
			var lstSections = "";
			var st = structNew();
			var token = ""; var arg1 = ""; var arg2 = "";
			
			if(arguments.pageTemplate eq "") {
				st = getDefaultTemplate("page");
				arguments.pageTemplate = st.name;
			}
			
			renderTemplateBody = getRenderTemplateBody("page", arguments.pageTemplate);

			while(Not finished) {
				stResult = reFindNoCase("\$PAGE_LAYOUTSECTION\[""([A-Za-z0-9_]*)""\]\[""([A-Za-z0-9_]*)""\]\$", renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					arg2 = mid(renderTemplateBody,stResult.pos[3],stResult.len[3]);
					lstSections = listAppend(lstSections,arg1);
					index = stResult.pos[1] + stResult.len[1];
				} else {
					finished = true;
				}
			}		
			
			return lstSections;
		</cfscript>
	</cffunction>
	
</cfcomponent>