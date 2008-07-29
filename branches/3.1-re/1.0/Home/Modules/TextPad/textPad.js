function textPadClient() {
	// properties
	this.URL = "";
	this.id = "";
	this.contentID = "";
	this.mode = "view"

	// Server addresses
	this.server = "/home/modules/TextPad/textPad.cfc";

	function getContent(contentID){
		if(!contentID) contentID = "";

		if(contentID != "") {
           	var params = {
            				instanceName: this.id,
            				contentID: contentID
            				};
 	
        		if(this.mode == "edit") {
            		h_callServer(this.server, "getContent", this.id + "_status", params);		
            		this.setStatusMessage("loading...");		
            	} else {
            	    h_callServer(this.server, "getView", this.id, params);	
            	    this.contentID = contentID;
            	}
        }
	}

    function setContent(contentID,tmpID) {
        // update editor content
        var tmp = $(tmpID);
        if(tmp) {
            this.setMCEInstance();
            tinyMCE.setContent(tmp.innerHTML);
        }
        
        // update form
        	var frm = $(this.id + "_form");
        	if(frm) {
        	    frm.btnDelete.disabled = false;
            	frm.contentID.value = contentID;
        	}

        	this.contentID = contentID;	
        	this.clearStatus();
    }

	function getIndex() {
		// get index
		var params = {instanceName: this.id};
		h_callServer(this.server, "getIndex", this.id, params);		
		this.contentID = "";			
	}
	
	function save() {
	    this.setMCEInstance();
	    var content = tinyMCE.getContent();
	    var frm = $(this.id + "_form");
	    
	    if(this.contentID == "" && frm.contentID.value == "") {
	        alert("Please enter a title for this entry");
	    } else {
        		var params = {
        					instanceName: this.id,
        					content: content,
        					contentID: this.contentID,
        					newContentID: frm.contentID.value
        				};		
        		h_callServer(this.server, "save", this.id + "_status", params);
        	}
	}
	
	function saveCallback(contentID) {
        this.getContentSelector();
	    setTimeout(this.id + ".clearStatus()",2000);
	    h_raiseEvent("editBox", "contentChanged", {instanceName: this.id, contentID: contentID});
	}
	

	function deleteEntry(){
		this.setMCEInstance();
		if(confirm("Are you sure you wish to delete this entry?")) {
			var params = {
						instanceName: this.id,
						contentID: this.contentID
						};
			h_callServer(this.server, "deleteEntry", this.id + "_status", params);	
		}
	}
	
	function deleteEntryCallback(contentID) {
        // update editor
	    this.setMCEInstance();
	    tinyMCE.setContent("");

        // clear current entry ID
		this.contentID = "";		
        
        // update select box
	    this.getContentSelector();

        // update form
		var frm = $(this.id + "_form");
        	if(frm) {
             // disable delete button
        	    frm.btnDelete.disabled = true;
        	    
            	// clear title
            	frm.contentID.value = "";
        	}					
        	
        	// display status message
        	setTimeout(this.id + ".clearStatus()",2000);
        	
        // raise event
        h_raiseEvent("editBox", "contentChanged", {instanceName: this.id, contentID: contentID});
        
	}
	
	function newDocument() {
        this.setMCEInstance();
        	var content = tinyMCE.getContent();
        	var frm = $(this.id + "_form");
        	
        	if(content != "")
        	    bOK = confirm("Discard any unsaved changes and start a new document?");
        	else
        	    bOK = true;
        	
        if(bOK && frm) {
            this.contentID = "";		
            tinyMCE.setContent("");
            frm.btnDelete.disabled = true;
            frm.contentID.value = "";
         }
	}

    function setMCEInstance() {
        var editor_id = this.id + "_edit";
        var myMCE = tinyMCE.getInstanceById(editor_id);
        tinyMCE.selectedInstance = myMCE;
    }
    
    function clearStatus() {
        	var stat = $(this.id + "_status_BodyRegion");
        	stat.innerHTML = "";
    }
    
    function setStatusMessage(msg) {
        	var stat = $(this.id + "_status_BodyRegion");
        	stat.innerHTML = msg;
    }

	function getContentSelector(){
		h_callServer(this.server, "getContentSelector", this.id + "_selector", {instanceName: this.id});	
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	textPadClient.prototype.getContent = getContent;	
	textPadClient.prototype.getIndex = getIndex;	
	textPadClient.prototype.save = save;	
	textPadClient.prototype.saveCallback = saveCallback;	
	textPadClient.prototype.deleteEntry = deleteEntry;	
	textPadClient.prototype.deleteEntryCallback = deleteEntryCallback;	
	textPadClient.prototype.newDocument = newDocument;	
	textPadClient.prototype.setContent = setContent;
	textPadClient.prototype.setMCEInstance = setMCEInstance;
	textPadClient.prototype.clearStatus = clearStatus;
	textPadClient.prototype.getContentSelector = getContentSelector;
	textPadClient.prototype.setStatusMessage = setStatusMessage;
}