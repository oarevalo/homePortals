<cfsilent>

<!--- generates an OPML document with all content entries in a given storage document --->

<cfparam name="owner" default="">
<cfparam name="storageURL" default="">

<cfset oStorage = CreateObject("component","contentStorage")>
<cfset oStorage.init(owner, storageURL, true)>
<cfset qryIndex = oStorage.getIndex()>

<cfxml variable="xmlDoc">
	<cfoutput>
		<opml>
			<head />
			<body>
				<cfloop query="qryIndex">
					<outline text="#qryIndex.id#" url="#qryIndex.id#" />
				</cfloop>
			</body>
		</opml>
	</cfoutput>
</cfxml>
</cfsilent>


<cfcontent type="text/xml" reset="true"><cfset writeOutput(toString(xmlDoc))>