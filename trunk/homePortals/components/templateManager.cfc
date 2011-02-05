<cfcomponent hint="This manages the different templates used to render content">

	<cfset variables.instance = structNew()>
	<cfset variables.instance.stTemplates = structNew()>
	<cfset variables.instance.stTemplateDefaults = structNew()>
	<cfset variables.stRenderTemplatesCache = structNew()>
	<cfset variables.appRoot = "">
	<cfset variables.tokenExprMap = {
							pageTitle = "\$PAGE_TITLE\$",
							htmlHead = "\$PAGE_HTMLHEAD\$",
							pageProperty = "\$PAGE_PROPERTY\[""([A-Za-z0-9_]*)""\]\$",
							customSection = "\$PAGE_CUSTOMSECTION\[""([A-Za-z0-9_]*)""]\$",
							layoutSection = "\$PAGE_LAYOUTSECTION\[""([A-Za-z0-9_]*)""\]\[""([A-Za-z0-9_]*)""\]\$",
							moduleIcon = "$MODULE_ICON$",
							moduleProperty = "\$MODULE_([A-Za-z0-9_]*)\$",
							moduleContent = "$MODULE_CONTENT$",
							contextToken = "\$?{([A-Za-z0-9_]*)}"
						}>

	<cffunction name="init" access="public" returntype="templateManager" hint="Constructor">
		<cfargument name="config" type="homePortalsConfigBean" required="true">
		<cfset var st = arguments.config.getRenderTemplates()>
		<cfset var rtName = "">
		<cfset var rtType = "">
		
		<cfloop collection="#st#" item="rtType">
			<cfloop collection="#st[rtType]#" item="rtName">
				<cfset setTemplate(argumentCollection = st[rtType][rtName])>
			</cfloop>
		</cfloop>
		
		<cfset variables.appRoot = arguments.config.getAppRoot()>
		
		<cfreturn this>
	</cffunction>

	<cffunction name="setTemplate" access="public" returntype="void" hint="Registers a new template with the manager">
		<cfargument name="name" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="href" type="string" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="isDefault" type="boolean" required="false" default="false">
		<cfargument name="useHTTP" type="boolean" required="false" default="false">
		
		<cfif not structKeyExists(variables.instance.stTemplates, arguments.type)>
			<cfset variables.instance.stTemplates[arguments.type] = structNew()>
		</cfif>
		
		<cfset variables.instance.stTemplates[arguments.type][arguments.name] = {
																					name = arguments.name,
																					type = arguments.type,
																					href = arguments.href,
																					description = arguments.description,
																					isDefault = arguments.isdefault,
																					useHTTP = arguments.useHTTP
																				}>
	
		<!--- set default template for type --->																				
		<cfif arguments.isDefault or not structKeyExists(variables.instance.stTemplateDefaults, arguments.type)>
			<cfset variables.instance.stTemplateDefaults[arguments.type] = arguments.name>
		</cfif>										
										
	</cffunction>

	<cffunction name="getTemplates" access="public" returntype="struct" hint="Returns a struct containing all registered templates of the given type">
		<cfargument name="type" type="string" required="true">
		<cfreturn duplicate(variables.instance.stTemplates[arguments.type])>
	</cffunction>
	
	<cffunction name="getTemplate" access="public" returntype="struct" hint="Returns a struct containing information about a specific template given its type and name.">
		<cfargument name="type" type="string" required="true">
		<cfargument name="name" type="string" required="true">
		<cfset var st = structNew()>
		<cfif structKeyExists(variables.instance.stTemplates[arguments.type],arguments.name)>
			<cfset st = duplicate(variables.instance.stTemplates[arguments.type][arguments.name])>
		<cfelse>		
			<cfset st = {href = arguments.name}>
		</cfif>
		<cfreturn st />
	</cffunction>

	<cffunction name="getDefaultTemplate" access="public" returntype="struct" hint="Returns the default template for the given type. If no template has been flagged as default, then returns the first one defined for that type.">
		<cfargument name="type" type="string" required="true">
		<cfset var t = variables.instance.stTemplates[arguments.type]>
		<cfset var td = variables.instance.stTemplateDefaults[arguments.type]>
		<cfreturn duplicate(t[td])>
	</cffunction>

	<cffunction name="getTemplateBody" access="public" returntype="string" hint="Returns the contents of the requested template. If name is missing or empty, then uses the default template for the given type. Template files are read only once whenever they are requested and then cached indefinetely for subsequent requests.">
		<cfargument name="type" type="string" required="true">
		<cfargument name="name" type="string" required="false" default="">
		<cfset var key = "">	
		<cfset var templateBody = "">
		<cfset var st = structNew()>
		<cfset var tmp = "">
			
		<cfif arguments.name eq "">
			<cfset st = getDefaultTemplate(arguments.type)>
		<cfelse>
			<cfset st = getTemplate(arguments.type, arguments.name)>
		</cfif>	
			
		<cfset key = arguments.type & "-" & arguments.name>	
			
		<cfif Not StructKeyExists(variables.stRenderTemplatesCache, key)>
			<cfif left(st.href,4) eq "http">
				<cfhttp url="#st.href#" result="tmp" resolveurl="true" />
				<cfset templateBody = tmp.fileContent>
			<cfelseif st.useHTTP>
				<cfscript>
					if(cgi.server_port_secure) tmpHREF = "https://"; else tmpHREF = "http://";
					tmpHREF = tmpHREF & cgi.server_name;
					if(cgi.server_port neq 80) tmpHREF = tmpHREF & ":" & cgi.server_port;
					if(left(st.href,1) neq "/") tmpHREF = tmpHREF & variables.appRoot;
					tmpHREF = tmpHREF & st.href;
				</cfscript>
				<cfhttp url="#tmpHREF#" result="tmp" />
				<cfset templateBody = tmp.fileContent>
			<cfelseif left(st.href,1) neq "/">
				<cffile action="read" file="#expandPath(variables.appRoot & st.href)#" variable="templateBody">
			<cfelse>
				<cffile action="read" file="#expandPath(st.href)#" variable="templateBody">
			</cfif>
			<cfset variables.stRenderTemplatesCache[key] = templateBody>
		<cfelse>
			<cfset templateBody = variables.stRenderTemplatesCache[key]>
		</cfif>

		<cfreturn templateBody>
	</cffunction>

	<cffunction name="getLayoutSections" access="public" returntype="string" hint="Returns a list with all the layout sections defined on the template with the given name. The template provided must be of type 'page'. If no template name is indicated then uses the default page template.">
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
			
			renderTemplateBody = getTemplateBody("page", arguments.pageTemplate);

			while(Not finished) {
				stResult = reFindNoCase(variables.tokenExprMap.layoutSection, renderTemplateBody, index, true);
				if(stResult.len[1] gt 0) {
					// match found
					token = mid(renderTemplateBody,stResult.pos[1],stResult.len[1]);
					arg1 = mid(renderTemplateBody,stResult.pos[2],stResult.len[2]);
					if(arrayLen(stResult.pos) gt 2)
						arg2 = mid(renderTemplateBody,stResult.pos[3],stResult.len[3]);
					else
						arg2 = "";
					lstSections = listAppend(lstSections,arg1);
					index = stResult.pos[1] + stResult.len[1];
				} else {
					finished = true;
				}
			}		
			
			return lstSections;
		</cfscript>
	</cffunction>

	<cffunction name="getTokenExprMap" access="public" returntype="struct" hint="Returns a key-value map containing all regular expressions used to match tokens on a template">
		<cfreturn variables.tokenExprMap />
	</cffunction>

	<cffunction name="setTokenExprMap" access="public" returntype="void" hint="Use this to override the default key-value map containing all regular expressions used to match tokens on a template">
		<cfargument name="data" type="struct" required="true">
		<cfset variables.tokenExprMap = arguments.data>
	</cffunction>
	
</cfcomponent>