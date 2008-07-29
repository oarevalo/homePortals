<!--- BookMarks.cfm
This module displays an outline of links and resources indicated
by an OPML document
version: 1.2

Changelog:
- 2/24/06 - added "followLink" attribute
		  - misc fixes and bugs
		  - removed "Edit" attribute and link to HomeEdit
		  - removed local error handling to fallback into HomePortals error handling
- 2/28/06 - changed errors raised when file does not exist or is not xml
			to display a message and exit the module instead of raising
			a framework error.
--->


<!--- Init variables and Params --->
<cfparam name="attributes.Module" default="#StructNew()#">
<cfparam name="Attributes.Module.XMLAttributes.url" default="">
<cfparam name="Attributes.Module.XMLAttributes.followLink" default="true">

<cfset thisURL = Attributes.Module.XMLAttributes.URL>
<cfset thisFollowLink = Attributes.Module.XMLAttributes.followLink>

<!--- make sure followLink is a boolean --->
<cfif thisFollowLink eq "" or Not IsBoolean(thisFollowLink)>
	<cfset thisFollowLink = true>
</cfif>


<!--- check that the path is not empty --->
<cfif thisURL eq "">
	<p>
		<cfoutput>
			Use the <a href="javascript:controlPanel.editModule('#Attributes.moduleID#')">Settings Page</a> to enter 
			the URL where your bookmarks are stored.<br /><br />
			The bookmarks must be stored in OPML format.<br /><br />
			To create your own bookmarks list that you can modify,
			use the Bookmarks2 module.
		</cfoutput>
	</p>	
	<cfexit>
</cfif>

<!--- open xml --->
<cftry>
	<cfif left(thisURL,4) eq "http">
		<cfhttp method="get" url="#thisURL#" throwonerror="yes"></cfhttp>
		<cfset txtDoc = cfhttp.FileContent>
	<cfelse>
		<cffile action="read" file="#expandpath(thisURL)#" variable="txtDoc">
	</cfif> 
	<cfcatch type="any">
		<cfoutput>
			<p>
				An error ocurred while opening the requested file [<a href="#thisURL#" target="_blank">#thisURL#</a>].<br>
				The given document does not exist.
			</p>
		</cfoutput>
		<cfexit>
	</cfcatch>
</cftry>

<!--- check that the given file is a valid xml --->
<cfif not IsXML(txtDoc)>
	<cfoutput>
		<p>
			An error ocurred while opening the requested file [<a href="#thisURL#" target="_blank">#thisURL#</a>]. <br>
			The given document is not valid xml.
		</p>
	</cfoutput>
	<cfexit>
<cfelse>
	<cfset xmlDoc = xmlParse(txtDoc)>
</cfif>
	
<style>
	#Bookmarks {
		font-size:11px;
		font-family:arial;
		text-align:left;
	}
	#Bookmarks ul {
		margin-left:0px;
		margin-bottom:10px;
		padding:0px;
		list-style-type:none;
	}
	#Bookmarks li {
		margin:0px;
		padding:0px;
	}
	#Bookmarks a {
		display:block;
		width:100%;
		text-decoration:none;
		padding:3px;
		border:1px solid #e5e5e5;
	}
	#Bookmarks a:hover {
		border:1px solid #999999;
		background-color:#E7F8FE;
		text-decoration:none;
	}
</style>
	
	
<cfoutput>
	<cfset aGroups = xmlSearch(xmlDoc,"//body/*")>
	<div id="Bookmarks">
	<ul>
		<cfloop from="1" to="#ArrayLen(aGroups)#" index="i">
			<cfset aLinks = aGroups[i].XMLChildren>
			
			<cfset thisAttribs = aGroups[i].XMLAttributes>
			<cfparam name="thisAttribs.text" default="" type="string">
			<cfparam name="thisAttribs.url" default="##" type="string">
			<cfparam name="thisAttribs.target" default="" type="string">
			<cfparam name="thisAttribs.onclick" default="" type="string">
			<cfparam name="thisAttribs.type" default="link" type="string">
			<cfparam name="thisAttribs.htmlURL" default="#thisAttribs.url#" type="string">
			<cfparam name="thisAttribs.xmlURL" default="" type="string">
	
			<cfset thisItem = thisAttribs.text>

			<cfif thisAttribs.htmlURL eq "">
				<cfset thisAttribs.htmlURL = thisAttribs.url>
			</cfif>	
	
			<cfif thisAttribs.xmlURL neq "" and (thisAttribs.type eq "rss" or thisAttribs.type eq "atom")>
				<cfset tmpURL = thisAttribs.xmlURL>
			<cfelse>
				<cfset tmpURL = thisAttribs.htmlURL>
			</cfif>
	
			<cfset tmpEvent = "h_raiseEvent('bookmarks','onClick','#tmpURL#')">
			<cfset thisAttribs.onclick = ListAppend(thisAttribs.onclick, tmpEvent, ";")>					

			<cfif Not thisFollowLink>
				<cfset thisAttribs.url = "##">
			</cfif>
				
			<li><a href="#URLDecode(thisAttribs.url)#" 
					target="#thisAttribs.target#" 
					onClick="#thisAttribs.onclick#"><strong>&nbsp;#thisItem#</strong></a></li>

			<cfif IsArray(aLinks)>
				<ul>
					<cfloop from="1" to="#ArrayLen(aLinks)#" index="j">
						<cfset thisSubItem = aLinks[j].XMLAttributes>
						<cfparam name="thisSubItem.url" default="##" type="string">
						<cfparam name="thisSubItem.target" default="" type="string">
						<cfparam name="thisSubItem.text" default="" type="string">
						<cfparam name="thisSubItem.onclick" default="" type="string">
						<cfparam name="thisSubItem.type" default="link" type="string">
						<cfparam name="thisSubItem.htmlURL" default="#thisSubItem.url#" type="string">
						<cfparam name="thisSubItem.xmlURL" default="" type="string">
	
						<cfif thisSubItem.xmlURL neq "" and (thisSubItem.type eq "rss" or thisSubItem.type eq "atom")>
							<cfset tmpURL = thisSubItem.xmlURL>
						<cfelse>
							<cfset tmpURL = thisSubItem.htmlURL>
						</cfif>
	
						<cfset tmpEvent = "h_raiseEvent('bookmarks','onClick','#tmpURL#')">
						<cfset thisSubItem.onclick = ListAppend(thisSubItem.onclick, tmpEvent, ";")>					
						
						<cfif Not thisFollowLink>
							<cfset thisSubItem.url = "##">
						</cfif>
									
						<li><a href="#URLDecode(thisSubItem.url)#" 
								target="#thisSubItem.target#" 
								onClick="#thisSubItem.onclick#">&nbsp;#URLDecode(thisSubItem.text)#</a></li>
					</cfloop>
				</ul>
			</cfif>
		</cfloop>
	</ul>
	</div>
</cfoutput>



