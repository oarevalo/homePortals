<cfset isContextVar = resourceID eq "_CUSTOM_" 
						or (left(resourceID,1) eq "{" and right(resourceID,1) eq "}")>
<cfoutput>
	<cfif isContextVar>
		<cfif resourceID eq "_CUSTOM_">
			<cfset tmp = "">
		<cfelse>
			<cfset tmp = "#resourceID#">
		</cfif>
		<input type="text" name="#prefix#__id" value="#tmp#" class="cms-formField">
		<input type="hidden" name="#prefix#__iscustom" value="1">
	<cfelse>
		<cfinclude template="vwEditResource.cfm">
		<input type="hidden" name="#prefix#__iscustom" value="0">
	</cfif>
</cfoutput>
