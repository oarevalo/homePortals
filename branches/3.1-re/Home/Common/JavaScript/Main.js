var h_appRoot = "";	// points to the current application root
var h_pageURI = ""; // points to the current page loaded

function h_setModuleContainerTitle(moduleID,title) {
	var d = $(moduleID + '_Title');
	if(d) d.innerHTML = title;
}
function h_getModuleContainerTitle(moduleID) {
	var title = "";
	var d = $(moduleID + '_Title');
	if(d) title = d.innerHTML;
	return title;
}
function h_setModuleContainerIcon(moduleID,imgURL) {
	var d = $(moduleID + '_Icon');
	if(d) d.innerHTML = "<img src='"+imgURL+"' width=16 height=16 align='absmiddle'>";
}
function h_setLoadingImg(secID) {
	var d = document.getElementById("h_loading");
	var url_loadingImage =  "/Home/Common/Images/loading_text.gif";

	if(!d) {
		var tmpHTML = "<div id='h_loading'><img src='" + url_loadingImage + "'></div>";
		new Insertion.Before("h_body_main",tmpHTML);

		if(window.innerWidth)  clientWidth = window.innerWidth;
		else if (document.body) clientWidth = document.body.clientWidth;

		if(window.innerHeight)  clientHeight = window.innerHeight;
		else if (document.body) clientHeight = document.body.clientHeight;
		
		var d = document.getElementById("h_loading");
		d.style.left = ((clientWidth/2)-70) + "px";
		d.style.top = ((clientHeight/2)-100) + "px";
	}
}
function h_clearLoadingImg() {
	var d = document.getElementById("h_loading");
	if(d) {
		new Element.remove("h_loading");
	}
	
}

/********************************  RPC Functions ***********************************/
function h_callModuleController(moduleID,method,sec,params,rcv) {
	var tgt = "";
	var pars = "";
	var server = h_appRoot + "gateway.cfm";
	var requestMethod = "post";	

	try {
		if(sec!=null && sec!="") tgt = sec+"_BodyRegion";
		h_setLoadingImg(tgt);
	
		// build the query string
		for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	
		// add the method to execute
		pars = pars + "method=" + method;
		
		// add the moduleid
		pars = pars + "&moduleID=" + moduleID;
		
		// add the current page
		pars = pars + "&pageURI=" + h_pageURI;

		// do the AJAX call
		if(rcv==null) 
			var myAjax = new Ajax.Updater(tgt,
										  server,
										  {method:requestMethod, parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:h_clearLoadingImg});
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

function h_resizeToClient(sec,offset) {
	/**** Resize a section height to fit the browser screen ****/
	var newHeight = 0;
	var clientHeight = 0;

	if(window.innerHeight)  clientHeight = window.innerHeight;
	else if (document.body) clientHeight = document.body.clientHeight;

	newHeight = clientHeight - offset;	
	var s= document.getElementById(sec);
	if(s) s.style.height = newHeight;

	return newHeight;
}

function h_parseQueryString (str) {
	/***** function to parse the query string ***/
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
	