<cfcomponent hint="This manages the different templates used to render content">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.stTemplates = structNew()>
	<cfset variables.stRenderTemplatesCache = structNew()>
	<cfset variables.DEFAULT_PAGE_TEMPLATE = "page">

	<cffunction name="init" access="public" returntype="templateManager">
		<cfargument name="config" type="homePortalsConfigBean" required="true">
		<cfset var st = arguments.config.getRenderTemplates()>
		
		<cfloop collection="#st#" item="key">
			<cfset addTemplate(key, st[key])>
		</cfloop>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="addTemplate" access="public" returntype="void">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfset variables.instance.stTemplates[arguments.type] = arguments.href>
	</cffunction>
	
	<cffunction name="getTemplate" access="public" returntype="string">
		<cfargument name="templateName" type="string" required="true">
		<cfreturn variables.instance.stTemplates[arguments.templateName]>
	</cffunction>

	<cffunction name="getLayoutSections" access="public" returntype="string">
		<cfargument name="pageTemplate" type="string" required="false" default="">
		<cfscript>
			var index = 1;
			var finished = false;
			var renderTemplateBody = "";
			var lstSections = "";
			var stResult = structNew();
			var token = ""; var arg1 = ""; var arg2 = "";
			
			if(arguments.pageTemplate eq "") arguments.pageTemplate = variables.DEFAULT_PAGE_TEMPLATE;
			renderTemplateBody = getRenderTemplateBody(arguments.pageTemplate);

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

	<cffunction name="getRenderTemplateBody" access="public" returntype="string" hint="returns the contents of a rendertemplate">
		<cfargument name="type" type="string" required="true">
			
		<cfif Not StructKeyExists(variables.stRenderTemplatesCache, arguments.type)>
			<cfset xmlDoc = xmlParse(expandPath( getTemplate(arguments.type) ))>
			<cfset templateBody = toString(xmlDoc.xmlRoot.xmlChildren[1])>
			<cfset variables.stRenderTemplatesCache[arguments.type] = templateBody>
		<cfelse>
			<cfset templateBody = variables.stRenderTemplatesCache[arguments.type]>
		</cfif>

		<cfreturn templateBody>
	</cffunction>
	
</cfcomponent>