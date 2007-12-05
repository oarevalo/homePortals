<!--- del.icio.us 

This module displays a list of del.icio.us bookmars
for the given user
--->
<cfcomponent displayname="google" extends="Home.Components.baseModule">

	<cfset variables.moduleName = "delicious">

	<cffunction name="renderHTMLHead" access="public" returntype="string" hint="overload this method to add module initialization code. The output of this method will be added to the HTML head section.">
		<cfsavecontent variable="tmpHead">
			<style type="text/css">
				###variables.id#_BodyRegion {
					padding:0px;
				}
				###variables.id# li {
					font-size:10px;
					border-bottom:1px solid silver;
					font-family:Arial, Helvetica, sans-serif;
					list-style-type:none;
					margin:0px;
					padding:1px;
				}
				###variables.id# li a {
					display:block;
					width:100%;
				}
				###variables.id# li a:hover {
					background-color:##CCCCCC;
					color:black;
					text-decoration:none;
				}
			</style>
		</cfsavecontent>
		<cfreturn tmpHead>
	</cffunction>


	<cffunction name="renderView" returntype="string">
		<cfset username = getPageSetting("username")>
		<cfset rssURL = "http://del.icio.us/rss/" & username>
		<cfhttp method="get" url="#rssURL#"></cfhttp>
		<cfset xmlDoc = XMLParse(cfhttp.FileContent)>
		<cfoutput>
			<cfsavecontent variable="tmpHTML">
				<cfset i=1>
				<cfset hasItem = ArrayLen(xmlDoc.xmlRoot.item) gte i>
				<cfloop condition="#hasItem#">
					<cfset thisItem = xmlDoc.xmlRoot.item[i]>
					<cfset tmpTitle = thisItem.title.xmlText>
					<li>
						<a href="#thisItem.link.xmlText#" target="_blank">#tmpTitle#</a>
					</li>
					<cfset i=i+1>
					<cfset hasItem = ArrayLen(xmlDoc.xmlRoot.item) gte i>
				</cfloop>
			</cfsavecontent>
		</cfoutput>
		<cfreturn tmpHTML>
	</cffunction>

</cfcomponent>