<!--- del.icio.us 

This module displays a list of del.icio.us bookmars
for the given user
--->

<cfset tmpAttr = Attributes.Module.xmlAttributes>

<cfparam name="tmpAttr.username" default="">

<cftry>
<cfset rssURL = "http://del.icio.us/rss/" & tmpAttr.username>
<cfhttp method="get" url="#rssURL#"></cfhttp>
<cfset xmlDoc = XMLParse(cfhttp.FileContent)>

<cfoutput>
<cfsavecontent variable="tmpHead">
	<style type="text/css">
		###Attributes.moduleID#_BodyRegion {
			padding:0px;
		}
		###Attributes.moduleID# li {
			font-size:10px;
			border-bottom:1px solid silver;
			font-family:Arial, Helvetica, sans-serif;
			list-style-type:none;
			margin:0px;
			padding:1px;
		}
		###Attributes.moduleID# li a {
			display:block;
			width:100%;
		}
		###Attributes.moduleID# li a:hover {
			background-color:##CCCCCC;
			color:black;
			text-decoration:none;
		}
	</style>
</cfsavecontent>
<cfhtmlhead text="#tmpHead#">

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
</cfoutput>

<cfcatch type="any">
	<cfoutput>
	Error retrieving feed: #rssURL#<br>
	#cfcatch.Message#<br>
	#cfcatch.Detail#
	</cfoutput>
</cfcatch>
</cftry>
