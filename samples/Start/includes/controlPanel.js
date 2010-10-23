
/* *****************************************************/
/* controlPanel.js								   		*/
/*												   		*/
/* This javascript contains all js functions for the  	*/
/* of the startPage application.  				  		*/
/*												   		*/
/* (c) 2007 - Oscar Arevalo - info@homeportals.net  	*/
/*												   		*/
/* *****************************************************/

function controlPanelClient() {

	// pseudo-constructor
	function init(gateway, lstLocations) {
		this.server = gateway;
		this.currentModuleLayout = "";
		this.locations = lstLocations;
		this.panelDivID = "cp_panelWindow";
	}

	function openPanel() {
		scroll(0,0);
		$("#anchorAddContent").append("<div id='"+this.panelDivID+"'></div>");
	}
	
	function isPanelOpen() {
		return ($("#"+this.panelDivID).length!=0);
	}
	
	function closePanel() {
		$("#"+this.panelDivID).remove();
	}
	
	function togglePanel() {
		if(isPanelOpen()) 
			closePanel();
		else
			openPanel();
	}
	
	function getView(view, args) {
		if(args==null) args = {};
		args["viewName"] = view;
		args["useLayout"] = true;
			
		if(!this.isPanelOpen()) this.openPanel();

		h_callServer("getView", this.panelDivID, args);
	}

	function getPartialView(view, args, tgt) {
		if(args==null) args = {};
		args["viewName"] = view;
		args["useLayout"] = false;
		h_callServer("getView", tgt, args);
	}


	// *****   Actions ****** //

	function addModule(modID) {
		controlPanel.setStatusMessage("Adding module to workspace...");
		h_callServer("addModule","siteMapStatusBar",{moduleID:modID});
	}

	function addFeed(feedURL, feedTitle) {
		h_callServer("addFeed","siteMapStatusBar",{feedURL:feedURL, feedTitle:feedTitle});
	}			

	function deleteModule(modID) {
		if(confirm('Are you sure you wish to delete this module?')) {
			h_callServer("deleteModule", "siteMapStatusBar", {moduleID:modID});
		}
	}		
	
	function removeModuleFromLayout(modID) {
		$("#"+modID).remove();
		$("#"+modID+"_lp").remove();
	}
	
	function addPage(pageName) {
		if(pageName=="") 
			alert("The page name cannot be blank.");	
		else 
			h_callServer("addPage","siteMapStatusBar",{pageName:pageName});
	}

	function deletePage(pageHREF) {
		if(confirm("Delete page from site?")) {
			h_callServer("deletePage","siteMapStatusBar",{pageHREF:pageHREF});
		}
	}
	
	function changeTitle(frm) {
		h_callServer("changeTitle","siteMapStatusBar",{title:frm.title.value});
	}
	
	function renamePage(title) {
		var d = jQuery("#"+this.currentTextID);
		d.html(this.tempHTML);
		if(this.tempHTML != title) {
			d.html(title);
			h_callServer("renamePage","siteMapStatusBar",{pageName:title});
		}
	}	
	function renameSite(title) {
		var d = jQuery("#"+this.currentTextID);
		d.html(this.tempHTML);
		if(this.tempHTML != title) {
			d.html(title);
			h_callServer("setSiteTitle","siteMapStatusBar",{title:title});
		}
	}


	// *****   Misc   ****** //
	
	function setStatusMessage(msg,timeout) {
		jQuery("#siteMapStatusBar").html(msg);

		if(!timeout || timeout==null) timeout=6000;
		setTimeout('controlPanel.clearStatusMessage()',timeout);
	}

	function clearStatusMessage() {
		jQuery("#siteMapStatusBar").empty();
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
		h_callServer("updateModuleOrder","siteMapStatusBar",{layout:newLayout});
   }

	function rename(txtID,title,type) {
		var fldID = "sb_" + type + "Name";
		var func = "controlPanel.rename" + type + "(this.value)";
		var d = jQuery("#"+txtID);
		this.currentTextID = txtID;
		this.tempHTML = d.html();
		d.html("<input type='text' id='" + fldID + "' value='" + title + "' class='inlineTextbox' onblur='" + func + "'>");
		if(type!='Site')
			d.html(d.html() + "<a href='#' onclick='navCmdDeletePage()'><img src='images/omit-page-orange.gif' border='0' align='absmiddle' alt='Click to delete page' title='click to delete page'></a>");
	}


	
	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	controlPanelClient.prototype.init = init;

	controlPanelClient.prototype.openPanel = openPanel;
	controlPanelClient.prototype.closePanel = closePanel; 
	controlPanelClient.prototype.isPanelOpen = isPanelOpen;
	controlPanelClient.prototype.getView = getView;
	controlPanelClient.prototype.getPartialView = getPartialView;

	controlPanelClient.prototype.addModule = addModule;
	controlPanelClient.prototype.addFeed = addFeed;
	controlPanelClient.prototype.deleteModule = deleteModule;
	controlPanelClient.prototype.addPage = addPage;
	controlPanelClient.prototype.deletePage = deletePage;
	controlPanelClient.prototype.changeTitle = changeTitle;
	controlPanelClient.prototype.renamePage = renamePage;
	controlPanelClient.prototype.updateLayout = updateLayout;
	controlPanelClient.prototype.setStatusMessage = setStatusMessage;
	controlPanelClient.prototype.clearStatusMessage = clearStatusMessage;
	controlPanelClient.prototype.renameSite = renameSite;
	controlPanelClient.prototype.removeModuleFromLayout = removeModuleFromLayout;
	controlPanelClient.prototype.rename = rename;
	controlPanelClient.prototype.togglePanel = togglePanel;
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
	return tmpHTML = "<a href=\"javascript:controlPanel.deleteModule('" + modID + "');\"><img src='images/omit-page-orange.gif' alt='Remove from page' border='0' style='margin-top:3px;margin-right:3px;' align='right'></a>"
}

function attachModuleIcons() {
	var aSections = document.getElementsByClassName("Section");
	var modID = "";
	controlPanel.setStatusMessage("attaching module icons...",1000);
	for(i=0;i<aSections.length;i++) {
		modID = aSections[i].id;
		jQuery("#"+modID + "_Head h2").prepend( getModuleIconsHTML(modID) );
	}
}

function attachLayoutHolders() {
	var html = "<div class='layoutSectionHolder'>&nbsp;</div>";
	
	for(loc in controlPanel.locations) {
		 jQuery("#"+controlPanel.locations[loc].id).prepend(html);
	}
}

function getRadioButtonValue(rad) {
	for (var i=0; i < rad.length; i++) {
	   if (rad[i].checked)
		  return rad[i].value;
	}
}

function navCmdAddPage() {
	controlPanel.addPage('New Page');
}
function navCmdAddContent() {
	if(controlPanel.isPanelOpen())
		controlPanel.closePanel()
	else
		controlPanel.getView('AddFeed')
}
function navCmdDeletePage() {
	controlPanel.deletePage(h_pageHREF);
}


function h_callServer(method,sec,params,rcv) {
	console.log("calling server: ["+method+"]["+sec+"]")
	controlPanel.setStatusMessage("Loading...");
	
	params.method = method;
	params._pageHREF = h_pageHREF;

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

