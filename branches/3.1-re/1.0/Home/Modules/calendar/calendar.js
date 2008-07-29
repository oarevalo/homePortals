function calendarClient() {
	// properties
	this.server = "/home/modules/Calendar/calendar.cfc";
	this.id = "";
	this.instanceName = "";

	function getCalendar(date) {
		// returns a calendar centerd on the given date
		if(date==null) date="";
		var params = {
					instanceName: this.instanceName,
					date: date
				};
		h_callServer(this.server, "getCalendar", this.id, params);
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	calendarClient.prototype.getCalendar = getCalendar;	
}