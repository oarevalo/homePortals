function appointmentsClient() {
	// properties
	this.calendarURL = "";
	this.server = "/home/modules/Appointments/appointments.cfc";
	this.id = "";
	this.instanceName = "";
	this.calendarID = "";
	this.contentID = "";
	this.currentDate = "";
	this.viewMode = "day"; // day | week | month
	
	function init() {
		// initialize server
		var params = {
					instanceName: this.instanceName,
					calendarURL: this.calendarURL
				};
		h_callServer(this.server, "init", this.contentID, params);		
	}

	function getAppointments(date) {
		// returns all appointments for the given date
		this.currentDate = date;
		var params = {
					instanceName: this.instanceName,
					date: date,
					viewMode: this.viewMode
				};
		h_callServer(this.server, "getAppointments", this.contentID, params);
	}
		
	function deleteAppointment(date,index) {
		if(confirm("Delete Appointment?"))
			h_callServer(this.server, 
						 "deleteAppointment", 
						 this.contentID, 
						 {instanceName: this.instanceName, index: index, date: date});			
	}

	function editAppointment(date,index) {
		h_callServer(this.server, 
					 "editAppointment", 
					 this.contentID, 
					 {instanceName: this.instanceName, index: index, date: date});			
	}
	
	function saveAppointment(index,frm) {
		var params = {
					instanceName: this.instanceName,
					index: index,
					date: frm.date.value,
					time: frm.time.value,
					description: frm.description.value
				};		
		h_callServer(this.server, "saveAppointment", this.contentID, params);			
	}	

	function setView(viewMode) {
		if(viewMode=="day" || viewMode=="week" || viewMode=="month") {
			this.viewMode = viewMode;
			this.getAppointments(this.currentDate);
		}
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	appointmentsClient.prototype.init = init;	
	appointmentsClient.prototype.getAppointments = getAppointments;	
	appointmentsClient.prototype.deleteAppointment = deleteAppointment;	
	appointmentsClient.prototype.editAppointment = editAppointment;	
	appointmentsClient.prototype.saveAppointment = saveAppointment;	
	appointmentsClient.prototype.setView = setView;	
}