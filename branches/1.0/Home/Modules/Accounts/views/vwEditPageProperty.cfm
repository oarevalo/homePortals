<!--- 
vwEditPageProperty

View to edit a page property

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
---->

<cfset initContext()>
<cfset xmlDoc = xmlParse(expandPath(this.pageURL))>

<cfoutput>
<form name="frm" action="##" method="post" style="margin:0px;padding:0px;">
	<input type="hidden" name="property_property_type" value="#arguments.type#">
	<input type="hidden" name="property_property_index" value="#arguments.index#">
	
	<cfswitch expression="#arguments.type#">
		<cfcase value="stylesheet">
			<cfset aStylesheets = xmlSearch(xmlDoc,"//stylesheet")>
			<cfif arguments.index gt 0>
				<cfset tmpValue = aStylesheets[arguments.index].xmlAttributes.href>
			<cfelse>
				<cfset tmpValue = "">
			</cfif>
			
			<b>Add/Edit Stylesheet</b><br><br>
			HREF: <input type="text" name="property_HREF" value="#tmpValue#" style="width:250px;"><br>
		</cfcase>
		
		<cfcase value="script">
			<cfset aScripts = xmlSearch(xmlDoc,"//script")>
			<cfif arguments.index gt 0>
				<cfset tmpValue = aScripts[arguments.index].xmlAttributes.src>
			<cfelse>
				<cfset tmpValue = "">
			</cfif>

			<b>Add/Edit Script</b><br><br>
			HREF: <input type="text" name="property_SRC" value="#tmpValue#" style="width:250px;"><br>
		</cfcase>
		
		<cfcase value="layout">
			<cfset aLocations = xmlSearch(xmlDoc,"//layout/location")>
			<cfif arguments.index gt 0>
				<cfset tmpName = aLocations[arguments.index].xmlAttributes.name>
				<cfset tmpType = aLocations[arguments.index].xmlAttributes.type>
				<cfset tmpClass = aLocations[arguments.index].xmlAttributes.class>
			<cfelse>
				<cfset tmpName = "">
				<cfset tmpType = "Column">
				<cfset tmpClass = "">
			</cfif>

			<b>Add/Edit Layout Section</b><br><br>
			<table>
				<tr>
					<td>Name:</td>
					<td><input type="text" name="property_Name" value="#tmpName#" style="width:200px;"></td>
				</tr>
				<tr>
					<td>Type:</td>
					<td>
						<select name="property_type" style="width:200px;">
							<option value="header" <cfif tmpType eq "header">selected</cfif>>Header</option>
							<option value="column" <cfif tmpType eq "column">selected</cfif>>Column</option>
							<option value="footer" <cfif tmpType eq "footer">selected</cfif>>Footer</option>
						</select>
					</td>
				</tr>
				<tr>
					<td>CSS Class:</td>
					<td><input type="text" name="property_Class" value="#tmpClass#" style="width:200px;"></td>
				</tr>
			</table>
		</cfcase>
		
		<cfcase value="listener">
			<cfset aListener = xmlSearch(xmlDoc,"//eventListeners/event")>	
			<cfif arguments.index gt 0>
				<cfset tmpObject = aListener[arguments.index].xmlAttributes.objectName>
				<cfset tmpEventName = aListener[arguments.index].xmlAttributes.eventName>
				<cfset tmpEventHandler = aListener[arguments.index].xmlAttributes.eventHandler>
			<cfelse>
				<cfset tmpObject = "">
				<cfset tmpEventName = "">
				<cfset tmpEventHandler = "">
			</cfif>


			<b>Add/Edit Event Listener</b><br><br>
			<table>
				<tr>
					<td>Object:</td>
					<td><input type="text" name="property_ObjectName" value="#tmpObject#" style="width:200px;"></td>
				</tr>
				<tr>
					<td>Event Name:</td>
					<td><input type="text" name="property_EventName" value="#tmpEventName#" style="width:200px;"></td>
				</tr>
				<tr>
					<td>Event Handler:</td>
					<td><input type="text" name="property_EventHandler" value="#tmpEventHandler#" style="width:200px;"></td>
				</tr>
			</table>
		</cfcase>
	</cfswitch>

	<br>
	<input type="button" value="Save" style="width:auto;" onclick="controlPanel.saveProperty(this.form)">
	<input type="button" value="Cancel" onclick="controlPanel.closeEditProperty()" style="width:auto;">
</form>
</cfoutput>
