function selectCustomStorage(obj) {
	var d = document.getElementById("fld_storageCFC");
	
	if(obj.checked) 
		d.style.display = "block";
	else
		d.style.display = "none";
}

function hideCustomStorage() {
	var d = document.getElementById("fld_storageCFC");
	d.style.display = "none";
}

function doResetPassword(userID) {
	var newPwd = prompt("Enter the new Password","Reset Password");
	if(newPwd!="") {
		document.location = '?event=ehAccounts.doChangePassword&newPassword=' + newPwd + '&UserID=' + userID;	
	} else {
		alert("The new password cannot be empty.");	
	}
}

function doDeleteAccount(userID) {
	if(confirm('Are you sure you wish to delete this account and all related files?'))
		document.location = '?event=ehAccounts.doDelete&UserID=' + userID;	
}

function doDeleteFile(userID,href) {
	if(confirm('Are you sure you wish to delete this file?'))
		document.location = '?event=ehAccounts.doDeleteFile&UserID=' + userID + '&href=' + href;	
}

function doDeletePage(href) {
	if(confirm('Are you sure you wish to remove this page from your site?'))
		document.location = '?event=ehSite.doDeletePage&href=' + href;	
}

currentModuleLayout = "";
function initLayoutPreview() {
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
			list.onDragDrop = function() {enableUpdateModuleOrder(); };
			
			// add onclick event to list items
			items = list.getElementsByTagName( "li" );
			for (var j = 0; j < items.length; j++) {	
				items[j].onclick = getModuleProperties;	
				items[j].ondblclick = editModuleProperties;
			}
		}

		currentModuleLayout = DragDrop.serData('g1');
	} catch(e) {
		alert(e);
	}
}


function enableUpdateModuleOrder() {
	var newLayout = DragDrop.serData('g1');
	if(currentModuleLayout != newLayout) {
		$("btnUpdateModuleOrder").style.display = "block";
	}
}

function updateModuleOrder() {
	var newLayout = DragDrop.serData('g1');
	document.location = "?event=ehPage.doUpdateModuleOrder&layout=" + newLayout;	
}

function showLayoutSectionTitles(display) {
	var divs = document.getElementsByClassName("layoutSectionLabel");
	for(i=0;i<divs.length;i++) {
		d = $(divs[i].id);
		if(display) 
			d.style.display = "block";
		else
			d.style.display = "none";
	}	
}

function addModule(moduleID) {
	if(confirm("Add " + moduleID + " module?")) {
		document.location="?event=ehPage.doAddModule&moduleID="+moduleID;
	}
}

function getModuleProperties(event) {
	e = fixEvent(event);
	var modID = this.id;
	
	doEvent("ehPage.dspModuleProperties","moduleProperties",{moduleID: modID});
	
	var items = document.getElementsByClassName("layoutListItem");
	for(var i=0;i<items.length;i++) {
		items[i].style.backgroundColor = "#eee";
	}
	$(modID).style.backgroundColor = "#fefcd8";
	
	
	function fixEvent(event) {
		if (typeof event == 'undefined') event = window.event;
		return event;
	}	
}

function editModuleProperties(event) {
	e = fixEvent(event);
	var modID = this.id;
	
	document.location = "?event=ehPage.dspEditModuleProperties&moduleID=" + modID;
	
	var items = document.getElementsByClassName("layoutListItem");
	for(var i=0;i<items.length;i++) {
		items[i].style.backgroundColor = "#eee";
	}
	$(modID).style.backgroundColor = "#fefcd8";
	
	
	function fixEvent(event) {
		if (typeof event == 'undefined') event = window.event;
		return event;
	}	
}

function doFormEvent (e, targetID, frm) {
	var params = {};
	for(i=0;i<frm.length;i++) {
		if(!(frm[i].type=="radio" && !frm[i].checked))  {
			params[frm[i].name] = frm[i].value;
		}
	}
	doEvent(e, targetID, params);
}

function doEvent (e, targetID, params) {
	var pars = "";
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	pars = pars + "event=" + e;
	var myAjax = new Ajax.Updater(targetID,
									"index.cfm",
									{method:'get', parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:doEventComplete});
	startLoadingTicker();
}

function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component.');
}

