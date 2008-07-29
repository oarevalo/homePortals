var h_modules = new Array();
var h_dragMode = false;

function h_InitModules() {
	/*
	for(var i=0;i<h_modules.length;i++) {
		m = $(h_modules[i]+"_BodyRegion");
		if(m) {
			tmpHTML = "<img style='float:right;' " +
							"src='/Accounts/default/cp_header_close.gif'"+ 
							"alt='Close' title='Close' border='0'>";
			new Insertion.Top(h_modules[i],tmpHTML);
		}
	}
	*/
}

/***************************** Hide and Show Sections *****************************/
function h_Hide(secName) { if(document.getElementById(secName)) document.getElementById(secName).style.display = "none"; }
function h_Show(secName,display) { 
	if(display==undefined) display="block";
	if(document.getElementById(secName)) document.getElementById(secName).style.display = display; 
}
function h_CollapseSection(secID) {
	h_Hide(secID + '_Body');
	h_Hide(secID + '_ButtonHide');
	h_Show(secID + '_ButtonShow',"inline");
}
function h_ExpandSection(secID) {
	h_Show(secID + '_Body');
	h_Hide(secID + '_ButtonShow');
	h_Show(secID + '_ButtonHide',"inline");
}
function h_IsVisible(secName) { 
	if(document.getElementById(secName)) return document.getElementById(secName).style.display != "none"; 
	else return false;
}
function h_IsSectionExpanded(secID) { return h_IsVisible(secID + '_Body') && h_IsVisible(secID); }
function h_ToggleSection(secID) { if(h_IsSectionExpanded(secID)) h_CollapseSection(secID); else h_ExpandSection(secID); }
function h_ToggleSectionVisibility(secID) { if(h_IsVisible(secID)) h_Hide(secID); else h_Show(secID); }

function h_SetSectionTitle(secID,title) {
	if(document.getElementById(secID + '_Title')) {
		document.getElementById(secID + '_Title').innerHTML = title;
	}
}
function h_GetSectionTitle(secID) {
	var title = "";
	if(document.getElementById(secID + '_Title')) {
		title = document.getElementById(secID + '_Title').innerHTML;
	}
	return title;
}
function h_setLoadingImg(secID) {
	var s =  document.getElementById(secID);
	//var url_loadingImage =  "/Common/images/animatedloading.gif";
	var url_loadingImage =  "/Home/Common/Images/loading_ring.gif";
	if(s) s.innerHTML = "<img src=\"" + url_loadingImage + "\">";	
}
/******************************** Print Functions ***************************/
function h_Print(secID,srcID) {
	// Create new window
	//var printAttr = "height=100,width=100,top=0,left=0,location=no,menubar=no,scrollbars=no,resizable=no,status=no,toolbar=no,titlebar=no";
	var printAttr = "";
	//var printHTML = "<html><body id='body' onload='window.print();window.close();'></body></html>";
	var printHTML = "<html><head id='head'></head><body id='body'></body></html>"
	
	var tWin = window.open("",secID,printAttr)
	var tDoc = tWin.document;
	tDoc.open();
	tDoc.writeln(printHTML);
	
	var title = h_GetSectionTitle(secID);
	if(title=="" || title==undefined) title=secID;
	tDoc.title = title;
	
	if(srcID==undefined) 
		var src = document.getElementById(secID + '_BodyRegion');
	else
		var src = document.getElementById(srcID);
	var tgt = tDoc.getElementById("body");

	var numStyles = tDoc.styleSheets.length;
	if(tDoc.createStyleSheet) {
		// Add basic CSS for printing
		ts = tDoc.createStyleSheet("Common/CSS/Print.css");
	
		// Copy linked CSS definitions
		for(var i=0; i<document.styleSheets.length;i++) {
			s = document.styleSheets(i).href;
			if(s!="") ts = tDoc.createStyleSheet(s);
		}

		// Copy embedded CSS definitions
		var aStyle = src.getElementsByTagName("style")
		var ts = "";
		for(i=0;i<aStyle.length;i++) {
			if(aStyle[i].innerHTML!="") ts = ts + aStyle[i].innerHTML;
		}
		tIStyle = tDoc.createStyleSheet();
		tIStyle.cssText = ts;
	}
	

	// Copy HTML code
	tgt.innerHTML = h_PrintHeader(title) + src.innerHTML;

	// remove no print sections
	var aNoPrint = tDoc.getElementsByTagName("div");
	for(i=0;i<aNoPrint.length;i++) {
		if(aNoPrint[i].id=="noprint") aNoPrint[i].innerHTML = "";
	}

	tDoc.close();
	
}
function h_PrintHeader(title) {
	var tmp = "";
	var today = new Date();
	
	tmp = "<h1>"+title+"</h1>";

	return tmp;
}

