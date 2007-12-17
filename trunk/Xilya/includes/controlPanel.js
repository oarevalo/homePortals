
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
var _pageHREF = "";

function controlPanelClient() {

	// pseudo-constructor
	function init(lstLocations) {
		this.server = "/xilya/includes/controlPanelGateway.cfm";
		this.termsAndPolicyURL = "/xilya/includes/termsAndPolicy.htm";
		this.instanceName = "";	
		this.currentModuleLayout = "";
		this.currentModuleID = "";
		this.locations = lstLocations;
		this.tempHTML = "";
		this.currentTextID = "";
	}

	function openEditWindow() {
		scroll(0,0);
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


	// *****   Views  ****** //		
	
	function getAddModule(modID) {
		d = $("catalogModuleInfo_BodyRegion");
		d.style.display = "block";
		this.getPartialView("AddModule",{moduleID:modID},"catalogModuleInfo");
	}
	
	
	
	// *****   Actions ****** //

	function addModule(frm) {
		var modID = frm.moduleID.value;
		var locID = frm.locationID.value;

		controlPanel.setStatusMessage("Adding module to workspace...");
		h_callServer(this.server,"addModule","siteMapStatusBar",{moduleID:modID,locationID:locID,reloadAfterAddModule:true});
	}

	function deleteModule(modID) {
		if(confirm('Are you sure you wish to delete this module?')) {
			h_callServer(this.server, "deleteModule", "siteMapStatusBar", {moduleID:modID});
		}
	}		
	
	function removeModuleFromLayout(modID) {
		var m1 = $(modID);
		var m2 = $(modID+"_lp");
		if(m1) new Element.remove(modID);
		if(m2) new Element.remove(modID+"_lp");
		controlPanel.currentModuleID = "";
	}
	
	function addPage(pageName,pageHREF) {
		if(pageHREF==undefined || pageHREF==null) pageHREF="";

		if(pageName=="" && pageHREF=="")
			alert("The page name cannot be blank.");	
		else {
			h_callServer(this.server,"addPage","siteMapStatusBar",{pageName:pageName,pageHREF:pageHREF});
		}
	}

	function deletePage(pageHREF) {
		if(confirm("Delete page from site?")) {
			h_callServer(this.server,"deletePage","siteMapStatusBar",{pageHREF:pageHREF});
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
		h_callServer(this.server,"changeTitle","siteMapStatusBar",{title:frm.title.value});
	}
	
	function doLogoff(target) {
		h_callServer(this.server,"doLogoff",target);
	}
	
	function sendFeedback(frm) {
		openEditWindow();
		h_callServer(this.server,"sendFeedback","cpContent",{comments:frm.comments.value});
	}

	function renamePage(title) {
		var d = $(this.currentTextID);
		d.innerHTML = this.tempHTML;
		if(this.tempHTML != title) {
			d.innerHTML = title;
			h_callServer(this.server,"renamePage","siteMapStatusBar",{pageName:title});
		}
	}	
	function renameSite(title) {
		var d = $(this.currentTextID);
		d.innerHTML = this.tempHTML;
		if(this.tempHTML != title) {
			d.innerHTML = title;
			h_callServer(this.server,"setSiteTitle","siteMapStatusBar",{title:title});
		}
	}

	function applyPageTemplate(frm) {
		var resourceID = "";
		for (var i=0; i<frm.layout.length; i++)  {
			if (frm.layout[i].checked)  {
				resourceID = frm.layout[i].value
			}
		}
		h_callServer(this.server,"applyPageTemplate","siteMapStatusBar",{resourceID:resourceID});
	}
		
	function setPageAccess(accessType) {
		h_callServer(this.server,"setPageAccess","siteMapStatusBar",{accessType:accessType});
	}			



	// *****   Misc   ****** //
	
	function closeAddModule() {
		d = $("catalogModuleInfo_BodyRegion");
		if(d) d.style.display = "none";
	}
			
	function setStatusMessage(msg,timeout) {
		var s1 = $("cp_status_BodyRegion");
		var s2 = $("siteMapStatusBar_BodyRegion");

		if(s1) s1.innerHTML = msg;
		if(s2) s2.innerHTML = msg;
	
		if(!timeout || timeout==null) timeout=2000;
		setTimeout('controlPanel.clearStatusMessage()',timeout);
	}

	function clearStatusMessage() {
		var s1 = $("cp_status_BodyRegion");
		var s2 = $("siteMapStatusBar_BodyRegion");
		if(s1) s1.innerHTML = "";
		if(s2) s2.innerHTML = "";
	}
		
    function updateLayout() {
		var container = DragDrop.firstContainer;
		var j = 0;
		var string = "";	
		
		var newLayout = DragDrop.serData('main');

		for(loc in this.locations) {
			tmpNameOriginal = this.locations[loc].id + "|";	
			tmpNameTarget = this.locations[loc].name + "|";	
			newLayout = newLayout.replace(tmpNameOriginal, tmpNameTarget);
		}

		controlPanel.setStatusMessage("Updating workspace layout...");
		h_callServer(this.server,"updateModuleOrder","siteMapStatusBar",{layout:newLayout});
    }
	
	function insertModule(modID, locID) {
		var tmpHTML = "<div class='Section' id='" + modID + "'>"
						+ "<div class='SectionTitle' id='" + modID + "_Head'>"
							+ "<h2>"
								+ getModuleIconsHTML(modID) 
								+ "<div class='SectionTitleLabel' id='" + modID + "_Title'>" + modID + "</div>"
							+ "</h2>"
						+ "</div>"
						+ "<div class='SectionBody' id='" + modID + "_Body'>"
							+ "<div class='SectionBodyRegion' id='" + modID + "_BodyRegion'>Module Content</div>"
						+ "</div>"
					+ "</div>"	
		
		new Insertion.Bottom(locID,tmpHTML);
		
		eval(modID + "= new moduleClient()");
		eval(modID + ".init('" + modID + "')");
		eval(modID + ".getView()");
		
		startDragDrop();
	}
	
	
	function rename(txtID,title,type) {
		var fldID = "sb_" + type + "Name";
		var func = "controlPanel.rename" + type + "(this.value)";
		var d = $(txtID);
		this.currentTextID = txtID;
		this.tempHTML = d.innerHTML;
		d.innerHTML = "<input type='text' id='" + fldID + "' value='" + title + "' class='inlineTextbox' onblur='" + func + "'>";
		$(fldID).focus();
	}
		
	function addFeed(feedURL, feedTitle) {
		h_callServer(this.server,"addFeed","siteMapStatusBar",{feedURL:feedURL, feedTitle:feedTitle});
	}			

	function addContent(contentID) {
		h_callServer(this.server,"addContent","siteMapStatusBar",{contentID:contentID});
	}			


	function addToMyFeeds(frm) {
		h_callServer(this.server,"addToMyFeeds","siteMapStatusBar",{rssURL:frm.rssURL.value, feedName:frm.feedName.value, access:getRadioButtonValue(frm.access), description:frm.description.value});
	}

	function removeFromMyFeeds(id) {
		if(confirm("Remove this feed from your feeds directory"))
			h_callServer(this.server,"removeFromMyFeeds","siteMapStatusBar",{id:id});
	}

	function addToMyContent(frm) {
		h_callServer(this.server,"addToMyContent","siteMapStatusBar",{contentName:frm.contentName.value, access:getRadioButtonValue(frm.access), description:frm.description.value, body:frm.body.value});
	}

	function removeFromMyContent(id) {
		if(confirm("Remove this content from your content directory?"))
			h_callServer(this.server,"removeFromMyContent","siteMapStatusBar",{id:id});
	}

	function setResourceAccess(resourceType, id, access) {
		h_callServer(this.server,"setResourceAccess","siteMapStatusBar",{resourceType:resourceType,id:id,access:access});
	}

	
	function addFriend(accountName) { h_callServer(this.server,"addFriend","siteMapStatusBar",{accountName:accountName}); }	
	function inviteFriend(email) { h_callServer(this.server,"inviteFriend","siteMapStatusBar",{email:email}); }	
	function removeFriend(accountName) { 
		if(confirm("Remove " + accountName + " from your friends?"))
			h_callServer(this.server,"removeFriend","siteMapStatusBar",{accountName:accountName}); 
	}	
	function acceptFriendRequest(sender) {	h_callServer(this.server,"acceptFriendRequest","siteMapStatusBar",{sender:sender}); }	
	function rejectFriendRequest(sender) {	h_callServer(this.server,"rejectFriendRequest","siteMapStatusBar",{sender:sender}); }	
	
	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	controlPanelClient.prototype.init = init;

	controlPanelClient.prototype.openEditWindow = openEditWindow;
	controlPanelClient.prototype.closeEditWindow = closeEditWindow; 
	controlPanelClient.prototype.isEditWindowOpen = isEditWindowOpen;
	controlPanelClient.prototype.getView = getView;
	controlPanelClient.prototype.getPartialView = getPartialView;

	controlPanelClient.prototype.getAddModule = getAddModule;
	controlPanelClient.prototype.closeAddModule = closeAddModule;

	controlPanelClient.prototype.addModule = addModule;
	controlPanelClient.prototype.deleteModule = deleteModule;
	controlPanelClient.prototype.addPage = addPage;
	controlPanelClient.prototype.deletePage = deletePage;
	controlPanelClient.prototype.changeTitle = changeTitle;
	controlPanelClient.prototype.renamePage = renamePage;
	controlPanelClient.prototype.doLogoff = doLogoff;
	controlPanelClient.prototype.sendFeedback = sendFeedback;
	controlPanelClient.prototype.updateLayout = updateLayout;
	controlPanelClient.prototype.setStatusMessage = setStatusMessage;
	controlPanelClient.prototype.clearStatusMessage = clearStatusMessage;
	controlPanelClient.prototype.renameSite = renameSite;
	controlPanelClient.prototype.addEventHandler = addEventHandler;
	controlPanelClient.prototype.deleteEventHandler = deleteEventHandler;
	controlPanelClient.prototype.removeModuleFromLayout = removeModuleFromLayout;
	controlPanelClient.prototype.insertModule = insertModule;
	controlPanelClient.prototype.rename = rename;
	controlPanelClient.prototype.applyPageTemplate = applyPageTemplate;
	controlPanelClient.prototype.setPageAccess = setPageAccess;
	
	controlPanelClient.prototype.addFeed = addFeed;
	controlPanelClient.prototype.addContent = addContent;
	controlPanelClient.prototype.addToMyFeeds = addToMyFeeds;
	controlPanelClient.prototype.removeFromMyFeeds = removeFromMyFeeds;
	controlPanelClient.prototype.addToMyContent = addToMyContent;
	controlPanelClient.prototype.removeFromMyContent = removeFromMyContent;
	controlPanelClient.prototype.setResourceAccess = setResourceAccess;

	controlPanelClient.prototype.addFriend = addFriend;
	controlPanelClient.prototype.inviteFriend = inviteFriend;
	controlPanelClient.prototype.removeFriend = removeFriend;
	controlPanelClient.prototype.acceptFriendRequest = acceptFriendRequest;
	controlPanelClient.prototype.rejectFriendRequest = rejectFriendRequest;
}


function startDragDrop() {
    DragDrop.tag = "div";
    DragDrop.theClass = "Section";
    DragDrop.firstContainer = null;
    DragDrop.lastContainer = null;
    DragDrop.parent_id = null;
    DragDrop.parent_group = null;

	controlPanel.setStatusMessage("Enabling draggable modules...",1000);

	for(loc in controlPanel.locations) {
        layoutSection = $(controlPanel.locations[loc].id);
        if(layoutSection) {
	        DragDrop.makeListContainer( layoutSection , "main");
	        layoutSection.onDragOver = function() { this.style["background"] = "#f5f5f5"; this.style["border"] = "0";};
	        layoutSection.onDragOut = function() {this.style["background"] = "none"; this.style["border"] = "0";};
	        layoutSection.onDragDrop = function() {controlPanel.updateLayout()};
		}
	}

	var aSections = document.getElementsByClassName("Section");
	for(i=0;i<aSections.length;i++) {
		d = $(aSections[i].id);
		h = $(aSections[i].id+"_Head");
		if(h) h.style.cursor="move";
		if(d) d.setDragHandle(h);
	}
	
}	

function addEvent(obj, event, listener, useCapture) {
  // Non-IE
  if(obj.addEventListener) {
    if(!useCapture) useCapture = false;

    obj.addEventListener(event, listener, useCapture);
    return true;
  }

  // IE
  else if(obj.attachEvent) {
    return obj.attachEvent('on'+event, listener);
  }
}

function getModuleIconsHTML(modID) {
	return tmpHTML = "<a href=\"javascript:controlPanel.deleteModule('" + modID + "');\"><img src='/xilya/includes/images/omit-page-orange.gif' alt='Remove from page' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>"
}

function attachModuleIcons() {
	var aSections = document.getElementsByClassName("Section");
	var modID = "";
	controlPanel.setStatusMessage("attaching module icons...",1000);
	for(i=0;i<aSections.length;i++) {
		modID = aSections[i].id;
		d = $(modID);
		h = $(modID + "_Head");
		aElem = h.getElementsByTagName("h2");
		new Insertion.Top(aElem[0], getModuleIconsHTML(modID));
	}
}

function attachLayoutHolders() {
	var html = "<div class='layoutSectionHolder'>&nbsp;</div>";
	
	for(loc in controlPanel.locations) {
        layoutSection = $(controlPanel.locations[loc].id);
        if(layoutSection) {
			new Insertion.Top(layoutSection, html);
		}
	}
}

function attachModuleIcon(modID, imgSrc, onclickStr, alt) {
	controlPanel.setStatusMessage("attaching module icons...",1000);
	h = $(modID + "_Head");
	aElem = h.getElementsByTagName("h2");
	new Insertion.Top(aElem[0],  "<a href='#' onclick=\"" + onclickStr + "\"><img src=\"" + imgSrc + "\" border='0' style='margin-top:3px;margin-right:3px;' align='right' alt='" + alt + "' title='" + alt + "'></a>");
}

function getRadioButtonValue(rad) {
	for (var i=0; i < rad.length; i++) {
	   if (rad[i].checked)
		  return rad[i].value;
	}
}

function addCustomFeed(frm) {
	if(frm.addToMyFeeds.checked)	
		controlPanel.getView('createFeedResource',{rssURL:frm.xmlUrl.value}) 
	else 
		controlPanel.addFeed(frm.xmlUrl.value)
}


function h_callServer(server,method,sec,params,rcv) {
	var tgt = "";
	var pars = "";

	if(sec!=null && sec!="") tgt = sec+"_BodyRegion";
	h_setLoadingImg(tgt);

	// build the query string
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";

	// add the method to execute
	pars = pars + "method=" + method;
	pars = pars + "&_server=" + server;
	pars = pars + "&_pageHREF=" + _pageHREF;

	// do the AJAX call
	if(rcv==null) 
		var myAjax = new Ajax.Updater(tgt,
									  "/xilya/includes/controlPanelGateway.cfm",
									  {method:'post', parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:h_clearLoadingImg});
	else
		var myAjax = new Ajax.Updater(tgt,
									  "/xilya/includes/controlPanelGateway.cfm",
									  {method:'post', parameters: pars, onFailure: h_callError, onComplete:rcv, evalScripts:true});
}
