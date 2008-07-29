function toDoClient() {
	// properties
	this.URL = "";
	this.instanceName = "";

	// client html-region IDs
	this.id = "";

	// Server addresses
	this.server = "/home/modules/ToDo/todo.cfc";


	function init() {
		// initialize server
		var params = {
					instanceName: this.instanceName,
					URL: this.URL
				};
		h_callServer(this.server, "init", this.id, params);				
	}
	
	function getItems(category) {
		// get items
		if(category!=null && category!="")
			var params = {
						instanceName: this.instanceName,
						category: category
					};
		else 
			var params = {instanceName: this.instanceName};
		h_callServer(this.server, "getItems", this.id, params);				
	}
	
	function setItemStatus(chk,category,index,id) {
		var r = document.getElementById(id);
		if(r) {
			if(chk.checked) 
				r.style.textDecoration = "line-through";
			else 
				r.style.textDecoration = "none";
		}
		
		h_callServer(this.server, 
					 "setItemStatus", 
					 "", 
					 {instanceName: this.instanceName, index: index, completed: chk.checked, category:category});	
	}
	
	function editItem(category, index, id) {
		
		//close open rows
		this.closeEdit();
		
		var r = document.getElementById(id + "_row");
		if(r) {
			r.className = "displayRow";
			h_callServer(this.server, 
						 "editItem", 
						 id, 
						 {instanceName: this.instanceName, index: index, category: category});
		}
	}
	function closeEdit() {
		/*var r = document.getElementById(id + "_row");
		if(r) {
			r.className = "hideRow";
		}*/
		var t = document.getElementById(this.id);
		var aRows = t.getElementsByTagName("tr");
		for(var i=0;i<aRows.length;i++) {
			if(aRows[i].className=="displayRow") {
				aRows[i].className="hideRow";
			}
		}
	};

	function deleteItem(category, index) {
		if(confirm("Delete task?")) {
			h_callServer(this.server, 
						 "deleteItem", 
						 this.id, 
						 {instanceName: this.instanceName, index: index, category:category});
		}
	}

	function saveItem(index,frm) {
		var params = {
					instanceName: this.instanceName,
					index: index,
					task: frm.task.value,
					completed: frm.completed.checked,
					category: frm.category.value,
					description: frm.description.value
				};		
		h_callServer(this.server, "saveItem", this.id, params);			
	}

	function hideComplete(hide) {
		var t = document.getElementById(this.id);
		var aRows = t.getElementsByTagName("tr");
		for(var i=0;i<aRows.length;i++) {
			if(aRows[i].className=="taskRowComplete" || aRows[i].className=="taskRowCompleteNoShow") {
				if(hide)
					aRows[i].className="taskRowCompleteNoShow";
				else
					aRows[i].className="taskRowComplete";
			}
		}
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	toDoClient.prototype.init = init;	
	toDoClient.prototype.getItems = getItems;	
	toDoClient.prototype.setItemStatus = setItemStatus;	
	toDoClient.prototype.editItem = editItem;	
	toDoClient.prototype.deleteItem = deleteItem;	
	toDoClient.prototype.saveItem = saveItem;
	toDoClient.prototype.closeEdit = closeEdit;	
	toDoClient.prototype.hideComplete = hideComplete;
}