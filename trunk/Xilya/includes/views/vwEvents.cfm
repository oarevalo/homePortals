
<cfparam name="arguments.eventName" default="">
<cfparam name="arguments.eventHandler" default="">

<cfscript>
	aModules = variables.oPage.getModules();
	qryListeners = variables.oPage.getEventHandlers();
	aAllEvents = ArrayNew(1);
	aAllEventHandlers = ArrayNew(1); 

	oCatalog = application.homePortals.getCatalog();

	for(i=1;i lte arrayLen(aModules);i=i+1) {
		oResourceBean = oCatalog.getModuleByName(aModules[i].name);

		if(not isSimpleValue(oResourceBean)) {

			// create list of possible events on this page	
			aEvents = oResourceBean.getEvents();
			for(j=1;j lte arrayLen(aEvents);j=j+1) {
				ArrayAppend(aAllEvents, aModules[i].id & "." & aEvents[j].name);
			}
	
			// create list of available event handlers
			aMethods = oResourceBean.getMethods();
			for(j=1;j lte arrayLen(aMethods);j=j+1) {
				ArrayAppend(aAllEventHandlers, aModules[i].id & "." & aMethods[j].name);
			}
		
		}
	}
	ArrayAppend(aAllEvents, "Framework.onPageLoaded");

</cfscript>


<cfoutput>

<cfset setControlPanelTitle("Module Connectors","cog")>

<div class="cp_sectionBox" 
	 style="padding:0px;margin:0px;width:475px;margin:10px;">
	<div style="margin:4px;">
		Use Module Connectors to allow two or more modules to interact with each other.
		Connect a module to another by indicating an event and a corresponding action.
		Events are raised by modules when certain conditions occurr (i.e. selecting a date on a calendar,
		a bookmark, etc)
	</div>
</div>

<div style="margin:10px;border:1px solid ##ccc;height:195px;overflow:auto;">	
	<table class="cp_dataTable">
		<tr>
			<th>Event</th>
			<th>Action</th>
			<th width="10">&nbsp;</th>
		</tr>
		<cfloop query="qryListeners">
			<tr <cfif qryListeners.currentRow mod 2>style="background-color:##f3f3f3;"</cfif>>
				<td>#qryListeners.objectName#.#qryListeners.eventName#</td>
				<td>#qryListeners.eventHandler#</td>
				<td align="right">
					<a href="javascript:controlPanel.deleteEventHandler(#qryListeners.currentRow#)"><img src="#imgRoot#/waste_small.gif" align="absmiddle" border="0"></a>
				</td>
			</tr>
		</cfloop>
		<cfif qryListeners.recordCount eq 0>
			<tr><td colspan="3"><em>No connectors found.</em></td></tr>
		</cfif>
	</table>
</div>	

<fieldset style="margin:10px;border:1px solid ##ccc;background-color:##ebebeb;">
	<legend><strong>Add Event Handler:</strong></legend>
	<form name="frm" action="##" method="post" style="margin:0px;padding:0px;">
		<table cellspacing="0" cellpadding="2" style="width:440px;margin-bottom:5px;">
			<tr>
				<td>Select an Event:</td>
				<td>Select an Action:</td>
			</tr>
			<tr>
				<td>
					<select name="eventName" style="width:200px;font-size:10px;">
						<option value=""></option>
						<cfloop from="1" to="#arrayLen(aAllEvents)#" index="i">
							<option value="#aAllEvents[i]#"
									<cfif arguments.eventName eq aAllEvents[i]>selected</cfif>>#aAllEvents[i]#</option>
						</cfloop>
					</select>
				</td>	
				<td>
					<select name="eventHandler" style="width:200px;font-size:10px;">
						<option value=""></option>
						<cfloop from="1" to="#arrayLen(aAllEventHandlers)#" index="i">
							<option value="#aAllEventHandlers[i]#"
									<cfif arguments.eventHandler eq aAllEventHandlers[i]>selected</cfif>>#aAllEventHandlers[i]#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>
		
		
		<input type="button" name="btnSave" value="Add Event Handler" onclick="controlPanel.addEventHandler(this.form)">
	</form>
</fieldset>



</cfoutput>
