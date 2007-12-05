<cfscript>
	oSite = getValue("oSite");
	oPage = getValue("oPage");
	oCatalog = getValue("oCatalog");
	
	eventName = getValue("eventName", "");
	eventHandler = getValue("eventHandler", "");
	
	aPages = oSite.getPages();
	owner = oSite.getOwner();
	title = oPage.getPageTitle();
	
	oAccounts = oSite.getAccount();
	stAccountInfo = oAccounts.getConfig();
	
	thisPageHREF = oPage.getHREF();	

	aModules = oPage.getModules();
	qryListeners = oPage.getEventHandlers();
	aAllEvents = ArrayNew(1);
	aAllEventHandlers = ArrayNew(1); 

	for(i=1;i lte arrayLen(aModules);i=i+1) {
		xmlModuleInfo = oCatalog.getModuleByName(aModules[i].name);
		if(Not isSimpleValue(xmlModuleInfo)) {

			// create list of possible events on this page	
			if(structKeyExists(xmlModuleInfo,"api") and structKeyExists(xmlModuleInfo.api,"events")) {
				aEvents = xmlModuleInfo.api.events.xmlChildren;
				for(j=1;j lte arrayLen(aEvents);j=j+1) {
					ArrayAppend(aAllEvents, aModules[i].id & "." & aEvents[j].xmlAttributes.name);
				}
			}
	
			// create list of available event handlers
			if(structKeyExists(xmlModuleInfo,"api") and structKeyExists(xmlModuleInfo.api,"methods")) {
				aMethods = xmlModuleInfo.api.methods.xmlChildren;
				for(j=1;j lte arrayLen(aMethods);j=j+1) {
					ArrayAppend(aAllEventHandlers, aModules[i].id & "." & aMethods[j].xmlAttributes.name);
				}
			}
			
		}
	}
	ArrayAppend(aAllEvents, "Framework.onPageLoaded");
	
</cfscript>

<cfoutput>
<h2>Accounts > #owner# > Page Editor > Event Handlers</h2>

<table id="tblPageDesigner" cellspacing="0" cellpadding="0">
	<tr valign="top">
		<td colspan="3" style="padding:0px;">
			<div class="cp_sectionBox" 
				 style="margin:0px;padding:0px;width:630px;margin-top:5px;overflow:hidden;">
				<table style="margin:5px;width:620px;" cellpadding="0" cellspacing="0">
					<tr>
						<td>
							<strong>Title:</strong> #title#
						</td>

						<td align="right">
							<strong>Page:</strong>
							<select name="page" style="width:120px;" onchange="document.location='?event=ehPage.doLoadPage&href=#stAccountInfo.accountsRoot#/'+this.value">
								<cfloop from="1" to="#arrayLen(aPages)#" index="i">
									<cfset pageAttributes = aPages[i]>
									<cfset pageHREF = "/#owner#/layouts/#pageAttributes.href#">
									<option value="#pageHREF#"
											<cfif getFileFromPath(pageHREF) eq getFileFromPath(thisPageHREF)>selected</cfif>>#pageAttributes.href#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</div>
		</td>
	</tr>
</table>

<div class="cp_sectionBox" 
	 style="padding:0px;margin:0px;margin-top:10px;">
	<div style="margin:4px;">
		<h2 style="margin:1px;">Event Handlers</h2>
		Using Event Handlers in HomePortals allows two or more modules to interact
		with each other. Use the form below
		to add event handler declarations for this page. Each event
		handler declaration consists on an event and a corresponding action. Events
		are raised by modules when certain conditions occurr (i.e. selecting a date on a calendar,
		a bookmark, etc)
	</div>
</div>

<div style="margin-top:10px;border:1px solid ##ccc;height:130px;overflow:auto;">	
	<table class="cp_dataTable">
		<tr>
			<th width="10">&nbsp;</th>
			<th>Event</th>
			<th>Action</th>
			<th width="10">&nbsp;</th>
		</tr>
		<cfloop query="qryListeners">
			<tr <cfif qryListeners.currentRow mod 2>style="background-color:##f3f3f3;"</cfif>>
				<td align="right"><b>#qryListeners.currentRow#.</b></td>
				<td>#qryListeners.objectName#.#qryListeners.eventName#</td>
				<td>#qryListeners.eventHandler#</td>
				<td align="right">
					<a href="javascript:deleteEventHandler(#qryListeners.currentRow#)"><img src="images/waste_small.gif" align="absmiddle" border="0"></a>
				</td>
			</tr>
		</cfloop>
		<cfif qryListeners.recordCount eq 0>
			<tr><td colspan="4"><em>No event handlers found.</em></td></tr>
		</cfif>
	</table>
</div>	

<form name="frm" method="post" action="index.cfm" style="margin:0px;padding:0px;">
	<fieldset style="margin-top:10px;border:1px solid ##ccc;background-color:##ebebeb;">
		<legend><strong>Add Event Handler:</strong></legend>
		<input type="hidden" name="event" value="ehPage.doAddEventHandler">
	
		<table cellspacing="0" cellpadding="2" style="width:440px;margin-bottom:5px;">
			<tr>
				<td>Select an Event:</td>
				<td>Select an Action:</td>
				<td>&nbsp;</td>
			</tr>
			<tr>
				<td>
					<select name="eventName" style="width:200px;font-size:10px;">
						<option value=""></option>
						<cfloop from="1" to="#arrayLen(aAllEvents)#" index="i">
							<option value="#aAllEvents[i]#"
									<cfif eventName eq aAllEvents[i]>selected</cfif>>#aAllEvents[i]#</option>
						</cfloop>
					</select>
				</td>	
				<td>
					<select name="eventHandler" style="width:200px;font-size:10px;">
						<option value=""></option>
						<cfloop from="1" to="#arrayLen(aAllEventHandlers)#" index="i">
							<option value="#aAllEventHandlers[i]#"
									<cfif eventHandler eq aAllEventHandlers[i]>selected</cfif>>#aAllEventHandlers[i]#</option>
						</cfloop>
					</select>
				</td>
				<td>
					<input type="submit" name="btnSave" value="Add Event Handler">	
				</td>
			</tr>
		</table>
	</fieldset>

	<p>
		<input type="button" 
				name="btnCancel" 
				value="Return To Page Editor" 
				onClick="document.location='?event=ehPage.dspPageEditor'">
		&nbsp;&nbsp;
		
	</p>
</form>
</cfoutput>