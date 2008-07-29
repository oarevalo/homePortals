/*
	This file contains all client-side functions and eventhandlers
	related to the boookmarks2 module
*/
function bookmarks2Client() {
	// properties
	this.server = "/Home/Modules/Bookmarks2/bookmarks2.cfc";
	this.instanceName = "";
	this.contentID = "";
	this.bookmarksURL = "";	
	
	function getBookmarks() {
		var params = {instanceName: this.instanceName};
		h_callServer(this.server, "getBookmarks", this.contentID,  params);
	}

	function getAddItem() {
		var params = {instanceName: this.instanceName};
		h_callServer(this.server, "getAddItem", this.contentID,  params);
	}

	function getEditView() {
		var params = {instanceName: this.instanceName};
		h_callServer(this.server, "getEditView", this.contentID,  params);
	}

	function getEditItem(index) {
		var params = {instanceName: this.instanceName,
					  index: index};
		h_callServer(this.server, "getEditItem", this.contentID,  params);
	}

	function addItem(text,url,type,onclick,target,htmlURL,xmlURL) {
		var params = {
				instanceName: this.instanceName,
				text:text,
				url:url,
				type:type,
				onclick:onclick,
				target:target,
				htmlURL:htmlURL,
				xmlURL:xmlURL
				};
		h_callServer(this.server, "addItem", this.contentID,  params);
	}

	function addItem2(params) {
		if(confirm('Add item to Bookmarks list?')) {
			if(typeof params == 'string') {
				params = {
						instanceName: this.instanceName,
						text:params,
						url:"javascript:;"
					}
			} else {
				params["instanceName"] = this.instanceName;
			}
			h_callServer(this.server, "addItem", this.contentID,  params);
		}
	}

	function followLink(url) {
		document.location = url;	
	}

	function getEdit() {
		var url =  '/home/home.cfm?currentHome=/HomeEdit/default.xml&doc='+this.bookmarksURL;
		window.open(url);
		//document.location =;
	}

	function showMoreAttribs() {
		var rl = document.getElementById(this.instanceName+"_editMoreLabel");	
		var tb = document.getElementById(this.instanceName+"_editMoreBody");	
		
		if(rl) rl.className = this.instanceName+"_hideRow";
		if(tb) tb.className = this.instanceName+"_showRow";
	}

	function saveItem(frm) {
		var params = {
				instanceName: this.instanceName,
				index:frm.index.value,
				text:frm.text.value,
				url:frm.url.value,
				type:frm.type.value,
				onclick:frm.onclick.value,
				target:frm.target.value,
				htmlURL:frm.htmlURL.value,
				xmlURL:frm.xmlURL.value
				};		
		h_callServer(this.server, "saveItem", this.contentID,  params);		
	}

	function deleteItem(index) {
		var params = {instanceName: this.instanceName,
					  index: index};
		if(confirm("Are you sure you wish to delete this item?")) 
			h_callServer(this.server, "deleteItem", this.contentID,  params);
	}


	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	bookmarks2Client.prototype.getBookmarks = getBookmarks;	
	bookmarks2Client.prototype.getAddItem = getAddItem;	
	bookmarks2Client.prototype.getEdit = getEdit;	
	bookmarks2Client.prototype.getEditView = getEditView;	
	bookmarks2Client.prototype.getEditItem = getEditItem;	

	bookmarks2Client.prototype.addItem = addItem;	
	bookmarks2Client.prototype.addItem2 = addItem2;	
	bookmarks2Client.prototype.followLink = followLink;	
	bookmarks2Client.prototype.showMoreAttribs = showMoreAttribs;	
	bookmarks2Client.prototype.saveItem = saveItem;	
	bookmarks2Client.prototype.deleteItem = deleteItem;	
}


