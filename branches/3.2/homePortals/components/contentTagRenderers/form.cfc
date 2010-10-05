<cfcomponent extends="homePortals.components.contentTagRenderer" hint="Creates a simple form.">
	<cfproperty name="elements" type="string" required="true" displayname="The elements on the form">
	<cfproperty name="action" type="string">
	<cfproperty name="method" type="list" values="get,post">
	<cfproperty name="submitLabel" type="string">

	<cffunction name="renderContent" access="public" returntype="void" hint="sets the rendered output for the head and body into the corresponding content buffers">
		<cfargument name="headContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		<cfargument name="bodyContentBuffer" type="homePortals.components.singleContentBuffer" required="true">	
		
		<cfset var tmpHTML = "">
		<cfset var tgtHREF = "">
		<cfset var elements = getContentTag().getAttribute("elements")>
		<cfset var action = getContentTag().getAttribute("action",cgi.script_name)>
		<cfset var method = getContentTag().getAttribute("method", "post")>
		<cfset var submitLabel = getContentTag().getAttribute("submitLabel", "submit")>

		<cfsavecontent variable="tmpHTML">
			<cfoutput>
			<form method="#method#" action="#action#">
			<table>
				<cfloop list="#elements#" index="element">
					<cfif listLen(element,"|") gte 4>
						<cfset tmpName = listGetAt(element,1,"|")>
						<cfset tmpType = listGetAt(element,2,"|")>
						<cfset tmpLabel = listGetAt(element,3,"|")>
						<cfset tmpValue = listGetAt(element,4,"|")>
					<cfelseif listLen(element,"|") gte 3>
						<cfset tmpName = listGetAt(element,1,"|")>
						<cfset tmpType = listGetAt(element,2,"|")>
						<cfset tmpLabel = listGetAt(element,3,"|")>
						<cfset tmpValue = "">
					<cfelseif listLen(element,"|") eq 2>
						<cfset tmpName = listGetAt(element,1,"|")>
						<cfset tmpType = listGetAt(element,2,"|")>
						<cfset tmpLabel = tmpName>
						<cfset tmpValue = "">
					<cfelse>
						<cfset tmpName = element>
						<cfset tmpType = "text">
						<cfset tmpLabel = tmpName>
						<cfset tmpValue = "">
					</cfif>
					<tr>
						<td><b><label for="#tmpName#">#tmpLabel#:</label></b></td>
						<td>
							<cfswitch expression="#tmpType#">
								<cfcase value="textarea">
									<textarea name="#tmpName#" rows="3">#tmpValue#</textarea>
								</cfcase>
								<cfdefaultcase>
									<input type="#tmpType#" value="#tmpValue#" name="#tmpName#">
								</cfdefaultcase>
							</cfswitch>
							<cfif listLen(elements) eq 1>
								<input type="submit" value="#submitLabel#">
							</cfif>
						</td>
					</tr>
				</cfloop>
				<cfif listLen(elements) neq 1>
				<tr>
					<td colspan="2">
						<input type="submit" value="#submitLabel#">
					</td>
				</tr>
				</cfif>
			</table>
			</form>
			</cfoutput>
		</cfsavecontent>
		
		<cfset arguments.bodyContentBuffer.set( tmpHTML )>
	</cffunction>
		
</cfcomponent>