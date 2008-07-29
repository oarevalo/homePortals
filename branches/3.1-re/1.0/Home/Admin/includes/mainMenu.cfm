<!--- renders the main menu --->
<cfset qryMenuOptions = appState.qryMenuOptions>
<cfset thisView = view>

<a href="home.cfm?view=main" <cfif view eq "main">style="color:black;"</cfif>>Home</a><br>

<cfoutput query="qryMenuOptions" group="optionGroup">
	<a href="##">#optionGroup#</a>
	<div style="margin-bottom:10px;">
		<cfoutput>
			<a href="home.cfm?view=#qryMenuOptions.view#" class="menuSubOption"
				<cfif thisView eq qryMenuOptions.view>style="color:black;"</cfif>>#qryMenuOptions.label#</a><br>
		</cfoutput>
	</div>
</cfoutput>

