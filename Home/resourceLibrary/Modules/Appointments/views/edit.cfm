<cfparam name="arguments.date" default="#now()#">
<cfparam name="arguments.id" type="string" default="">

<cfscript>
	cfg = this.controller.getModuleConfigBean();
	moduleID = this.controller.getModuleID();
	
	stUser = this.controller.getUserInfo();
	tmpModulePath = cfg.getModuleRoot();	
	imgRoot = tmpModulePath & "/images";
	
	bFailed = false;
	errorMessage = "";
	
	try {	
		// get content store
		setContentStoreURL();
		myContentStore = this.controller.getContentStore();
	
		// check if current user is owner
		bIsContentOwner = (stUser.username eq myContentStore.getOwner());

		if(arguments.date eq "") arguments.date = now();
		arguments.date = DateFormat(Arguments.date, "mm/dd/yyyy");
				
		// get the appointments to display
		qryData = getAppointmentByID(arguments.id);
		
		tmpTime = qryData.eventTime;
		tmpDescription = qryData.description;
		tmpSubject = qryData.subject;

		// if this is recognized as a proper time, then format it
		try {
			tmpTime = LSTimeFormat(tmpTime);
		} catch(any e) {
			// do nothing 
		}
				
	} catch(any e) {
		aGroups = ArrayNew(1);
		bFailed = true;
		bIsContentOwner = stUser.isOwner;   // since we can't read the content store, 
											// assume the page owner is the content owner
		errMessage = e.message & "<br>" & e.detail;
	}
</cfscript>

<cfoutput>
	<div style="background-color:##f5f5f5;">
		<div style="padding:0px;width:490px;">
		
			<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;">
				<div style="margin:5px;">
					<strong>Appointments:</strong> #DayOfWeekAsString(DayOfWeek(arguments.date))# #lsDateFormat(arguments.date)#
				</div>
			</div>
						
			<cfif not bFailed>
				<form action="##" method="post" name="frmEditAppointment" style="padding:0px;margin:0px;">
					<div style="border:1px solid silver;background-color:##fff;margin:5px;">
						<table style="margin:5px;">
							<tr>
								<td><strong>Time:</strong></td>
								<td>
									<input type="text" name="time" value="#tmpTime#" style="width:300px;border:1px solid black;padding:2px;font-size:11px;">
								</td>
							</tr>
							<tr>
								<td><strong>Subject:</strong></td>
								<td><input type="text" name="subject" value="#tmpSubject#" style="width:300px;border:1px solid black;padding:2px;font-size:11px;"></td>
							</tr>
						</table>
					</div>
		
					<textarea name="description" 
							  style="width:475px;border:1px solid silver;padding:2px;height:320px;margin:5px;"
							  rows="22">#htmlEditFormat(tmpDescription)#</textarea>
		
					<div style="margin:5px;background-color:##ececec;border:1px solid silver;color:##fff;">
						<div style="margin:5px;">
							<input type="hidden" name="date" value="#arguments.date#">
							<input type="hidden" name="id" value="#arguments.id#">
							<input type="button" value="Save Appointment" onclick="#moduleID#.doFormAction('saveAppointment',this.form);#moduleID#.closeWindow();">
							<input type="button" value="Cancel" onclick="#moduleID#.closeWindow()">
						</div>
					</div>
				</form>
			<cfelse>
				<b>Error:</b><br>
				#errMessage#
				<p><a href="javascript:#moduleID#.getView()">Return</a></p>
			</cfif>
	
		</div>
	</div>	
</cfoutput>