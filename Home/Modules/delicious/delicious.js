function deliciousClient() {
	// properties
	this.id = "";
	this.contentID = "";
	this.user = "";
	this.tags = "";

	// Server addresses
	this.server = "/home/modules/delicious/delicious.cfc";

	function doSearch(user,tags) {
		this.user = user;
		this.tags = tags;
		var params = {
					instanceName: this.id,
					contentID: this.contentID,
					user: this.user,
					tags: this.tags
				};
		h_callServer(this.server, "doSearch", this.contentID, params);				
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	deliciousClient.prototype.doSearch = doSearch;	
}