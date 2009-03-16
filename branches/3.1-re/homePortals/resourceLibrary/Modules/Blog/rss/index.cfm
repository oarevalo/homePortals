<!-------------------------------------->
<!--- RSS                            --->
<!-------------------------------------->

<cfparam name="url.blog" default="">
<cfparam name="url.version" default="2">
<cfparam name="url.maxEntries" default="10" >

<cfset articles = "">
<cfset z = getTimeZoneInfo()>
<cfset header = "">
<cfset channel = "">
<cfset items = "">
<cfset dateStr = "">
<cfset rssStr = "">
<cfset utcPrefix = "">
<cfset rootURL = "">
<cfset cat = "">
<cfset endIndex = 1>
<cfset blogURL = "http://" & cgi.SERVER_NAME & cgi.SCRIPT_NAME>
<cfset stBlog = structNew()>

<cftry>
	<cfif url.blog eq "">
		<cfthrow message="No blog document has been indicated.">
	</cfif>
	
	<!--- open and parse blog xml --->
	<cfset xmlDoc = xmlParse(expandpath(blog))>
	
	<!--- get blog details --->
	<cfset stBlog.title = "">
	<cfset stBlog.description = "">
	<cfset stBlog.ownerEmail = "">
	<cfset stBlog.url = "">
	
	<cfif isDefined("xmlDoc.xmlRoot.description")>
		<cfset stBlog.description = xmlDoc.xmlRoot.description.xmlText>
	</cfif>
	<cfif StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "title")>
		<cfset stBlog.title = xmlDoc.xmlRoot.xmlAttributes.title>
	</cfif>
	<cfif StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "ownerEmail")>
		<cfset stBlog.ownerEmail = xmlDoc.xmlRoot.xmlAttributes.ownerEmail>
	</cfif>
	<cfif StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "url")>
		<cfset stBlog.url = xmlDoc.xmlRoot.xmlAttributes.url>
	</cfif>
	
	
	<!--- get posts --->
	<cfset aEntries = xmlSearch(xmlDoc, "//entry")>
	<cfif arrayLen(aEntries) gt maxEntries>
		<cfset endIndex = arrayLen(aEntries) - maxEntries + 1>
	<cfelse>
		<cfset endIndex = 1>
	</cfif>



	<cfoutput>
	<cfif url.version is 1>

		<cfsavecontent variable="header">
			<?xml version="1.0" encoding="iso-8859-1"?>
			<rdf:RDF 
				xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns##"
				xmlns:dc="http://purl.org/dc/elements/1.1/"
				xmlns="http://purl.org/rss/1.0/"
			>
		</cfsavecontent>

		<cfsavecontent variable="channel">
			<channel rdf:about="#xmlFormat(blogURL)#">
				<title>#xmlFormat(stBlog.title)#</title>
				<description>#xmlFormat(stBlog.description)#</description>
				<link>#xmlFormat(stBlog.url)#</link>
				<items>
					<rdf:Seq>
						<cfif ArrayLen(aEntries) gt 0>
							<cfloop from="#ArrayLen(aEntries)#" to="#endIndex#" index="i" step="-1">
								<rdf:li rdf:resource="#xmlFormat(makeLink(aEntries[i].created.xmlText))#" />
							</cfloop>
						</cfif>
					</rdf:Seq>
				</items>
			</channel>
		</cfsavecontent>

		<cfif not find("-", z.utcHourOffset)>
			<cfset utcPrefix = "-">
		<cfelse>
			<cfset z.utcHourOffset = right(z.utcHourOffset, len(z.utcHourOffset) -1 )>
			<cfset utcPrefix = "+">
		</cfif>
		
		<cfsavecontent variable="items">
			<cfif ArrayLen(aEntries) gt 0>
				<cfloop from="#ArrayLen(aEntries)#" to="#endIndex#" index="i" step="-1">
					<cfset dateStr = aEntries[i].created.xmlText & utcPrefix & numberFormat(z.utcHourOffset,"00") & ":00">
					<item rdf:about="#xmlFormat(makeLink(aEntries[i].created.xmlText))#">
						<title>#xmlFormat(aEntries[i].title.xmlText)#</title>
						<description>#xmlFormat(aEntries[i].content.xmlText)#</description>
						<link>#xmlFormat(makeLink(aEntries[i].created.xmlText))#</link>
						<dc:date>#dateStr#</dc:date>
					</item>
				</cfloop>
			</cfif>
		</cfsavecontent>

		<cfset rssStr = trim(header & channel & items & "</rdf:RDF>")>
		
	<cfelseif url.version eq "2">
	
		<cfset rootURL = reReplace(blogURL, "(.*)/index.cfm", "\1")>

		<cfsavecontent variable="header">
		<rss version="2.0">
		<channel>
		<title>#xmlFormat(stBlog.title)#</title>
		<link>#xmlFormat(stBlog.url)#</link>
		<description>#xmlFormat(stBlog.description)#</description>
		<language>#GetLocale()#</language>
		<pubDate>#dateFormat(Now(),"ddd, dd mmm yyyy") & " " & timeFormat(Now(),"HH:mm:ss") & " -" & numberFormat(z.utcHourOffset,"00") & "00"#</pubDate>
		<lastBuildDate>{LAST_BUILD_DATE}</lastBuildDate>
		<generator>HomePortalBlog</generator>
		<docs>http://blogs.law.harvard.edu/tech/rss</docs>
		<managingEditor>#xmlFormat(stBlog.ownerEmail)#</managingEditor>
		<webMaster>#xmlFormat(stBlog.ownerEmail)#</webMaster>
		</cfsavecontent>
	
		<cfsavecontent variable="items">
			<cfif ArrayLen(aEntries) gt 0>
				<cfloop from="#ArrayLen(aEntries)#" to="#endIndex#" index="i" step="-1">
					<cfset posted = aEntries[i].created.xmlText>
					<cfset tmpDate = ListFirst(posted, "T")>
					<cfset tmpTime = ListLast(posted, "T")>
					<cfset dateStr = dateFormat(tmpDate,"ddd, dd mmm yyyy") & " " & timeFormat(tmpTime,"HH:mm:ss") & " -" & numberFormat(z.utcHourOffset,"00") & "00">
					<item>
						<title>#xmlFormat(aEntries[i].title.xmlText)#</title>
						<link>#xmlFormat(makeLink(aEntries[i].created.xmlText))#</link>
						<description>
						<!--- Regex operation removes HTML code from blog body output 
						#xmlFormat(REReplace(aEntries[i].content.xmlText,"<[^>]*>","","All"))#--->
						#xmlFormat(aEntries[i].content.xmlText)#
						</description>
						<pubDate>#dateStr#</pubDate>
						<guid>#xmlFormat(makeLink(aEntries[i].created.xmlText))#</guid>
					</item>
				</cfloop>
			</cfif>
		</cfsavecontent>
	
		<cfif ArrayLen(aEntries) gt 0>
			<cfset lastPostDate = aEntries[1].created.xmlText>
		<cfelse>
			<cfset lastPostDate = "">
		</cfif>
		<cfset tmpDate = ListFirst(lastPostDate, "T")>
		<cfset tmpTime = ListLast(lastPostDate, "T")>
		<cfset header = replace(header,'{LAST_BUILD_DATE}','#dateFormat(tmpDate,"ddd, dd mmm yyyy") & " " & timeFormat(tmpTime,"HH:mm:ss") & " -" & numberFormat(z.utcHourOffset,"00") & "00"#','one')>
		<cfset rssStr = trim(header & items & "</channel></rss>")>
	</cfif>
	</cfoutput>

	<cfcontent type="text/xml"><cfoutput>#rssStr#</cfoutput>

	<cfcatch type="any">
		<cfoutput>#cfcatch.Message#</cfoutput>
	</cfcatch>
</cftry>


<!-------------------------------------->
<!--- makeLink                       --->
<!-------------------------------------->
<cffunction name="makeLink" access="private" returnType="string" output="false"
			hint="Generates links for an entry.">
	<cfargument name="entryid" type="any" required="true">

	<cfset var retVar = "">
	<cfset var blogURL = "http://" & cgi.SERVER_NAME & getDirectoryFromPath(cgi.SCRIPT_NAME)>
	
	<cfset retVar = blogURL & "../?blog=" & blog & "&timestamp=" & arguments.entryID>
	
	<cfreturn retVar>
</cffunction>