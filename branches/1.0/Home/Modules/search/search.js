/*
	This file contains all client-side functions and eventhandlers
	related to the boookmarks2 module
*/
function searchClient() {
	// properties
	this.server = "/Home/Modules/search/search.cfc";
	this.instanceName = "";
	this.contentID = "";
	
	function doSearch(frm) {
		if(frm.query.value!="") {
			var params = {
					instanceName: this.instanceName,
					engine: frm.engine.value,
					query: frm.query.value
					};
			h_callServer(this.server, "doSearch", this.contentID,  params);
		}
	}
	function clearSearch() {	
		var d = document.getElementById(this.instanceName+"_content_BodyRegion");
		if(d) d.innerHTML = "";	
	}
	function doSearch2(engine,query,start) {
		var params = {
				instanceName: this.instanceName,
				engine: engine,
				query: query,
				start: start
			};
		h_callServer(this.server, "doSearch", this.contentID,  params);
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	searchClient.prototype.doSearch = doSearch;	
	searchClient.prototype.clearSearch = clearSearch;	
	searchClient.prototype.doSearch2 = doSearch2;	
}


