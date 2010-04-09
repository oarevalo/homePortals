<cfcomponent extends="homePortals.components.contentTagRenderer"
			 hint="This content renderer displays a simple navigation menu.">
	<cfproperty name="direction" default="horizontal" type="list" values="Horizontal,Vertical">
	<cfproperty name="pages" default="" type="string" hint="List of pages to display on the menu. If empty, includes all pages at the root level. You can use the format: page|title to provide a custom nav title for each page.">
	<cfproperty name="bgcolor" default="##ccc" type="string" displayname="Background color">
	<cfproperty name="fontcolor" default="##000" type="string" displayname="Font color">


	<!---------------------------------------->
	<!--- renderContent	                   --->
	<!---------------------------------------->		
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
		<cfset var direction = getContentTag().getAttribute("direction")>
		<cfset var pages = getContentTag().getAttribute("pages")>
		<cfset var thisPageHREF = trim(getPageRenderer().getPageHREF())>
		<cfset var bgcolor = getContentTag().getAttribute("bgcolor","##ccc")>
		<cfset var fontcolor = getContentTag().getAttribute("fontcolor","##000")>
		<cfset var tmpCSS = "">
		<cfset var thisFolder = "/">
		<cfset var qryPages = 0>
		<cfset var pp = getPageRenderer().getHomePortals().getPageProvider()>

		<cfif listLen(thisPageHREF,"/") gt 1>
			<cfset thisFolder = listDeleteAt(thisPageHREF,listLen(thisPageHREF,"/"),"/") & "/">
		</cfif>
		
		<cfif pages eq "">
			<cfset qryPages = pp.listFolder(thisFolder)>
			
			<cfquery name="qryPages" dbtype="query">
				SELECT name, UPPER(name) as name_u
					FROM qryPages
					ORDER BY name_u
			</cfquery>
			
			<cfloop query="qryPages">
				<cfset pages = listAppend(pages,thisFolder & qryPages.name)>
			</cfloop>
		</cfif>
		
		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<div class="navMenu_container" <cfif bgcolor neq "">style="background-color:#bgcolor#;"</cfif>>
					<cfif direction eq "Vertical">
						<table> 
							<cfloop list="#pages#" index="page">
								<cfset tmpCSSClass = "">
								<cfif fontcolor neq "">
									<cfset tmpCSS = "color:#fontcolor#;">
								</cfif>
								<cfif listLen(page,"|") gt 1>
									<cfset href = listFirst(page,"|")>
									<cfset label = listLast(page,"|")>
								<cfelse>
									<cfset href = page>
									<cfset label = listLast(page,"/")>
								</cfif>
								<cfif left(href,1) neq "/">
									<cfset href = "/" & href>
								</cfif>
								<cfif href eq thisPageHREF>
									<cfset tmpCSSClass = "navMenu_selectedItem">
								</cfif>
								<tr><td style="padding-top:0px;"><a href="#cgi.SCRIPT_NAME#?page=#href#" <cfif tmpCSS neq "">style="#tmpCSS#"</cfif> <cfif tmpCSSClass neq "">class="#tmpCSSClass#"</cfif>>#label#</a></td></tr>
							</cfloop>
						</table>
					<cfelse>
						<table> 
							<tr>
								<cfloop list="#pages#" index="page">
									<cfset tmpCSSClass = "">
									<cfif fontcolor neq "">
										<cfset tmpCSS = "color:#fontcolor#;">
									</cfif>
									<cfif listLen(page,"|") gt 1>
										<cfset href = listFirst(page,"|")>
										<cfset label = listLast(page,"|")>
									<cfelse>
										<cfset href = page>
										<cfset label = listLast(page,"/")>
									</cfif>
									<cfif left(href,1) neq "/">
										<cfset href = "/" & href>
									</cfif>
									<cfif href eq thisPageHREF>
										<cfset tmpCSSClass = "navMenu_selectedItem">
									</cfif>
									<td><a href="#cgi.SCRIPT_NAME#?page=#href#" <cfif tmpCSS neq "">style="#tmpCSS#"</cfif> <cfif tmpCSSClass neq "">class="#tmpCSSClass#"</cfif>>#label#</a></td>
								</cfloop>
							</tr>
						</table>
					</cfif>
				</div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>
	</cffunction>	
	
	<cffunction name="renderCSS"  access="private" returntype="string">
		<cfset var tmpHTML = "">
		<cfset var bgcolor = getContentTag().getAttribute("bgcolor","##ccc")>
		<cfset var fontcolor = getContentTag().getAttribute("fontcolor","##000")>
		
		<cfsavecontent variable="tmpHTML">
			<cfoutput>
				<style type="text/css">
					.navMenu_container td {
						padding:5px;
						padding-right:10px;
						border-right:1px solid #fontcolor#;
					}
					.navMenu_selectedItem {
						font-weight:bold;
					}
				</style>
			</cfoutput>
		</cfsavecontent>

		<cfreturn tmpHTML>	
	</cffunction>
	
</cfcomponent>