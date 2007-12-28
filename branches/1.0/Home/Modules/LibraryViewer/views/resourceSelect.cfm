<cfoutput>
	<b>Select Resource: </b>
	<select name="resourcePath" onchange="#instanceName#.getResource(this.value)">
		<cfloop list="#lstResources#" index="resType">
			<cfset qryRes = stCatalog[resType]>
			<cfif qryRes.recordCount gt 0>
				<optgroup label="#resType#">
					<cfloop query="qryRes">
						<cfif resType eq "pages">
							<option value="#arguments.catalogIndex#/#resType#/#id#">#title#</option>	
						<cfelse>
							<option value="#arguments.catalogIndex#/#resType#/#id#">#id#</option>	
						</cfif>
					</cfloop>
				</optgroup>
			</cfif>
		</cfloop>
	</select>
</cfoutput>