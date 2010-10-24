<!--- This page displays the default error layout --->
<cfparam name="cfcatch" type="any" default="#structNew()#">
<cfparam name="cfcatch.type" default="">
<cfparam name="cfcatch.Message" default="">
<cfparam name="cfcatch.Detail" default="">

<cfif isDefined("exception")>
	<cfset cfcatch = exception>
</cfif>

<cfoutput>
	<div style="margin:10px;padding:10px;border:1px solid silver;background-color:##FFFF99;font-family:arial;font-size:11px;color:black;">
		<b>StartPage</b> - #loc['errors.errorPageIntro']#
		<br /><br />
		<div style="font-family:arial;font-size:11px;color:black;">
			<b>#cfcatch.Message#</b><br>
			#cfcatch.Detail#<br><br>
			
			<cfif StructKeyExists(cfcatch, "tagContext")>
				<cfloop from="1" to="#arrayLen(cfcatch.tagContext)#" index="i">
					<li>#cfcatch.tagContext[i].template# [line #cfcatch.tagContext[i].line#]
				</cfloop>
			</cfif>	
		</div>
	</div>
</cfoutput>
