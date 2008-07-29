
<cfxml variable="xmlMenu">
	<menu>
		<option label="Settings" event="ehSettings.dspMain" />
		<option label="Accounts" event="ehAccounts.dspMain" />
		<option label="Module Library" event="ehModules.dspMain" />
		<option label="Developer Resources" event="ehDevRes.dspMain" />
		<!--<option label="Check for Updates" event="ehUpdate.dspMain" />-->
	</menu>
</cfxml>

<cfoutput>
	<div style="height:10px;background-color:##50628b;">&nbsp;</div>
	<ul>
		<cfloop from="1" to="#arrayLen(xmlMenu.xmlRoot.xmlChildren)#" index="i">
			<cfset thisNode = xmlMenu.xmlRoot.xmlChildren[i]>
			<li>
				<cfif session.mainMenuOption eq thisNode.xmlAttributes.label>
					<span style="padding-left:10px;">#thisNode.xmlAttributes.label#</span>
				<cfelse>
					<a href="?event=#thisNode.xmlAttributes.event#">#thisNode.xmlAttributes.label#</a>
				</cfif>
			</li>
		</cfloop>
	</ul>
	<div style="height:10px;background-color:##50628b;border-bottom:1px solid black;">&nbsp;</div>
	<p>&nbsp;</p>
	<p>&nbsp;</p>
	<p>&nbsp;</p>
	<p>&nbsp;</p>
	<p>&nbsp;</p>
	<p>&nbsp;</p>
</cfoutput>