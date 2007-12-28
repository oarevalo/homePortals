function gmailClient() {
	// properties
	this.server = "/home/modules/gmail/gmail.cfc";
	this.instanceName = "";
	this.contentID = "";
	this.username = "";

	function getMail() {
		// initialize server
		var params = {
					instanceName: this.instanceName
				};
		h_callServer(this.server, "getMail", this.contentID, params);		
	}

	function doLogin(frm) {
		// perform login
		//var pwd = Encrypt(frm.password.value);
		var pwd = frm.password.value;
		var params = {
					instanceName: this.instanceName,
					username: frm.user.value,
					password: pwd,
					remember: frm.remember.checked
				};
		h_callServer(this.server, "doLogin", this.contentID, params);		
	}
	
	function Encrypt(theText) {
		output = new String;
		Temp = new Array();
		Temp2 = new Array();
		TextSize = theText.length;
		for (i = 0; i < TextSize; i++) {
			rnd = Math.round(Math.random() * 122) + 68;
			Temp[i] = theText.charCodeAt(i) + rnd;
			Temp2[i] = rnd;
		}
		for (i = 0; i < TextSize; i++) {
			output += String.fromCharCode(Temp[i], Temp2[i]);
		}
		return output;
	}	
	
	function unEncrypt(theText) {
		output = new String;
		Temp = new Array();
		Temp2 = new Array();
		TextSize = theText.length;
		for (i = 0; i < TextSize; i++) {
			Temp[i] = theText.charCodeAt(i);
			Temp2[i] = theText.charCodeAt(i + 1);
		}
		for (i = 0; i < TextSize; i = i+2) {
			output += String.fromCharCode(Temp[i] - Temp2[i]);
			alert(Temp[i] - Temp2[i]);
		}
		return output;
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	gmailClient.prototype.getMail = getMail;		
	gmailClient.prototype.doLogin = doLogin;		
}


