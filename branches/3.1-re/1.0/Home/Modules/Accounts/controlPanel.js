
/******************************************************/
/* controlPanel.js								   */
/*												   */
/* This javascript contains all js functions for the  */
/* client side of the HomePortals control panel.      */
/*												   */
/* (c) 2005 - CFEmpire   							   */
/*	by Oscar Arevalo - oarevalo@cfempire.com		   */
/*												   */
/******************************************************/

var editHTML = "";

function controlPanelClient() {

	// pseudo-constructor
	function init(path) {
		this.modulesRoot = path;
		this.server = this.modulesRoot + "/Accounts/controlPanel.cfc";
		this.termsAndPolicyURL = this.modulesRoot + "/Accounts/termsAndPolicy.htm";
		this.instanceName = "";	
		this.currentModuleLayout = "";
		this.currentModuleID = "";
	}

	function openEditWindow() {
		scroll(0,0);
		var d = document.getElementById("editContent_BodyRegion");
		if(!d) {
			var tmpHTML = "<div id='editContent_BodyRegion'></div>";
			new Insertion.Before("anchorAddContent",tmpHTML);
	
			if(window.innerWidth)  clientWidth = window.innerWidth;
			else if (document.body) clientWidth = document.body.clientWidth;
			
			var d = document.getElementById("editContent_BodyRegion");
			d.style.left = ((clientWidth/2)-250) + "px";
		}
	}
	
	function isEditWindowOpen() {
		var d = document.getElementById("editContent_BodyRegion");
		if(!d) 
			return false;
		else
			return true;
	}
	
	function closeEditWindow() {
		new Element.remove("editContent_BodyRegion");
	}
	
	function getView(view, args) {
		if(args==null) args = {};

		args["viewName"] = view;
			
		if(!this.isEditWindowOpen()) {
			this.openEditWindow();
			args["useLayout"] = true;
			tgt = "editContent";
		} else {
			args["useLayout"] = false;
			tgt = "cpContent";
		}

		if(view!="Page") 
			h_callServer(this.server,"getView",tgt,args);
		else
			h_callServer(this.server,"getView",tgt,args,controlPanel.initModulesView);
	}

	function getPartialView(view, args, tgt) {
		if(args==null) args = {};
		args["viewName"] = view;
		args["useLayout"] = false;
		h_callServer(this.server,"getView",tgt,args);
	}




	// *****   Views  ****** //		
	
	function getPublishPage(pageHREF) {this.getView("PublishPage",{pageHREF:pageHREF})}
	function getLogin() {this.getView("Login",{standAlone:false})}
	function getCreateAccount() {this.getView("CreateAccount",{standAlone:false})}
	function getModuleCSS(modID) { this.getPartialView("ModuleCSS",{moduleID:modID},"cp_pd_moduleProperties") }

	function editModule(modID) {
		this.currentModuleID = modID;
		this.getView("Page");
	}

	function getAddModule(modID,catID) {
		d = $("catalogModuleInfo_BodyRegion");
		d.style.display = "block";
		this.getPartialView("AddModule",{moduleID:modID,catalog:catID},"catalogModuleInfo");
	}
	
	function getCatalogModules(catalog) {
		var d = $("catalogModuleInfo_BodyRegion");
		d.style.display = "none";
		this.getPartialView("CatalogModules",{catalog: catalog},"catalogModules");
	}

	function getCatalogPages(catalog,startRow) {
		if(startRow==null) startRow=1;
		this.getPartialView("CatalogPages",{catalog: catalog,startRow:startRow},"catalogPages");
	}

	function getModuleProperties(event) {
		e = fixEvent(event);
		var modID = this.id;
		
		controlPanel.getPartialView("ModuleProperties",{moduleID: modID},"cp_pd_moduleProperties");
		
		function fixEvent(event) {
			if (typeof event == 'undefined') event = window.event;
			return event;
		}	
	}
	





	
	
	// *****   Actions ****** //

	function addModule(frm) {
		this.openEditWindow();
		var modID = frm.moduleID.value;
		var locID = frm.locationID.value;
		var catID = frm.catalog.value;
		h_callServer(this.server,"addModule","cpContent",{moduleID:modID,locationID:locID,catalog:catID});
	}
	
	function saveModule(frm) {
		this.openEditWindow();
		var params = {};
		for(i=0;i<frm.length;i++) {
			if(frm[i].name!="") {
				if(frm[i].type=="checkbox")
					params[frm[i].name] = frm[i].checked;
				else
					params[frm[i].name] = frm[i].value;
			}
		}
		h_callServer(this.server, "saveModule", "cp_status", params);
	}		

	function deleteModule(modID) {
		this.openEditWindow();
		h_callServer(this.server, "deleteModule", "cpContent", {moduleID:modID});
	}		
	
	function addPage(pageName,pageHREF) {
		if(pageHREF==undefined || pageHREF==null) pageHREF="";

		if(pageName=="" && pageHREF=="")
			alert("The page name cannot be blank.");	
		else {
			this.openEditWindow();
			h_callServer(this.server,"addPage","cp_status",{pageName:pageName,pageHREF:pageHREF});
		}
	}
	
	function addPageFromCatalog(page,catalog,title) {
		this.openEditWindow();
		var params = {pageHREF: page,	
					  catalogHREF: catalog};	
		if(confirm("Add \"" + title + "\" to this site?"))
			h_callServer(this.server, "addPageFromCatalog", "cp_status", params);
	}
	
	function deletePage(pageHREF) {
		this.openEditWindow();
		if(confirm("Delete page from site?"))
			h_callServer(this.server,"deletePage","cp_status",{pageHREF:pageHREF});
	}
	
	function saveProperty(frm) { 
		this.openEditWindow();
		var params = {}

		for(p in frm) {
			pn = p.substr(9,p.length);
			if(p.substr(0,9)=="property_") {
				params[pn] = frm[p].value;
			}
		}
		h_callServer(this.server,"saveProperty","cp_status",params);
		this.closeEditProperty();
	}
	
	function deleteProperty(type,index) { 
		if(confirm("Delete property?")) {
			this.openEditWindow();
			h_callServer(this.server,"deleteProperty","cp_status",{property_type:type,property_index:index});
		}
	}

	function changeTitle(frm) {
		this.openEditWindow();
		h_callServer(this.server,"changeTitle","cp_status",{title:frm.title.value});
	}
	
	function changePrivate(frm) {
		this.openEditWindow();
		h_callServer(this.server,"changePrivate","cp_status",{isPrivate:frm.isPrivate.checked});
	}

	function changeDefault(frm) {
		this.openEditWindow();
		h_callServer(this.server,"changeDefault","cp_status",{isDefault:frm.isDefault.checked});
	}

	function addCatalog(frm) {
		this.openEditWindow();
		h_callServer(this.server,"addCatalog","cp_status",{href:frm.href.value}, controlPanel.getSiteCatalogs);
	}
	
	function removeCatalog(href) {
		if(confirm("Remove catalog?")) {
			this.openEditWindow();
			h_callServer(this.server,"removeCatalog","cp_status",{href:href}, controlPanel.getSiteCatalogs);
		}
	}
	
	function publishPage(frm) {
		this.openEditWindow();
		var params = {catalog: frm.catalog.value,	
					 description: frm.description.value,
					 pageHREF: frm.pageHREF.value};
		h_callServer(this.server,"publishPage","cp_status",params);
	}

	function doLogin(frm) {
		var params = {username: frm.username.value,	
						password: frm.password.value,
						rememberMe: frm.rememberMe.checked};
		h_callServer(this.server,"doLogin","loginMsg",params);
	}

	function doCreateAccount(frm) {
		var msg = "";

		if(frm.username.value=="") msg = "Please select a username";
		if(frm.password.value=="") msg = "Please enter a password";
		if(frm.password2.value=="") msg = "Please confirm your password";
		if(frm.email.value=="") msg = "Please enter your email address";
		if(!frm.agree.checked) msg = "You must agree to the terms and conditions before creating an account";

		if(msg=="") {
			var params = {username: frm.username.value,	
							password: frm.password.value,
							password2: frm.password2.value,
							email: frm.email.value
							};
			h_callServer(this.server, "doCreateAccount", "loginMsg", params);
		} else {
			alert(msg);
		}
	}

	function doLogoff(target) {
		h_callServer(this.server,"doLogoff",target);
	}
	
	function addPageToCurrentUser(page,catalog) {
		if(confirm("Add " + page + " to your site?")) {
			this.openEditWindow();	
			var params = {catalog: catalog, page: page};
			h_callServer(this.server,"addPageToCurrentUser","cpContent",params);
		}
	}

	function selectSkin(href) {
		if(href!="") {
			this.openEditWindow();	
			var params = {skinHREF: href};
			h_callServer(this.server,"selectSkin","cpContent",params);
		}
	}
		
	function sendFeedback(frm) {
		openEditWindow();
		h_callServer(this.server,"sendFeedback","cpContent",{comments:frm.comments.value});
	}

	function updateModuleOrder() {
		var newLayout = DragDrop.serData('g1');
		if(this.currentModuleLayout != newLayout) {
			h_callServer(this.server,"updateModuleOrder","cp_status",{layout:newLayout});
		}
	}

	function renamePage(frm) {
		this.openEditWindow();
		h_callServer(this.server,"renamePage","cp_status",{pageName:frm.pageName.value});
	}	
	
	function savePageCSS(frm) {
		this.openEditWindow();
		h_callServer(this.server,"savePageCSS","cp_status",{content:frm.cssContent.value});
	}






	// *****   Misc   ****** //
	
	function closeAddModule() {
		d = $("catalogModuleInfo_BodyRegion");
		d.style.display = "none";
	}
	
	function showPageConfigSec(secID) {
		// select tab on menu
		d=$("pnl_menu");
		if(d) {
			aTabs = d.getElementsByTagName("a");
			for(var i=0;i<aTabs.length;i++) {
				if(aTabs[i].id == secID + "Tab") {
					aTabs[i].style.backgroundColor = "#990000";
					aTabs[i].childNodes[0].style.color= "white";
				} else {
					aTabs[i].style.backgroundColor = "";
					aTabs[i].childNodes[0].style.color= "";
				}
			}
		}
		
		// hide all sections
		new Element.hide("pnl_intro","pnl_stylesheets","pnl_scripts","pnl_layouts","pnl_eventListeners");
		
		// show selected section
		if(secID!="") new Element.show(secID);
		
		// make sure the edit property panel is closed
		this.closeEditProperty();
	}
	
	function openEditProperty(type,index) { 
		this.closeEditProperty();
		var tmpHTML = "<div id='editProperty_BodyRegion'></div>";
		new Insertion.After("cp_props_edit",tmpHTML);
		this.getPartialView("EditPageProperty",{type:type,index:index},"editProperty");
	}
	
	function closeEditProperty() { 
		if($("editProperty_BodyRegion")) new Element.remove("editProperty_BodyRegion");
	}

	function getTermsAndPolicy(name) {
		window.open(this.termsAndPolicyURL+'#'+name,'info','width=500,height=500,scrollbars=1');
	}
		
	function setStatusMessage(msg) {
		var s = $("cp_status_BodyRegion");
		s.innerHTML = msg;
		setTimeout('controlPanel.clearStatusMessage()',2000);
	}

	function clearStatusMessage() {
		var s = $("cp_status_BodyRegion");
		s.innerHTML = "";
	}
		
	function initModulesView() {
		try {
			var lists = document.getElementsByClassName("layoutPreviewList");
	
			// clear all containers
			DragDrop.firstContainer = null;
			DragDrop.lastContainer = null;
			DragDrop.parent_id = null;
			DragDrop.parent_group = null;
	
			for(i=0;i<lists.length;i++) {
				// declare list as sortable
				list = document.getElementById(lists[i].id);
				DragDrop.makeListContainer( list , "g1");
				list.onDragOver = function() { this.style["background"] = "#EEF"; };
				list.onDragOut = function() {this.style["background"] = "none"; };
				list.onDragDrop = function() {controlPanel.updateModuleOrder(); };
				
				// add onclick event to list items
				items = list.getElementsByTagName( "li" );
				for (var j = 0; j < items.length; j++) {
					items[j].onclick = controlPanel.getModuleProperties;
				}
			}
	
			controlPanel.currentModuleLayout = DragDrop.serData('g1');
			controlPanel.getCatalogModules("");
			
			if(controlPanel.currentModuleID!="")
				controlPanel.getPartialView("ModuleProperties",{moduleID: controlPanel.currentModuleID},"cp_pd_moduleProperties");
		} catch(e) {
			alert(e);
		}
	}
	

	

	
	
	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	controlPanelClient.prototype.init = init;

	controlPanelClient.prototype.openEditWindow = openEditWindow;
	controlPanelClient.prototype.closeEditWindow = closeEditWindow; 
	controlPanelClient.prototype.isEditWindowOpen = isEditWindowOpen;
	controlPanelClient.prototype.getView = getView;
	controlPanelClient.prototype.getPartialView = getPartialView;

	controlPanelClient.prototype.getAddModule = getAddModule;
	controlPanelClient.prototype.getModuleCSS = getModuleCSS;
	controlPanelClient.prototype.getModuleProperties = getModuleProperties;
	controlPanelClient.prototype.getPublishPage = getPublishPage;
	controlPanelClient.prototype.getLogin = getLogin;
	controlPanelClient.prototype.getCreateAccount = getCreateAccount;
	controlPanelClient.prototype.getTermsAndPolicy = getTermsAndPolicy;
	controlPanelClient.prototype.getCatalogPages = getCatalogPages;
	controlPanelClient.prototype.getCatalogModules = getCatalogModules;

	controlPanelClient.prototype.closeAddModule = closeAddModule;
	controlPanelClient.prototype.addModule = addModule;
	controlPanelClient.prototype.editModule = editModule;
	controlPanelClient.prototype.saveModule = saveModule;
	controlPanelClient.prototype.deleteModule = deleteModule;
	controlPanelClient.prototype.addPage = addPage;
	controlPanelClient.prototype.addPageFromCatalog = addPageFromCatalog;
	controlPanelClient.prototype.deletePage = deletePage;
	controlPanelClient.prototype.showPageConfigSec = showPageConfigSec;
	controlPanelClient.prototype.openEditProperty = openEditProperty;
	controlPanelClient.prototype.closeEditProperty = closeEditProperty;
	controlPanelClient.prototype.saveProperty = saveProperty;
	controlPanelClient.prototype.deleteProperty = deleteProperty;
	controlPanelClient.prototype.changeTitle = changeTitle;
	controlPanelClient.prototype.changePrivate = changePrivate;
	controlPanelClient.prototype.changeDefault = changeDefault;
	controlPanelClient.prototype.renamePage = renamePage;
	controlPanelClient.prototype.addCatalog = addCatalog;
	controlPanelClient.prototype.removeCatalog = removeCatalog;
	controlPanelClient.prototype.publishPage = publishPage;
	controlPanelClient.prototype.doLogin = doLogin;
	controlPanelClient.prototype.doLogoff = doLogoff;
	controlPanelClient.prototype.doCreateAccount = doCreateAccount;
	controlPanelClient.prototype.addPageToCurrentUser = addPageToCurrentUser;
	controlPanelClient.prototype.selectSkin = selectSkin;
	controlPanelClient.prototype.sendFeedback = sendFeedback;
	controlPanelClient.prototype.initModulesView = initModulesView;
	controlPanelClient.prototype.updateModuleOrder = updateModuleOrder;
	controlPanelClient.prototype.setStatusMessage = setStatusMessage;
	controlPanelClient.prototype.clearStatusMessage = clearStatusMessage;
	controlPanelClient.prototype.savePageCSS = savePageCSS;
}


