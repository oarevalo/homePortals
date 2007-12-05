
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
		closeAddContentPanel();
		var c = document.getElementById("editContent_BodyRegion");
		if(!d) {
			var tmpHTML = "<div id='editContent_BodyRegion'></div>";
			new Insertion.Before("anchorAddContent",tmpHTML);
	
			if(window.innerWidth)  clientWidth = window.innerWidth;
			else if (document.body) clientWidth = document.body.clientWidth;
			
			var d = document.getElementById("editContent_BodyRegion");
			d.style.left = ((clientWidth/2)-250) + "px";
			d.style.top = "50px";
			d.style.marginTop = "20px";
			
			Drag.makeDraggable(d);
		}
	}
	
	function isEditWindowOpen() {
		var d= document.getElementById("editContent_BodyRegion");
		if(!d) 
			return false;
		else
			return true;
	}
	
	function closeEditWindow() {
		if($("editContent_BodyRegion")) 
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

	function openAddContentPanel() {
		scroll(0,0);
		closeEditWindow();
		var d = document.getElementById("addContent_BodyRegion");
		if(!d) {
			var tmpHTML = "<div id='addContent_BodyRegion'></div>";
			new Insertion.Before("anchorAddContent",tmpHTML);
	
			if(window.innerWidth)  clientWidth = window.innerWidth;
			else if (document.body) clientWidth = document.body.clientWidth;

			if(window.innerHeight)  clientHeight = window.innerHeight;
			else if (document.body) clientHeight = document.body.clientHeight;
			
			var d = document.getElementById("addContent_BodyRegion");
			d.style.position = "absolute";
			d.style.width = "300px"
			d.style.height = "300px"
			d.style.top = "50px";
			d.style.left = (clientWidth/2)+20 + "px";
			d.style.backgroundColor = "#fff";
			d.style.border = "1px solid black";
			d.style.color = "black";
			d.style.textAlign = "left";
			d.style.marginTop = "20px";
			d.style.padding = "0px";
			
			//d.onclick = function() {new Element.remove("addContent_BodyRegion");};
			this.getPartialView('AddContent',{},'addContent');
			Drag.makeDraggable(d);
		} else {
			closeAddContentPanel();
		}
	}
	function closeAddContentPanel() {
		if($("addContent_BodyRegion")) 
			new Element.remove("addContent_BodyRegion");	
	}

	// *****   Views  ****** //		
	
	function getPublishPage(pageHREF) {this.getView("PublishPage",{pageHREF:pageHREF})}
	function getLogin() {this.getView("Login")}
	function getCreateAccount() {this.getView("CreateAccount")}
	function getModuleCSS(modID) { this.getPartialView("ModuleCSS",{moduleID:modID},"cp_pd_moduleProperties") }

	function editModule(modID) {
		this.currentModuleID = modID;
		this.getView("Page");
	}

	function getAddModule(modID) {
		d = $("catalogModuleInfo_BodyRegion");
		d.style.display = "block";
		this.getPartialView("AddModule",{moduleID:modID},"catalogModuleInfo");
	}
	
	function getCatalogModules() {
		var d = $("catalogModuleInfo_BodyRegion");
		d.style.display = "none";
		this.getPartialView("CatalogModules",{},"catalogModules");
	}

	function getModuleProperties(event) {
		e = fixEvent(event);
		var modID = this.id;

		var items = document.getElementsByClassName("layoutListItem");
		for(var i=0;i<items.length;i++) {
			items[i].style.backgroundColor = "#eee";
		}
		$(modID).style.backgroundColor = "#fefcd8";
			
		// remove the '_lp' at the end of the element ID name
		modID = modID.substring(0, modID.length-3);
		
		controlPanel.getPartialView("ModuleProperties",{moduleID: modID},"cp_pd_moduleProperties");
		
		function fixEvent(event) {
			if (typeof event == 'undefined') event = window.event;
			return event;
		}	
	}
	





	
	
	// *****   Actions ****** //

	function addModule(frm) {
		var modID = frm.moduleID.value;
		var locID = frm.locationID.value;
		
		if(isEditWindowOpen()) {
			h_callServer(this.server,"addModule","cpContent",{moduleID:modID,locationID:locID});
		} else {
			h_callServer(this.server,"addModule","addContent",{moduleID:modID,locationID:locID,reloadAfterAddModule:true});
		}
	}

	function addModule2(modID, locID) {
		if(isEditWindowOpen()) {
			h_callServer(this.server,"addModule","cpContent",{moduleID:modID,locationID:locID});
		} else {
			h_callServer(this.server,"addModule","addContent",{moduleID:modID,locationID:locID,reloadAfterAddModule:true});
		}
	}
	
	function saveModule(frm) {
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
		if(confirm('Are you sure you wish to delete this module?'))
			h_callServer(this.server, "deleteModule", "cp_status", {moduleID:modID});
	}		
	function removeModuleFromLayout(modID) {
		var m1 = $(modID);
		var m2 = $(modID+"_lp");
		if(m1) new Element.remove(modID);
		if(m2) new Element.remove(modID+"_lp");
		controlPanel.currentModuleID = "";
		controlPanel.getView('Page');
	}
	
	function addPage(pageName,pageHREF) {
		if(pageHREF==undefined || pageHREF==null) pageHREF="";

		if(pageName=="" && pageHREF=="")
			alert("The page name cannot be blank.");	
		else {
			if(isEditWindowOpen()) {
				h_callServer(this.server,"addPage","cp_status",{pageName:pageName,pageHREF:pageHREF});
			} else {
				this.openEditWindow();
				h_callServer(this.server,"addPage","editContent",{pageName:pageName,pageHREF:pageHREF});
			}
		}
	}

	function deletePage(pageHREF) {
		if(confirm("Delete page from site?")) {
			if(isEditWindowOpen()) {
				h_callServer(this.server,"deletePage","cp_status",{pageHREF:pageHREF});
			} else {
				h_callServer(this.server,"deletePage","anchorAddContent",{pageHREF:pageHREF});
			}			
		}
	}
	
	function saveProperty(frm) { 
		//this.openEditWindow();
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
			h_callServer(this.server,"deleteProperty","cp_status",{property_type:type,property_index:index});
		}
	}

	function addEventHandler(frm) {
		params = {
			eventName: frm.eventName.value,
			eventHandler: frm.eventHandler.value
		}
		if(frm.eventName.value!='' && frm.eventHandler.value!='')
			h_callServer(this.server,"addEventHandler","cp_status",params);
		else
			alert("To add an event handler, you must select both an event and an action");
	}

	function deleteEventHandler(index) { 
		if(confirm("Delete event handler?")) {
			h_callServer(this.server,"deleteEventHandler","cp_status",{index:index});
		}
	}

	function changeTitle(frm) {
		//this.openEditWindow();
		h_callServer(this.server,"changeTitle","cp_status",{title:frm.title.value});
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
	
	function selectSkin(href) {
		if(!href || href==null || href==undefined) href="";
		this.openEditWindow();	
		var params = {skinHREF: href};
		h_callServer(this.server,"selectSkin","cpContent",params);
	}
		
	function sendFeedback(frm) {
		openEditWindow();
		h_callServer(this.server,"sendFeedback","cpContent",{comments:frm.comments.value});
	}

	function renamePage(frm) {
		h_callServer(this.server,"renamePage","cp_status",{pageName:frm.pageName.value});
	}	
	function savePageCSS(frm) {
		h_callServer(this.server,"savePageCSS","cp_status",{content:frm.cssContent.value});
	}
	function movePageUp(pageHREF) {
		h_callServer(this.server,"movePageUp","cp_status",{pageHREF:pageHREF});
	}
	function movePageDown(pageHREF) {
		h_callServer(this.server,"movePageDown","cp_status",{pageHREF:pageHREF});
	}
	function setDefaultPage(pageHREF) {
		h_callServer(this.server,"setDefaultPage","cp_status",{pageHREF:pageHREF});
	}
	function setPagePrivacyStatus(pageHREF,isPrivate) {
		h_callServer(this.server,"setPagePrivacyStatus","cp_status",{pageHREF:pageHREF,isPrivate:isPrivate});
	}
	function setSiteTitle(title) {
		h_callServer(this.server,"setSiteTitle","cp_status",{title:title});
	}
	function setPageNavStatus(pageHREF,showInNav) {
		h_callServer(this.server,"setPageNavStatus","cp_status",{pageHREF:pageHREF,showInNav:showInNav});
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
		if(s) s.innerHTML = msg;
		setTimeout('controlPanel.clearStatusMessage()',2000);
	}

	function clearStatusMessage() {
		var s = $("cp_status_BodyRegion");
		if(s) s.innerHTML = "";
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

			// add drag from module list
			var modulesList = $("ModulesList");
			if(modulesList) {
				DragDrop.makeListContainer( modulesList , "g1");
				modulesList.onDragOver = function() { this.style["background"] = "#EEF"; };
				modulesList.onDragOut = function() {this.style["background"] = "none"; };
				modulesList.onDragDrop = function() {controlPanel.returnToModuleList();};
			}
			
			h_clearLoadingImg();
			
			if(controlPanel.currentModuleID!="")
				controlPanel.getPartialView("ModuleProperties",{moduleID: controlPanel.currentModuleID},"cp_pd_moduleProperties");

		} catch(e) {
			alert("initModulesView:" + e);
		}
	}
	
	function returnToModuleList() {
		var items = DragDrop.lastContainer.getElementsByTagName( "li" );
		for(var i=0;i<items.length;i++) {
			e = items[i].id;
			if(e.substr(e.length-3)=="_lp") {
				modID = e.substr(0,e.length-3);
				controlPanel.deleteModule(modID);
				controlPanel.getCatalogModules();
			}
		}		
	}

	
	function updateModuleOrder() {
		
		var container = DragDrop.firstContainer;
		var j = 0;
		var string = "";
            
		while (container != null) {
			if(container.id!="ModulesList") {
				var items = container.getElementsByTagName( "li" );
				for(var i=0;i<items.length;i++) {
					e = items[i].id;
					if(e.substr(e.length-4)=="_add") {
						modID = e.substr(0,e.length-4);
						controlPanel.addModule2(modID, container.id);
						return
					}
				}
			}
			container = container.nextContainer;
		}		
		
		var newLayout = DragDrop.serData('g1');
		if(this.currentModuleLayout != newLayout) {
			h_callServer(this.server,"updateModuleOrder","cp_status",{layout:newLayout});
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
	controlPanelClient.prototype.getLogin = getLogin;
	controlPanelClient.prototype.getCreateAccount = getCreateAccount;
	controlPanelClient.prototype.getTermsAndPolicy = getTermsAndPolicy;
	controlPanelClient.prototype.getCatalogModules = getCatalogModules;

	controlPanelClient.prototype.closeAddModule = closeAddModule;
	controlPanelClient.prototype.addModule = addModule;
	controlPanelClient.prototype.addModule2 = addModule2;
	controlPanelClient.prototype.editModule = editModule;
	controlPanelClient.prototype.saveModule = saveModule;
	controlPanelClient.prototype.deleteModule = deleteModule;
	controlPanelClient.prototype.addPage = addPage;
	controlPanelClient.prototype.deletePage = deletePage;
	controlPanelClient.prototype.showPageConfigSec = showPageConfigSec;
	controlPanelClient.prototype.openEditProperty = openEditProperty;
	controlPanelClient.prototype.closeEditProperty = closeEditProperty;
	controlPanelClient.prototype.saveProperty = saveProperty;
	controlPanelClient.prototype.deleteProperty = deleteProperty;
	controlPanelClient.prototype.changeTitle = changeTitle;
	controlPanelClient.prototype.renamePage = renamePage;
	controlPanelClient.prototype.doLogin = doLogin;
	controlPanelClient.prototype.doLogoff = doLogoff;
	controlPanelClient.prototype.doCreateAccount = doCreateAccount;
	controlPanelClient.prototype.selectSkin = selectSkin;
	controlPanelClient.prototype.sendFeedback = sendFeedback;
	controlPanelClient.prototype.initModulesView = initModulesView;
	controlPanelClient.prototype.updateModuleOrder = updateModuleOrder;
	controlPanelClient.prototype.setStatusMessage = setStatusMessage;
	controlPanelClient.prototype.clearStatusMessage = clearStatusMessage;
	controlPanelClient.prototype.savePageCSS = savePageCSS;
	controlPanelClient.prototype.openAddContentPanel = openAddContentPanel;
	controlPanelClient.prototype.closeAddContentPanel = closeAddContentPanel;
	controlPanelClient.prototype.movePageUp = movePageUp;
	controlPanelClient.prototype.movePageDown = movePageDown;
	controlPanelClient.prototype.setDefaultPage = setDefaultPage;
	controlPanelClient.prototype.setPagePrivacyStatus = setPagePrivacyStatus;
	controlPanelClient.prototype.setSiteTitle = setSiteTitle;
	controlPanelClient.prototype.setPageNavStatus = setPageNavStatus;
	controlPanelClient.prototype.addEventHandler = addEventHandler;
	controlPanelClient.prototype.deleteEventHandler = deleteEventHandler;
	controlPanelClient.prototype.removeModuleFromLayout = removeModuleFromLayout;
	controlPanelClient.prototype.returnToModuleList = returnToModuleList;
}

