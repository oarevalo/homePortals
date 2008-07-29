<!--- 
vwEditPageProperty

View to edit a page property

** This file should be included from addContent.cfc

History:
12/4/05 - oarevalo - created
---->

<cfset tmpValue = "">

<cfoutput>
<form name="frm" action="##" method="post" style="margin:0px;padding:0px;">
	<input type="hidden" name="property_property_type" value="#arguments.type#">
	<input type="hidden" name="property_property_index" value="#arguments.index#">
	
	<cfswitch expression="#arguments.type#">
		<cfcase value="stylesheet">
			<cfset aStylesheets = variables.oPage.getStyles()>
			<cfif arguments.index gt 0>
				<cfset tmpValue = aStylesheets[arguments.index]>
			</cfif>

			<b>Add/Edit Stylesheet</b><br><br>
			HREF: <input type="text" name="property_HREF" value="#tmpValue#" style="width:250px;"><br>
		</cfcase>
		
		<cfcase value="script">
			<cfset aScripts = variables.oPage.getScripts()>
			<cfif arguments.index gt 0>
				<cfset tmpValue = aScripts[arguments.index]>
			</cfif>

			<b>Add/Edit Script</b><br><br>
			HREF: <input type="text" name="property_SRC" value="#tmpValue#" style="width:250px;"><br>
		</cfcase>
		
		<cfcase value="layout">
			<cfset qryLocations = variables.oPage.getLocations()>
			<cfif arguments.index gt 0>
				<cfset tmpName = qryLocations.name[arguments.index]>
				<cfset tmpType = qryLocations.type[arguments.index]>
				<cfset tmpClass = qryLocations.class[arguments.index]>
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
			<cfset qryListeners = variables.oPage.getEventHandlers()>
			<cfif arguments.index gt 0>
				<cfset tmpObject = qryListeners.objectName[arguments.index]>
				<cfset tmpEventName = qryListeners.eventName[arguments.index]>
				<cfset tmpEventHandler = qryListeners.eventHandler[arguments.index]>
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
