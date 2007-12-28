/*
	This file contains all client-side functions and eventhandlers
	related to the LibraryViewer module
*/
function libraryViewerClient() {
	// properties
	this.server = "/Home/Modules/LibraryViewer/LibraryViewer.cfc";
	this.instanceName = "";
	this.contentID = "";
	this.resourcesID = "";
	this.catalogIndex = -1;
	this.resourcePath = "";
	
	function getResource(path) {
		var params = {
		            instanceName: this.instanceName,
		            resourcePath: path
		            };
		h_callServer(this.server, "getResource", this.contentID,  params);
	}

	function getCatalogResources(catalogIndex) {
		if(catalogIndex > 0) {
        		var params = {
        		                instanceName: this.instanceName,
        		                catalogIndex: catalogIndex
        		              };
        		   
        		h_callServer(this.server, "getCatalogResources", this.resourcesID,  params);
        	}
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	libraryViewerClient.prototype.getResource = getResource;	
	libraryViewerClient.prototype.getCatalogResources = getCatalogResources;	

}


