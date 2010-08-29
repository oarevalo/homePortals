
/* *****************************************************/
/* main.js								   		*/
/*												   		*/
/* This javascript contains all js functions for the  	*/
/* of the CMS plugin.  				  		*/
/*												   		*/
/* (c) 2007 - Oscar Arevalo - info@homeportals.net  	*/
/*												   		*/
/* *****************************************************/


var editHTML = "";
var _pageHREF = "";
var _pageFileName = "";

function controlPanelClient() {

	// pseudo-constructor
	function init(gateway, cmsRoot, lstLocations) {
		this.server = gateway;
		this.cmsRoot = cmsRoot;
		this.instanceName = "";	
		this.currentModuleLayout = "";
		this.currentModuleID = "";
		this.locations = lstLocations;
		this.panelDivID = "cms-navMenuContentPanel";
	}

	function closePanel() {
		jQuery("#"+this.panelDivID).hide();
	}

	function getView(view, args) {
		scroll(0,0);
		if(args==null) args = {};
		args["viewName"] = view;
		args["useLayout"] = true;

		var p = jQuery("#"+this.panelDivID);
		p.empty();
		h_callServer("getView", this.panelDivID, args);
		p.show();
	}

	function getPartialView(view, args, tgt) {
		if(args==null) args = {};
		args["viewName"] = view;
		args["useLayout"] = false;
		h_callServer("getView", tgt, args);
}


	// *****   Actions ****** //
	
	function addContentTag(frm) {
		h_callServer("addContentTag","cms-statusMessage",{tag:frm.tag.value, location:frm.location.value});
	}

	function deleteModule(modID) {
		if(confirm('Are you sure you wish to delete this module?')) {
			h_callServer("deleteModule", "cms-statusMessage", {moduleID:modID});
		}
	}		
	
	function removeModuleFromLayout(modID) {
		jQuery("#"+modID).remove();
		controlPanel.currentModuleID = "";
	}
	
	function addPage(pageName,parent) {
		if(pageName=="") 
			alert("The page name cannot be blank.");	
		else 
			h_callServer("addPage","cms-statusMessage",{pageName:pageName,parent:parent});
	}

	function deletePage(pageHREF) {
		if(confirm("Delete page from site?")) {
			h_callServer("deletePage","cms-statusMessage",{pageHREF:pageHREF});
		}
	}

	function deleteFolder(path) {
		if(confirm("Delete folder?")) {
			h_callServer("deleteFolder","cms-statusMessage",{path:path});
		}
	}

	function changeTitle(frm) {
		h_callServer("changeTitle","cms-statusMessage",{title:frm.title.value});
	}
	
	function renamePage(fldID,txtID) {
		var d = jQuery("#pageTitle");
		var title = jQuery("#sb_PageName")[0].value;
		d.html(title);
		h_callServer("renamePage","cms-statusMessage",{pageName:title});
	}	

	function updateModule(frm, props, resPrefixes, resPrefixesJs) {
		var hasFileToUpload = false;
		var params = {
				moduleID: frm.moduleID.value,
				title: frm.title.value,
				location: frm.location.value,
				moduleTemplate: frm.moduleTemplate.value,
				style: frm.style.value,
				resPrefixes: resPrefixes
		};
		
		for(var i=0;i<frm.elements.length;i++) {
			var fieldName = frm.elements[i].name;
			var fieldType = frm.elements[i].type
			var fieldValue = frm.elements[i].value
			var fieldChecked = frm.elements[i].checked

			for(var j=0;j<props.length;j++) {
				if(fieldName==props[j]) {
					if(!(fieldType=="radio" && !fieldChecked)) {
						params[props[j]] = fieldValue;
					}
				}
			}

			for(var j=0;j<resPrefixesJs.length;j++) {
				if(fieldName.substr(0,resPrefixesJs[j].length)==resPrefixesJs[j]) {
					if(fieldType == "file" && fieldValue!="") {
						hasFileToUpload = true;
					}
					if(fieldName == resPrefixesJs[j]+"__filebody" ) {
						jQuery("#"+resPrefixesJs[j]+"__filebody").htmlarea("updateTextArea");
					}
					if(fieldType=="radio")  {
						 if(fieldChecked) {
							params[fieldName] = fieldValue;
						 }
					} else {
						params[fieldName] = fieldValue;
					}
				}
			}
		}
		
		if(hasFileToUpload)
			submitFormToServer(frm,"updateModule");
		else
			h_callServer("updateModule",
							this.panelDivID,
							params		
						);
	}

	function updatePage(frm) {
		h_callServer("updatePage",
						"cms-statusMessage",
						{
							name:frm.name.value, 
							title:frm.title.value, 
							template:frm.template.value,
							description:frm.description.value,
							keywords:frm.keywords.value,
							extends:frm.extends.value
						}
					);
	}

	function updateSettings(frm) {
		h_callServer("updateSettings",
						"cms-statusMessage",
						{
							defaultPage:frm.defaultPage.value, 
							newPassword:frm.newPassword.value, 
							newPassword2:frm.newPassword2.value
						}
					);
	}
	
	function updateResource(frm,prefix) {
		var hasFileToUpload = false;
		var params = {
			resourceType:frm.resourceType.value,
			prefix: prefix
		};
		
		for(var i=0;i<frm.elements.length;i++) {
			var fieldName = frm.elements[i].name;
			var fieldType = frm.elements[i].type
			var fieldValue = frm.elements[i].value
			var fieldChecked = frm.elements[i].checked

			if(fieldName.substr(0,prefix.length)==prefix) {
				if(fieldType == "file" && fieldValue!="") {
					hasFileToUpload = true;
				}
				if(fieldName == prefix+"__filebody" ) {
					jQuery("#"+prefix+"__filebody").htmlarea("updateTextArea");
				}
				if(fieldType=="radio")  {
					 if(fieldChecked) {
						params[fieldName] = fieldValue;
					 }
				} else {
					params[fieldName] = fieldValue;
				}
			}
		}
		
		if(hasFileToUpload)
			submitFormToServer(frm,"updateResource");
		else
			h_callServer("updateResource",
							this.panelDivID,
							params		
						);
	}
	
	function deleteResource(resourceType,resourceID) {
		if(confirm("Delete resource from site?")) {
			h_callServer("deleteResource","cms-statusMessage",{resourceID:resourceID,resourceType:resourceType});
		}
	}


	// *****   Misc   ****** //
	
	function setStatusMessage(msg,timeout) {
		jQuery("#cms-statusMessage").html(msg);
	
		if(!timeout || timeout==null) timeout=4000;
		setTimeout('controlPanel.clearStatusMessage()',timeout);
	}

	function clearStatusMessage() {
		jQuery("#cms-statusMessage").empty();
	}
		
    function updateLayout() {
		var regions = jQuery('.cms-layoutRegion');
		var newLayout = "";
		for(var i=0;i<regions.length;i++) {
			var x = jQuery(regions[i]).sortable('toArray');
			var str = jQuery(regions[i]).attr('id') + '|' + x;
			newLayout = newLayout + str + ':';
		}

		for(loc in this.locations) {
			tmpNameOriginal = this.locations[loc].id + "|";	
			tmpNameTarget = this.locations[loc].name + "|";	
			newLayout = newLayout.replace(tmpNameOriginal, tmpNameTarget);
		}

		controlPanel.setStatusMessage("Updating workspace layout...");
		h_callServer("updateModuleOrder","cms-statusMessage",{layout:newLayout});
    }

	function login(frm) {
		h_callServer("login",
				"cms-statusMessage",
				{
					username:frm.username.value,
					password:frm.password.value
				}
			);		
	}
	
	function logout() {
		h_callServer("logout",
				"cms-statusMessage",
				{}
			);		
	}

	function getModuleIconsHTML(modID) {
		var tmpHTML = "<a href=\"javascript:controlPanel.deleteModule('" + modID + "');\"><img src='" + this.cmsRoot + "/images/omit-page-orange.gif' alt='Remove from page' title='Remove from page' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>";
		tmpHTML  = tmpHTML + "<a href=\"javascript:controlPanel.getView('EditModule',{moduleID:'" + modID + "'});\"><img src='" + this.cmsRoot + "/images/cog.png' alt='Edit Module' title='Edit Module' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>";
		return tmpHTML;	
	}

	function getLocationIconsHTML(id,implicitLayout) {
		var tmpHTML = "";
		if(implicitLayout==0) {
			tmpHTML  = tmpHTML + "<a href=\"javascript:controlPanel.deleteLocation('" + id + "');\"><img src='" + this.cmsRoot + "/images/omit-page-orange.gif' alt='Remove from page' title='Remove from page' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>";
			tmpHTML  = tmpHTML + "<a href=\"javascript:controlPanel.addLocation('" + id + "');\"><img src='" + this.cmsRoot + "/images/page_copy.png' alt='Add container on this region' title='Add container on this region' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>";
		}
		tmpHTML  = tmpHTML + "<a href=\"javascript:controlPanel.getView('AddContent',{locationName:'" + id + "'});\"><img src='" + this.cmsRoot + "/images/brick_add.png' alt='Add element on this region' title='Add element on this region' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>";
		return tmpHTML;	
	}
	
	function addLocation(id) {
		h_callServer("addLocation",
				"cms-statusMessage",
				{locationName:id}
			);		
	}	

	function deleteLocation(id) {
		if(confirm("Delete container '"+id+"' from page?")) {
			h_callServer("deleteLocation","cms-statusMessage",{locationName:id});
		}
	}

	function createUser(frm) {
		frm.action = controlPanel.server;
		frm.submit();
	}
	
	function createFolder(parent,name) {
		h_callServer("createFolder",
				"cms-statusMessage",
				{parent:parent,
				name:name}
			);		
	}		

	function resetApp() {
		h_callServer("resetApp",
				"cms-statusMessage",
				{}
			);		
	}		
	
	function setGlobalPageProperties(frm, props) {
		var params = {};
		for(var i=0;i<props.length;i++) {
			params["prop_"+props[i]] = frm[props[i]].value;
		}
		h_callServer("setGlobalPageProperties",
				"cms-navMenuContentPanel",
				params
			);	
	}
	
	
	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	controlPanelClient.prototype.init = init;

	controlPanelClient.prototype.closePanel = closePanel; 
	controlPanelClient.prototype.getView = getView;
	controlPanelClient.prototype.getPartialView = getPartialView;

	controlPanelClient.prototype.deleteModule = deleteModule;
	controlPanelClient.prototype.addPage = addPage;
	controlPanelClient.prototype.deletePage = deletePage;
	controlPanelClient.prototype.changeTitle = changeTitle;
	controlPanelClient.prototype.renamePage = renamePage;
	controlPanelClient.prototype.updateLayout = updateLayout;
	controlPanelClient.prototype.setStatusMessage = setStatusMessage;
	controlPanelClient.prototype.clearStatusMessage = clearStatusMessage;
	controlPanelClient.prototype.removeModuleFromLayout = removeModuleFromLayout;
	controlPanelClient.prototype.updateModule = updateModule;
	controlPanelClient.prototype.login = login;
	controlPanelClient.prototype.logout = logout;
	controlPanelClient.prototype.getModuleIconsHTML = getModuleIconsHTML;
	controlPanelClient.prototype.getLocationIconsHTML = getLocationIconsHTML;
	controlPanelClient.prototype.deleteLocation = deleteLocation;
	controlPanelClient.prototype.addLocation = addLocation;
	controlPanelClient.prototype.createUser = createUser;
	controlPanelClient.prototype.updatePage = updatePage;
	controlPanelClient.prototype.createFolder = createFolder;
	controlPanelClient.prototype.deleteFolder = deleteFolder;
	controlPanelClient.prototype.resetApp = resetApp;
	controlPanelClient.prototype.updateSettings = updateSettings;
	controlPanelClient.prototype.setGlobalPageProperties = setGlobalPageProperties;
	controlPanelClient.prototype.addContentTag = addContentTag;
	controlPanelClient.prototype.updateResource = updateResource;
	controlPanelClient.prototype.deleteResource = deleteResource;
}




function navCmdAddPage(path) {
	controlPanel.addPage('New Page',path);
}
function navCmdAddContent() {
	controlPanel.getView('AddContent')
}
function navCmdDeletePage() {
	controlPanel.deletePage(_pageFileName);
}
function navCmdLogout() {
	controlPanel.logout();
}
function navCmdLogin(frm) {
	controlPanel.login(frm);
}
function navCmdDeleteResource(resourceType,resourceID) {
	controlPanel.deleteResource(resourceType,resourceID);
}


function h_callServer(method,sec,params,rcv) {
	controlPanel.setStatusMessage("Loading...");
	
	params.method = method;
	params._pageHREF = _pageHREF;

	jQuery("#"+sec).load(controlPanel.server,
						 params,
						 function(responseText, textStatus, XMLHttpRequest) {
						    if(textStatus!='success') {alert('An error ocurred while contacting the server');}
						    if(rcv!=null) 
						    	eval(rcv);
						    else
						    	setTimeout('controlPanel.clearStatusMessage()',2000);
						 }
	);

}

function submitFormToServer(frm,method) {
	frm.action = controlPanel.server;
	frm.method.value = method;
	frm._pageHREF.value = _pageHREF;
	frm.submit();
}