/********************************  RPC Functions ***********************************/
function h_callServer(server,method,sec,params,rcv) {
	var tgt = "";
	var pars = "";

	if(sec!=null && sec!="") tgt = sec+"_BodyRegion";
	h_setLoadingImg(tgt);

	// build the query string
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";

	// add the method to execute
	pars = pars + "method=" + method;
	

	// check to see if the called server is on the same domain, otherwise we
	// will need to user our own server as a proxy due to the security limitations
	// of XMLHttpRequest
	if(server.substr(0,4)=="http" || server.substr(0,4)=="HTTP") {
		pars = pars + "&_server=" + server;
		server = "/Home/Common/Templates/proxy.cfm";
	} else {
		pars = pars + "&_server=" + server;
		server = "/Home/Common/Templates/gateway.cfm";	
	}

	// do the AJAX call
	if(rcv==null) 
		var myAjax = new Ajax.Updater(tgt,
									  server,
									  {method:'get', parameters:pars, evalScripts:true, onFailure:h_callError});
	else
		var myAjax = new Ajax.Updater(tgt,
									  server,
									  {method:'get', parameters: pars, onFailure: h_callError, onComplete:rcv, evalScripts:true});
}

function h_callModuleController(moduleID,method,sec,params,rcv) {
	var tgt = "";
	var pars = "";
	var server = "/Home/Common/Templates/moduleGateway.cfm";
	var requestMethod = "get";	

	try {
		if(sec!=null && sec!="") tgt = sec+"_BodyRegion";
		h_setLoadingImg(tgt);
	
		// build the query string
		for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	
		// add the method to execute
		pars = pars + "method=" + method;
		
		// add the moduleid
		pars = pars + "&moduleID=" + moduleID;

		// do the AJAX call
		if(rcv==null) 
			var myAjax = new Ajax.Updater(tgt,
										  server,
										  {method:requestMethod, parameters:pars, evalScripts:true, onFailure:h_callError});
		else
			var myAjax = new Ajax.Updater(tgt,
										  server,
										  {method:requestMethod, parameters: pars, onFailure: h_callError, onComplete:rcv, evalScripts:true});
	} catch(e) {
		alert(e);
	}
}

	
function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component.');
}




/**** Resize a section to fit the browser screen ****/
function h_resizeToClient(sec,offset) {
	var newHeight = 0;
	var clientHeight = 0;

	if(window.innerHeight)  clientHeight = window.innerHeight;
	else if (document.body) clientHeight = document.body.clientHeight;

	newHeight = clientHeight - offset;	
	var s= document.getElementById(sec);
	if(s) s.style.height = newHeight;

	return newHeight;
}

/***** function to parse the query string ***/
function h_parseQueryString (str) {
	str = str ? str : location.search;
	var query = str.charAt(0) == '?' ? str.substring(1) : str;
	var args = new Object();
	if (query) {
		var fields = query.split('&');
		for (var f = 0; f < fields.length; f++) {
			var field = fields[f].split('=');
			args[unescape(field[0].replace(/\+/g, ' '))] = unescape(field[1].replace(/\+/g, ' '));
		}
	}
	return args;
}
	
/* Enable drag and drop for modules in column sections*/
/***  REQUIRES SCRIPTACULOUS ****/
function h_enableModuleDrag() {
	var tbl = document.getElementById("h_body_main");
	var aCols = tbl.getElementsByTagName("td");
	var aColumnnIDs = new Array();
	
	for(var i=0;i<aCols.length;i++) aColumnnIDs[i]= aCols[i].id;
	var params = {dropOnEmpty:true,
					tag:"div",
					only:"Section",
					containment:aColumnnIDs,
					constraint:false, 
					ghosting: false}
					//,onUpdate: h_finishModuleDrag

	for(i=0;i<aCols.length;i++) Sortable.create(aCols[i].id, params)	
}

function h_finishModuleDrag(obj) {
	poststring = Sortable.serialize(obj.id, {tag:"div"});
}