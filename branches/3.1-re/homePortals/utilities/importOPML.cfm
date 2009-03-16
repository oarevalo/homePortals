<cfparam name="action" default="">
<cfparam name="opml" default="">
<cfparam name="resourceLibraryRoot" default="">
<cfparam name="owner" default="">
<cfparam name="accessType" default="">
<cfparam name="packageName" default="">
<cfparam name="replacePackage" default="false">

<cfset lstAccessTypes = "general,owner,friend">

<cfoutput>
<html>
	<head>
		<title>HomePortals - Import OPML</title>
	</head>
	<body>
		<h1>Import OPML</h1>
		
		<p>
			This tool imports rss feeds from an OPML document and create them as resources.
		</p>
		
		<form name="frm" method="post" action="#cgi.SCRIPT_NAME#"> 
			
			OPML Document: 
			<input type="text" name="opml" value="#opml#"><br>
			Resource Library Root: 
			<input type="text" name="resourceLibraryRoot" value="#resourceLibraryRoot#"><br>
			Owner:
			<input type="text" name="owner" value="#owner#"><br>
			Access Type:
				<cfloop list="#lstAccessTypes#" index="item">
					<input type="radio" name="accessType" value="#item#"> #item#  &nbsp;&nbsp;&nbsp;&nbsp;
				</cfloop><br>
			Package Name:
			<input type="text" name="packageName" value="#packageName#"><br>
			Replace Existing Package Contents?:
			<input type="checkbox" name="replacePackage" value="true"><br>

			<input type="submit" name="action" value="Go">
		</form>
		<hr>

		<cfif action eq "Go">
		
			<!--- remove existing package if requested --->
			<cfif replacePackage>
				<cfset pkgDescHREF = resourceLibraryRoot & "/feeds/" & packageName & "/info.xml">
				<cfif fileExists(expandPath(pkgDescHREF))>
					<cffile action="delete" file="#expandPath(pkgDescHREF)#">
					Existing file descriptor deleted...<br>
				</cfif>
			</cfif>
		
			<cfset oResourceLibrary = createObject("component","homePortals.components.resourceLibrary").init(resourceLibraryRoot)>
			<cfset xmlDoc = xmlParse(opml)>
			<cfset aNodes = xmlDoc.xmlRoot.body.xmlChildren>			
			
			<cfloop from="1" to="#arrayLen(aNodes)#" index="i">
				<b>#aNodes[i].xmlAttributes.text#....</b>
				
				<cftry>
					<cfscript>
						// remove any invalid characters from the id
						id = createUUID();
						
						// create the bean for the new resource
						oResourceBean = createObject("component","homePortals.components.resourceBean").init();	
						oResourceBean.setID(id);
						oResourceBean.setName(aNodes[i].xmlAttributes.text);
						oResourceBean.setHREF(aNodes[i].xmlAttributes.xmlURL);
						oResourceBean.setOwner(owner);
						oResourceBean.setAccessType(accessType); 
						oResourceBean.setDescription(aNodes[i].xmlAttributes.description); 
						oResourceBean.setPackage(packageName); 
						oResourceBean.setType("feed"); 
		
						/// add the new resource to the library
						oResourceLibrary.saveResource(oResourceBean);
					</cfscript>
					OK
					<Cfcatch type="any">
						#cfcatch.message#
					</Cfcatch>
				</cftry>
				<br>
			</cfloop>
						
		</cfif>		
		
	</body>
</html>
</cfoutput>
		