function loginClient() {
	// properties
	this.server = "/Home/Modules/Accounts/controlPanel.cfc";
	this.contentID = "";
	this.instanceName = "";
	
	function getLogin() {
		h_callServer(this.server, "getLogin", this.contentID,{useLayout:false});
	}
	function getCreateAccount() {
		h_callServer(this.server, "getCreateAccount", this.contentID,{useLayout:false});
	}
	function getAccountWelcome() {
		h_callServer(this.server, "getAccountWelcome", this.contentID,{useLayout:false});
	}
	function doCreateAccount(frm) {
		var msg = "";

		if(frm.username.value=="") msg = "Please select a username";
		if(frm.password.value=="") msg = "Please enter a password";
		if(frm.password2.value=="") msg = "Please confirm your password";
		if(frm.email.value=="") msg = "Please enter your email address";
		if(!frm.agree.checked) msg = "You must agree to the terms and conditions before creating an account";

		if(msg=="") {
			var params = {username: frm.username.value,	
							password: frm.password.value,
							password2: frm.password2.value,
							email: frm.email.value
							};
			h_callServer(this.server, "doCreateAccount", this.contentID, params);
		} else {
			alert(msg);
		}
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	loginClient.prototype.getLogin = getLogin;	
	loginClient.prototype.getCreateAccount = getCreateAccount;	
	loginClient.prototype.doCreateAccount = doCreateAccount;
	loginClient.prototype.getAccountWelcome = getAccountWelcome;
}
