var h_appRoot = "";	// points to the current application root
var h_pageHREF = ""; // points to the current page loaded

function h_setModuleContainerTitle(moduleID,title) {
	$("#" + moduleID + '_Title').html(title);
}
function h_getModuleContainerTitle(moduleID) {
	return $("#" + moduleID + '_Title').html();;
}
function h_setModuleContainerIcon(moduleID,imgURL) {
	$("#" + moduleID + '_Icon').html("<img src='"+imgURL+"' width=16 height=16 align='absmiddle'>");
}
function h_setLoadingImg(secID) {
	var d = document.getElementById("h_loading");
	var url_loadingImage =  "/homePortals/plugins/modules/common/Images/loading_text.gif";

	if(!d) {
		var tmpHTML = "<div id='h_loading'><img src='" + url_loadingImage + "'></div>";
		$("#"+secID).prepend(tmpHTML);

		if(window.innerWidth)  clientWidth = window.innerWidth;
		else if (document.body) clientWidth = document.body.clientWidth;

		if(window.innerHeight)  clientHeight = window.innerHeight;
		else if (document.body) clientHeight = document.body.clientHeight;
		
		var d = document.getElementById("h_loading");
		if(d) {
			d.style.left = ((clientWidth/2)-70) + "px";
			d.style.top = ((clientHeight/2)-100) + "px";
		}
	}
}
function h_clearLoadingImg() {
	$("#h_loading").remove();
}

/********************************  RPC Functions ***********************************/
function h_callModuleController(moduleID,method,sec,params,rcv) {
	var server = h_appRoot + "gateway.cfm";
	var tgt = "";

	if($("#"+sec+"_BodyRegion"))
		sec = sec+"_BodyRegion";
	h_setLoadingImg(sec);
	
	params.method = method;
	params.pageHREF = h_pageHREF;
	params.moduleID = moduleID;

	if(jQuery("#"+sec).html() == "")
		jQuery("#"+sec).html("loading...");
	jQuery("#"+sec).load(server,
						 params,
						 function(responseText, textStatus, XMLHttpRequest) {
						    if(textStatus!='success') {alert('An error ocurred while contacting the server');}
						    if(rcv!=null) 
						    	eval(rcv);
						    else
						    	setTimeout('h_clearLoadingImg()',2000);
						 }
	);
}
	
	