<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="This content renderer displays a simple navigation menu.">
	<cfproperty name="type" default="horizontal" type="list" values="Horizontal,Vertical,Plain" hint="Indicates the type of menu to display. Use 'Plain' to render the menu as an unstyled list.">
	<cfproperty name="pages" default="" type="string" hint="List of pages to display on the menu. If empty, includes all pages in the current folder. You can use the format: page|title to provide a custom nav title for each page.">
	<cfproperty name="folder" default="" type="string" hint="Use this attribute to list all pages on the given folder. This is only used if the 'pages' argument is empty.">
	<cfproperty name="exclude" default="" type="string" hint="List of pages to exclude from the menu. This only takes effect when the 'pages' argument is empty.">
	<cfproperty name="fontcolor" default="##fff" type="string" displayname="Font color" hint="Used to indicate the font color on the menu items. Only used for 'Horizontal' and 'Vertical' list types. To fall back to the current page's style, use 'none'.">
	<cfproperty name="bgcolor" default="##036" type="string" displayname="BG color" hint="Used to indicate the background color on the menu items. Only used for 'Horizontal' and 'Vertical' list types. To fall back to the current page's style, use 'none'.">
	<cfproperty name="hovercolor" default="##369" type="string" displayname="Hover color" hint="Used to indicate the background color on the menu items when hovering over them. Only used for 'Horizontal' and 'Vertical' list types. To fall back to the current page's style, use 'none'.">
	<cfproperty name="pageHREF" type="string" hint="Use this field to provide the format for the page URLs on the menu. To indicate the page name of the selected item, use the token %pageName. By default is '?page=%pageName'" />

	<cfset variables.DEFAULT_PAGE_HREF = "?page=%pageName">
	<cfset variables.DEFAULT_TYPE = "horizontal">
	<cfset variables.DEFAULT_BGCOLOR = "##036">
	<cfset variables.DEFAULT_HOVERCOLOR = "##369">
	<cfset variables.DEFAULT_FONTCOLOR = "##fff">
	<cfset variables.NO_CSS_TYPE = "plain">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">

		<cfscript>
			var moduleID = getContentTag().getAttribute("id");

			try {
				arguments.headContentBuffer.set( renderCSS() );
				arguments.bodyContentBuffer.set( renderMenu() );
				
			} catch(any e) {
				tmpHTML = "<b>An unexpected error ocurred while processing module #moduleID#.</b><br><br><b>Message:</b> #e.message# #e.detail#";
				arguments.bodyContentBuffer.set( tmpHTML );
			}
		</cfscript>
	</cffunction>

	<cffunction name="renderMenu" access="private" returntype="string" >
		<cfset var tmpHTML = "">
		<cfset var type = getContentTag().getAttribute("type",variables.DEFAULT_TYPE)>
		<cfset var pages = getContentTag().getAttribute("pages")>
		<cfset var folder = getContentTag().getAttribute("folder")>
		<cfset var exclude = getContentTag().getAttribute("exclude")>
		<cfset var itemHREFMask = getContentTag().getAttribute("pageHREF",variables.DEFAULT_PAGE_HREF)>
		<cfset var thisPageHREF = trim(getPageRenderer().getPageHREF())>
		<cfset var thisFolder = "/">
		<cfset var qryPages = 0>
		<cfset var pp = getPageRenderer().getHomePortals().getPageProvider()>

		<cfif listLen(thisPageHREF,"/") gt 1>
			<cfset thisFolder = listDeleteAt(thisPageHREF,listLen(thisPageHREF,"/"),"/") & "/">
		</cfif>
		
		<cfif pages eq "" and folder neq "">
			<cfset thisFolder = folder>
			<cfif left(thisFolder,1) neq "/">
				<cfset thisFolder = thisFolder & "/">
			</cfif>
		</cfif>
		
		<cfif pages eq "">
			<cfset qryPages = pp.listFolder(thisFolder)>
			
			<cfquery name="qryPages" dbtype="query">
				SELECT name, UPPER(name) as name_u
					FROM qryPages
					WHERE type NOT LIKE 'folder'
					<cfif exclude neq "">
						AND name not in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#exclude#" list="true">)
					</cfif>
					ORDER BY name_u
			</cfquery>
			
			<cfloop query="qryPages">
				<cfset pages = listAppend(pages,thisFolder & qryPages.name)>
			</cfloop>
		</cfif>

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<ul>
					<cfloop list="#pages#" index="page">
						<cfif listLen(page,"|") gt 1>
							<cfset href = listFirst(page,"|")>
							<cfset label = listLast(page,"|")>
						<cfelse>
							<cfset href = page>
							<cfset label = listLast(page,"/")>
						</cfif>
						<cfif left(href,1) eq "/">
							<cfset href = right(href,len(href)-1)>
						</cfif>
						<cfset itemHREF = replaceNoCase(itemHREFMask,"%pageName",urlEncodedFormat(href),"ALL")>
						<li><a href="#itemHREF#" <cfif href eq thisPageHREF>class="navMenu_selectedItem"</cfif>>#label#</a></li>
					</cfloop>
				</ul>
				<br style="clear:both;" />
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	
	
	<cffunction name="renderCSS"  access="private" returntype="string">
		<cfset var tmpHTML = "">
		<cfset var id = getContentTag().getAttribute("id")>
		<cfset var type = getContentTag().getAttribute("type", variables.DEFAULT_TYPE)>
		<cfset var bgcolor = getContentTag().getAttribute("bgcolor", variables.DEFAULT_BGCOLOR)>
		<cfset var hovercolor = getContentTag().getAttribute("hovercolor", variables.DEFAULT_HOVERCOLOR)>
		<cfset var fontcolor = getContentTag().getAttribute("fontcolor", variables.DEFAULT_FONTCOLOR)>
		
		<cfif type eq "" or type eq variables.NO_CSS_TYPE>
			<cfreturn tmpHTML>
		</cfif>
		
		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<cfswitch expression="#type#">
					<cfcase value="horizontal">
						<style type="text/css">
							/* *** Style declarations for NavMenu tag ***/
							###id# ul {
								padding-left: 0;
								margin-left: 0;
								<cfif bgcolor neq "none">
									background-color: #bgcolor#;
								</cfif>
								<cfif fontcolor neq "none">
									color: #fontcolor#;
								</cfif>
								float: left;
								width: 100%;
								font-family: arial, helvetica, sans-serif;
							}
							###id# ul li { display: inline; }
							###id# ul li a {
								padding: 0.2em 1em;
								<cfif bgcolor neq "none">
									background-color: #bgcolor#;
								</cfif>
								<cfif fontcolor neq "none">
									color: #fontcolor#;
								</cfif>
								text-decoration: none;
								float: left;
								<cfif fontcolor neq "none">
									border-right: 1px solid #fontcolor#;
								</cfif>
							}
							###id# ul li a:hover {
								<cfif hovercolor neq "none">
									background-color: #hovercolor#;
								</cfif>
								<cfif fontcolor neq "none">
									color: #fontcolor#;
								</cfif>
							}
							###id# .navMenu_selectedItem {
								<cfif hovercolor neq "none">
									background-color: #hovercolor#;
								</cfif>
							}		
						</style>
					</cfcase>
					<cfcase value="vertical">
						<style type="text/css">
							###id# ul {
								margin-left: 0;
								padding-left: 0;
								list-style-type: none;
								font-family: Arial, Helvetica, sans-serif;
							}
							###id# a {
								display: block;
								padding: 3px;
								<cfif bgcolor neq "none">
									background-color: #bgcolor#;
								</cfif>
								<cfif fontcolor neq "none">
									border-bottom: 1px solid  #fontcolor#;
								</cfif>
							}
							###id# a:link, ###id# a:visited {
								<cfif fontcolor neq "none">
									color: #fontcolor#;
								</cfif>
								text-decoration: none;
							}
							###id# a:hover {
								<cfif hovercolor neq "none">
									background-color: #hovercolor#;
								</cfif>
								<cfif fontcolor neq "none">
									color: #fontcolor#;
								</cfif>
							}
							###id# .navMenu_selectedItem {
								<cfif hovercolor neq "none">
									background-color: #hovercolor#;
								</cfif>
							}		
						</style>
					</cfcase>
				</cfswitch>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>	
	</cffunction>
	
</cfcomponent>