function doEventComplete (obj) {stopLoadingTicker()}

function startLoadingTicker() {
	var i = $("loadingImage");
	if(i) i.style.display = 'block';
}
function stopLoadingTicker() {
	var i = $("loadingImage");
	if(i) i.style.display = 'none';
}


function doDeleteModule(moduleID) {
	if(confirm('Remove module from page?'))
		document.location = '?event=ehPage.doDeleteModule&ModuleID=' + moduleID;	
}

    var tab = "\t";

	function checkTab(evt) {
		var t = evt.target;
		var ua = navigator.userAgent.toLowerCase(); 
		var isFirefox = (ua.indexOf('mozilla') != -1); 
		var isOpera = (ua.indexOf('opera') != -1); 
		var isIE  = (ua.indexOf('msie') != -1 && !isOpera && (ua.indexOf('webtv') == -1) ); 
		if(!isIE) {
			var ss = t.selectionStart;
			var se = t.selectionEnd;
			
			// Tab key - insert tab expansion
			if (evt.keyCode == 9) {
			    evt.preventDefault();
			    
			    // Special case of multi line selection
			    if (ss != se && t.value.slice(ss,se).indexOf("\n") != -1) {
			        // In case selection was not of entire lines (e.g. selection begins in the middle of a line)
			        // we ought to tab at the beginning as well as at the start of every following line.
			        var pre = t.value.slice(0,ss);
			        var sel = t.value.slice(ss,se).replace(/\n/g,"\n"+tab);
			        var post = t.value.slice(se,t.value.length);
			        t.value = pre.concat(tab).concat(sel).concat(post);
			        t.selectionStart = ss + tab.length;
			        t.selectionEnd = se + tab.length;
			    }
			    
			    // "Normal" case (no selection or selection on one line only)
			    else {
			        t.value = t.value.slice(0,ss).concat(tab).concat(t.value.slice(ss,t.value.length));
			        if (ss == se) {
			            t.selectionStart = t.selectionEnd = ss + tab.length;
			        }
			        else {
			            t.selectionStart = ss + tab.length;
			            t.selectionEnd = se + tab.length;
			        }
			    }
			}
			
			// Backspace key - delete preceding tab expansion, if exists
			else if (evt.keyCode==8 && t.value.slice(ss - tab.length,ss) == tab) {
			    evt.preventDefault();
			    t.value = t.value.slice(0,ss - tab.length).concat(t.value.slice(ss,t.value.length));
			    t.selectionStart = t.selectionEnd = ss - tab.length;
			}
			
			// Delete key - delete following tab expansion, if exists
			else if (evt.keyCode==46 && t.value.slice(se,se + tab.length) == tab) {
			    evt.preventDefault();
			    t.value = t.value.slice(0,ss).concat(t.value.slice(ss + tab.length,t.value.length));
			    t.selectionStart = t.selectionEnd = ss;
			}
			
			// Left/right arrow keys - move across the tab in one go
			else if (evt.keyCode == 37 && t.value.slice(ss - tab.length,ss) == tab) {
			    evt.preventDefault();
			    t.selectionStart = t.selectionEnd = ss - tab.length;
			}
			else if (evt.keyCode == 39 && t.value.slice(ss,ss + tab.length) == tab) {
			    evt.preventDefault();
			    t.selectionStart = t.selectionEnd = ss + tab.length;
			}
		}      
  }
  function checkTabIE() {
	var ua = navigator.userAgent.toLowerCase(); 
	var isFirefox = (ua.indexOf('mozilla') != -1); 
	var isOpera = (ua.indexOf('opera') != -1); 
	var isIE  = (ua.indexOf('msie') != -1 && !isOpera && (ua.indexOf('webtv') == -1) ); 

	if(isIE && event.srcElement.value) {
	   if (event.keyCode == 9) {  // tab character
	      if (document.selection != null) {
	         document.selection.createRange().text = '\t';
	         event.returnValue = false;
	      } else {
	         event.srcElement.value += '\t';
	         return false;
	      }
	   }
	 }
  }
  
function deleteEventHandler(index) {
	if(confirm('Delete event handler?')) {
		document.location = '?event=ehPage.doDeleteEventHandler&index='+index;
	}
}
