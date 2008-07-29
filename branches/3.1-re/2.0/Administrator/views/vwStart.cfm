<cfset qryAccounts = getValue("qryAccounts")>
<cfset accountsRoot = getValue("accountsRoot")>
<cfset stFeed = getValue("stFeed")>
<cfset trialExpirationDate = getValue("trialExpirationDate","")>

<h2>Welcome To the HomePortals Administrator!</h2>

<cfif trialExpirationDate neq "">
	<p class="trialText">
		Your HomePortals Trial will expire on <cfoutput>#trialExpirationDate#</cfoutput>.
	</p>
</cfif>

<p class="introText">
	The HomePortals Administrator is a management application that allows you to manage your
	current installation of the HomePortals Portal Server. From here you are able to manage
	the HomePortals configuration and settings, manage accounts, create new accounts, 
	manipulate account sites and pages, and update the module library.
</p>
<p class="introText">
	Here you will also find the latest HomePortals news and announcements, and see the latest
	HomePortals accounts created on this server.
</p>

<table width="100%">
	<tr valign="top">
		<td>
			<h2 style="margin-top:0px;">HomePortals News</h2>
			<ul class="home_rssfeed">
				<cftry>
					<cfif isStruct(stFeed)>
						<cfoutput>
							<cfloop from="1" to="#arrayLen(stFeed.items)#" index="i">
								<cfset xmlItem = stFeed.items[i]>
								<li><a href="#xmlItem.link.xmlText#">#xmlItem.title.xmlText#</a> posted on #xmlItem.pubdate.xmlText#</li>
							</cfloop>
						</cfoutput>
					<cfelse>
						<li>HomePortals RSS feed could not be read. The RSS Feed may be offline, or there may
						be a problem with the server's connection to the Internet.</li>
					</cfif>
					<cfcatch type="any">
						<cfoutput>
							<li>A problem ocurred while displaying the RSS Feed. [#cfcatch.message#]</li>
						</cfoutput>
					</cfcatch>
				</cftry>
			</ul>
		</td>
		<td style="width:150px;">
			<div class="cp_sectionTitle" style="width:200px;padding:0px;margin-bottom:0px;">
				<div style="margin:2px;">
					<img src="images/status_online.png" align="absmiddle"> Recent Accounts
				</div>
			</div>
			<div class="cp_sectionBox" style="margin-top:0px;padding:0px;margin-bottom:0px;width:200px;border-top:0px;">
				<div style="margin:5px;">
				<cfif isQuery(qryAccounts)>
					<cfoutput query="qryAccounts" maxrows="10">
						<li>
							[#DateFormat(createDate,"mm/dd/yy")#] 
							<a href="#accountsRoot#/#Username#">#Username#</a>
							[<a href="?event=ehAccounts.doSetAccount&UserID=#userID#">Edit</a>]
						</li>
					</cfoutput>
					
					<cfif qryAccounts.recordCount eq 0>
						<em>There are no accounts yet.</em>
					</cfif>
				<cfelse>
					<em>HomePortals Accounts have not been setup properly.</em>
				</cfif>
				</div>
			</div>	
			
			<br>
			<div class="cp_sectionTitle" style="width:200px;padding:0px;margin-bottom:0px;">
				<div style="margin:2px;">
					Reset HomePortals
				</div>
			</div>
			<div class="cp_sectionBox" style="margin-top:0px;padding:0px;margin-bottom:0px;width:200px;border-top:0px;">
				<div style="margin:5px;text-align:center;">
					Click this button to reset the HomePortals application.<br><br>
					<input type="button" 
						   name="btnRestart" 
						   onclick="document.location='?event=ehGeneral.doResetHomePortals'"
						   value="Reset HomePortals">
					<br><br>
				</div>
			</div>	
		</td>
	</tr>
</table>