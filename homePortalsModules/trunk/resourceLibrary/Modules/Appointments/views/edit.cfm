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
		
		tmpDate = qryData.eventDate;
		tmpTime = qryData.eventTime;
		tmpDescription = qryData.description;
		tmpSubject = qryData.subject;

		// if this is recognized as a proper time, then format it
		try {
			tmpTime = LSTimeFormat(tmpTime);
		} catch(any e) {
			// do nothing 
		}
		
		if(arguments.id eq "")
			tmpDate = arguments.date;
			
		tmpDate = dateFormat(tmpDate, "mm/dd/yy");
				
	} catch(any e) {
		aGroups = ArrayNew(1);
		bFailed = true;
		bIsContentOwner = stUser.isOwner;   // since we can't read the content store, 
											// assume the page owner is the content owner
		errMessage = e.message & "<br>" & e.detail;
	}
</cfscript>

<style type="text/css">
	#frmEditAppointment {
		padding:0px;
		margin:0px;
	}
	#frmEditAppointment input {
		font-family:Arial, Helvetica, sans-serif;
		font-size:11px;
		border:1px solid black;
		padding:2px;
	}
	#frmEditAppointment textarea  {
		font-family:Arial, Helvetica, sans-serif;
		font-size:11px;
		width:475px;
		border:1px solid silver;
		padding:2px;
		height:320px;
		margin:5px;
	}	
</style>

<cfoutput>
	<div style="background-color:##f5f5f5;">
		<div style="padding:0px;width:490px;">
		
			<div style="margin:5px;background-color:##333;border:1px solid silver;color:##fff;">
				<div style="margin:5px;">
					<strong>Appointments:</strong> #DayOfWeekAsString(DayOfWeek(arguments.date))# #lsDateFormat(arguments.date)#
				</div>
			</div>
						
			<cfif not bFailed>
				<form action="##" method="post" id="frmEditAppointment" name="frmEditAppointment">
					<div style="border:1px solid silver;background-color:##fff;margin:5px;">
						<table style="margin:5px;">
							<tr>
								<td style="width:60px;font-size:10px;"><strong>Date:</strong></td>
								<td style="width:180px;">
									<input type="text" name="date" value="#arguments.date#" style="width:100px;">
									<span style="font-size:9px;">mm/dd/yyyy</span>
								</td>
								<td style="width:10px;">&nbsp;</td>
								<td>
									<span style="font-size:10px;"><strong>Time:</strong></span>
									<input type="text" name="time" value="#tmpTime#" style="width:80px;">
									<span style="font-size:9px;">(optional)</span>
								</td>
							</tr>
							<tr>
								<td style="width:60px;font-size:10px;"><strong>Subject:</strong></td>
								<td colspan="3"><input type="text" name="subject" value="#tmpSubject#" style="width:380px;"></td>
							</tr>
						</table>
					</div>
		
					<textarea name="description" 
							  rows="22">#htmlEditFormat(tmpDescription)#</textarea>
		
					<div style="margin:5px;background-color:##ececec;border:1px solid silver;color:##fff;">
						<div style="margin:5px;">
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