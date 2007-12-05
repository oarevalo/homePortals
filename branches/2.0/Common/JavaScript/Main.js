
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
									  {method:'post', parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:h_clearLoadingImg});
	else
		var myAjax = new Ajax.Updater(tgt,
									  server,
									  {method:'post', parameters: pars, onFailure: h_callError, onComplete:rcv, evalScripts:true});
}

function h_callModuleController(moduleID,method,sec,params,rcv) {
	var tgt = "";
	var pars = "";
	var server = "/Home/Common/Templates/moduleGateway.cfm";
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
	