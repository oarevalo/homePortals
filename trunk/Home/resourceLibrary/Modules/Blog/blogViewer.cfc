<cfcomponent displayname="BlogViewer">

	<!-------------------------------------->
	<!--- getBlogInfo                    --->
	<!-------------------------------------->
	<cffunction name="getBlogInfo" access="public" output="false" returntype="struct">
		<cfargument name="xmlDoc" type="xml" required="true">
		<cfscript>
			var stBlogInfo = structNew();
			stBlogInfo.title = "";
			stBlogInfo.description = "";
			stBlogInfo.ownerEmail = "";
			stBlogInfo.url = "";			
			
			// get blog details
			if(StructKeyExists(arguments.xmlDoc.xmlRoot, "description")) stBlogInfo.description = arguments.xmlDoc.xmlRoot.description.xmlText;
			if(StructKeyExists(arguments.xmlDoc.xmlRoot.xmlAttributes, "title")) stBlogInfo.title = arguments.xmlDoc.xmlRoot.xmlAttributes.title;
			if(StructKeyExists(arguments.xmlDoc.xmlRoot.xmlAttributes, "ownerEmail")) stBlogInfo.ownerEmail = arguments.xmlDoc.xmlRoot.xmlAttributes.ownerEmail;
			if(StructKeyExists(arguments.xmlDoc.xmlRoot.xmlAttributes, "url")) stBlogInfo.url = arguments.xmlDoc.xmlRoot.xmlAttributes.url;
		</cfscript>
		<cfreturn stBlogInfo>
	</cffunction>

	<!-------------------------------------->
	<!--- saveBlogComment                --->
	<!-------------------------------------->	
	<cffunction name="saveBlogComment" access="public" output="false">
		<cfargument name="blog" type="string" required="true">
		<cfargument name="timestamp" type="string" required="true">
		<cfargument name="form" type="struct" required="true">
	
		<cfscript>
			var xmlDoc = 0;
			var aUpdateNode = 0;
	
			// get content store
			xmlDoc = xmlParse(expandpath(arguments.blog));
	
			// check if we find the entry the caller say we are updating
			aUpdateNode = xmlSearch(xmlDoc, "//entry[created='#arguments.timestamp#']");
	
			if(arguments.form.comment neq "" and arrayLen(aUpdateNode) gt 0) {
				if(arguments.form.name eq "") arguments.form.name = "Visitor";
				
				// create comment 
				xmlNode = xmlElemNew(xmlDoc,"comment");
				xmlNode.xmlText = xmlFormat(arguments.form.comment);
				xmlNode.xmlAttributes["postedByName"] = xmlFormat(arguments.form.name);
				xmlNode.xmlAttributes["postedByEmail"] = xmlFormat(arguments.form.email);
				xmlNode.xmlAttributes["postedOn"] = DateFormat(Now(),"yyyy-mm-dd") & "T" & TimeFormat(Now(),"HH:mm:ss");
	
				// check if comments branch exist
				if(Not structKeyExists(aUpdateNode[1], "comments")) {
					ArrayAppend(aUpdateNode[1].xmlChildren, xmlElemNew(xmlDoc,"comments"));
				}
				
				// add comment 
				ArrayAppend(aUpdateNode[1].comments.xmlChildren, xmlNode);
	
				saveBlog(arguments.blog, xmlDoc);
			}
		</cfscript>
	</cffunction>	

	<!-------------------------------------->
	<!--- processCodeBlocks              --->
	<!-------------------------------------->	
	<cffunction name="processCodeBlocks" access="public" output="false" returntype="string">
		<cfargument name="dataString" type="string" required="true">

		<cfset var counter = 0>
		<cfset var result = "">
		<cfset var codeblock = 0>
		<cfset var codeportion = "">
		<cfset var newbody = "">
		<cfset var txtContent = trim(arguments.dataString)>


		<cfif findNoCase("<code>",txtContent) and findNoCase("</code>",txtContent)>
			<cfset counter = findNoCase("<code>",txtContent)>
			<cfloop condition="counter gte 1">
                <cfset codeblock = reFindNoCase("(?s)(.*)(<code>)(.*)(</code>)(.*)",txtContent,1,1)> 
				<cfif arrayLen(codeblock.len) gte 6>
                    <cfset codeportion = mid(txtContent, codeblock.pos[4], codeblock.len[4])>
                    <cfif len(trim(codeportion))>
						<cfset result = renderColoredCode(codeportion, "BlogCodeBlock")>
					<cfelse>
						<cfset result = "">
					</cfif>
					<cfset newbody = mid(txtContent, 1, codeblock.len[2]) & result & mid(txtContent,codeblock.pos[6],codeblock.len[6])>
	
                    <cfset txtContent = newbody>
					<cfset counter = findNoCase("<code>",txtContent,counter)>
				<cfelse>
					<!--- bad crap, maybe <code> and no ender, or maybe </code><code> --->
					<cfset counter = 0>
				</cfif>
			</cfloop>
		</cfif>		
		<cfreturn txtContent>
	</cffunction>


	<!-------------------------------------->
	<!--- saveBlog                       --->
	<!-------------------------------------->	
	<cffunction name="saveBlog" access="private" output="false">
		<cfargument name="blog" type="string" required="true">
		<cfargument name="xmlDoc" type="xml" required="true">
		<cffile action="write"  file="#expandPath(arguments.blog)#" output="#toString(arguments.xmlDoc)#">
	</cffunction>
	
	<!-------------------------------------->
	<!--- renderColoredCode              --->
	<!-------------------------------------->		
	<cffunction name="renderColoredCode" output="false" returnType="string" access="private"
			   hint="Colors code">
		<cfargument name="dataString" type="string" required="true">
		<cfargument name="class" type="string" required="true">
	
		<cfset var data = trim(arguments.dataString) />
		<cfset var eof = 0>
		<cfset var bof = 1>
		<cfset var match = "">
		<cfset var orig = "">
		<cfset var chunk = "">
	
		<cfscript>
		/* Convert special characters so they do not get interpreted literally; italicize and boldface */
		data = REReplaceNoCase(data, '&([[:alpha:]]{2,});', '«strong»«em»&amp;\1;«/em»«/strong»', 'ALL');
	
		/* Convert many standalone (not within quotes) numbers to blue, ie. myValue = 0 */
		data = REReplaceNoCase(data, "(gt|lt|eq|is|,|\(|\))([[:space:]]?[0-9]{1,})", "\1«span style='color: ##0000ff'»\2«/span»", "ALL");
	
		/* Convert normal tags to navy blue */
		data = REReplaceNoCase(data, "<(/?)((!d|b|c(e|i|od|om)|d|e|f(r|o)|h|i|k|l|m|n|o|p|q|r|s|t(e|i|t)|u|v|w|x)[^>]*)>", "«span style='color: ##000080'»<\1\2>«/span»", "ALL");
	
		/* Convert all table-related tags to teal */
		data = REReplaceNoCase(data, "<(/?)(t(a|r|d|b|f|h)([^>]*)|c(ap|ol)([^>]*))>", "«span style='color: ##008080'»<\1\2>«/span»", "ALL");
	
		/* Convert all form-related tags to orange */
		data = REReplaceNoCase(data, "<(/?)((bu|f(i|or)|i(n|s)|l(a|e)|se|op|te)([^>]*))>", "«span style='color: ##ff8000'»<\1\2>«/span»", "ALL");
	
		/* Convert all tags starting with 'a' to green, since the others aren't used much and we get a speed gain */
		data = REReplaceNoCase(data, "<(/?)(a[^>]*)>", "«span style='color: ##008000'»<\1\2>«/span»", "ALL");
	
		/* Convert all image and style tags to purple */
		data = REReplaceNoCase(data, "<(/?)((im[^>]*)|(sty[^>]*))>", "«span style='color: ##800080'»<\1\2>«/span»", "ALL");
	
		/* Convert all ColdFusion, SCRIPT and WDDX tags to maroon */
		data = REReplaceNoCase(data, "<(/?)((cf[^>]*)|(sc[^>]*)|(wddx[^>]*))>", "«span style='color: ##800000'»<\1\2>«/span»", "ALL");
	
		/* Convert all inline "//" comments to gray (revised) */
		data = REReplaceNoCase(data, "([^:/]\/{2,2})([^[:cntrl:]]+)($|[[:cntrl:]])", "«span style='color: ##808080'»«em»\1\2«/em»«/span»", "ALL");
	
		/* Convert all multi-line script comments to gray */
		data = REReplaceNoCase(data, "(\/\*[^\*]*\*\/)", "«span style='color: ##808080'»«em»\1«/em»«/span»", "ALL");
	
		/* Convert all HTML and ColdFusion comments to gray */	
		/* The next 10 lines of code can be replaced with the commented-out line following them, if you do care whether HTML and CFML 
		   comments contain colored markup. */
	
		while(NOT EOF) {
			Match = REFindNoCase("<!--" & "-?([^-]*)-?-->", data, BOF, True);
			if (Match.pos[1]) {
				Orig = Mid(data, Match.pos[1], Match.len[1]);
				Chunk = REReplaceNoCase(Orig, "«(/?[^»]*)»", "", "ALL");
				BOF = ((Match.pos[1] + Len(Chunk)) + 38); // 38 is the length of the SPAN tags in the next line
				data = Replace(data, Orig, "«span style='color: ##808080'»«em»#Chunk#«/em»«/span»");
			} else EOF = 1;
		}
	
	
		/* Convert all quoted values to blue */
		data = REReplaceNoCase(data, """([^""]*)""", "«span style=""color: ##0000ff""»""\1""«/span»", "all");
	
		/* Convert left containers to their ASCII equivalent */
		data = REReplaceNoCase(data, "<", "&lt;", "ALL");
	
		/* Convert right containers to their ASCII equivalent */
		data = REReplaceNoCase(data, ">", "&gt;", "ALL");
	
		/* Revert all pseudo-containers back to their real values to be interpreted literally (revised) */
		data = REReplaceNoCase(data, "«([^»]*)»", "<\1>", "ALL");
	
		/* ***New Feature*** Convert all FILE and UNC paths to active links (i.e, file:///, \\server\, c:\myfile.cfm) */
		data = REReplaceNoCase(data, "(((file:///)|([a-z]:\\)|(\\\\[[:alpha:]]))+(\.?[[:alnum:]\/=^@*|:~`+$%?_##& -])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");
	
		/* Convert all URLs to active links (revised) */
		data = REReplaceNoCase(data, "([[:alnum:]]*://[[:alnum:]\@-]*(\.[[:alnum:]][[:alnum:]-]*[[:alnum:]]\.)?[[:alnum:]]{2,}(\.?[[:alnum:]\/=^@*|:~`+$%?_##&-])+)", "<a target=""_blank"" href=""\1"">\1</a>", "ALL");
	
		/* Convert all email addresses to active mailto's (revised) */
		data = REReplaceNoCase(data, "(([[:alnum:]][[:alnum:]_.-]*)?[[:alnum:]]@[[:alnum:]][[:alnum:].-]*\.[[:alpha:]]{2,})", "<a href=""mailto:\1"">\1</a>", "ALL");
		</cfscript>
	
		<!--- mod by ray --->
		<!--- change line breaks at end to <br /> 
		<cfset data = replace(data,chr(13),"<br />","all") />--->
		<!--- replace tab with 3 spaces --->
		<cfset data = replace(data,chr(9),"&nbsp;&nbsp;&nbsp;","all") />
		<cfset data = "<div class=""#arguments.class#"">" & data &  "</div>" />
		
		<cfreturn data>
	</cffunction>	
	

</cfcomponent>