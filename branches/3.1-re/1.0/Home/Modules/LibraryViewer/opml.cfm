<cfsilent>

<!--- generates an OPML document with all resources in a given catalog --->

<cfparam name="index" default="1">

<cfset oModuleViewer = CreateObject("component","LibraryViewer")>
<cfset catalogCount = oModuleViewer.getCatalogCount()>
<cfif Not IsNumeric(index) or index gt catalogCount>
	<cfset index = 1>
</cfif>
<cfset stCatalog = oModuleViewer.getCatalog(index)>
<cfset lstResources = stCatalog.resourceList>

<cfxml variable="xmlDoc">
	<cfoutput>
		<opml>
			<head />
			<body>
				<cfloop list="#lstResources#" index="resType">
					<cfset qryRes = stCatalog[resType]>
					<cfif qryRes.recordCount gt 0>
						<outline text="#resType#" url="#index#/#resType#">
							<cfloop query="qryRes">
								<cfif resType eq "pages">
									<outline text="#title#" url="#index#/#resType#/#id#" />	
								<cfelse>
									<outline text="#id#" url="#index#/#resType#/#id#" />	
								</cfif>
							</cfloop>
						</outline>
					</cfif>
				</cfloop>
			</body>
		</opml>
	</cfoutput>
</cfxml>
</cfsilent>


<cfcontent type="text/xml" reset="true"><cfset writeOutput(toString(xmlDoc))>