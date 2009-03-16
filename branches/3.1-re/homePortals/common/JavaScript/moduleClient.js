/******************************************************/
/* moduleClient.js 								      */
/*												      */
/* This javascript contains all js functions for the  */
/* client side of HomePortals modules.       		  */
/*												   	  */
/* (c) 2006 - CFEmpire   							  */
/*	by Oscar Arevalo - oarevalo@cfempire.com		  */
/*												      */
/******************************************************/

function moduleClient() {

	// pseudo-constructor
	function init(moduleID) {
		this.moduleID = moduleID;
	}

	function getView(view, target, args) {
		if(view==null) view = "";
		if(target==null || target=="") target = this.moduleID;
		if(args==null) args = {};

		args["view"] = view;
		
		h_callModuleController(this.moduleID,"getView",target,args);
	}
	function getPopupView(view,args) {
		try {
		if(args==null) args = {};
		if(view==null) view = "";

		args["view"] = view;

		if(!this.isWindowOpen()) 
			this.openWindow();
			
		scroll(0,0);
	
		h_callModuleController(this.moduleID,"getView","h_moduleWindow",args);
		
		} catch(e) {
			alert(e);
			closeWindow()
		}
	}

	function doAction(action, args) {
		// make sure args is a structure
		if(args==null) args = {};

		// add required arguments
		args["action"] = action;

		// create a temporary area to hold any returned output
		// this area is intended ONLY for status messages and javascript code,
		// not for actual views
		var actionOutputID = this.moduleID + "ActionOutput_BodyRegion";
		if(!$(actionOutputID)) {
			var tmpHTML = "<div id='" + actionOutputID + "' class='h_actionOutputMessage'></div>";
			new Insertion.Before(this.moduleID+"_BodyRegion",tmpHTML);
		}

		// call server-side method
		h_callModuleController(this.moduleID, "doAction", this.moduleID + "ActionOutput", args);

		// clear output in a few seconds		
		setTimeout(this.moduleID + '.clearActionOutput()',5000);
	}	

	function doFormAction(action,frm) {
		var params = {};
		for(i=0;i<frm.length;i++) {
			if(frm[i].name!="") {
				if(frm[i].type=="checkbox")
					params[frm[i].name] = frm[i].checked;
				else
					params[frm[i].name] = frm[i].value;
			}
		}
		this.doAction(action, params);
	}

	function clearActionOutput() {
		if($(this.moduleID + "ActionOutput_BodyRegion")) 
			new Element.remove(this.moduleID + "ActionOutput_BodyRegion");
	}


	function openWindow() {
		var d = document.getElementById("h_moduleWindow");
		if(!d) {
			var tmpHTML = "<div id='h_moduleWindow'><div id='h_moduleWindow_BodyRegion'></div></div>";
			new Insertion.Before("h_body_main",tmpHTML);

			tmpHTML = "<a href='javascript:" + this.moduleID + ".closeWindow();'>" +
							"<img id='h_moduleWindowClose' " +
									"src='/homePortals/common/Images/cp_header_close.gif'"+ 
									"alt='Close' title='Close' border='0'></a>";
			new Insertion.Top("h_moduleWindow",tmpHTML);

			if(window.innerWidth)  clientWidth = window.innerWidth;
			else if (document.body) clientWidth = document.body.clientWidth;
			
			var d = document.getElementById("h_moduleWindow");
			d.style.left = ((clientWidth/2)-250) + "px";
		}
	}
	
	function isWindowOpen() {
		var d = document.getElementById("h_moduleWindow");
		if(!d) 
			return false;
		else
			return true;
	}
	
	function closeWindow() {
		new Element.remove("h_moduleWindow");
	}

	function setMessage(msg) {
		var actionOutputID = this.moduleID + "ActionOutput_BodyRegion";
		var divMsg = $(actionOutputID);
		if(divMsg) {
			if(msg!="") divMsg.innerHTML = msg;
		}
	}

	function raiseEvent(eventName, args) {
		h_raiseEvent(this.moduleID, eventName, args);
	}

	function attachIcon(imgSrc, onclickStr, alt) {
		h = $(this.moduleID + "_Head");
		if(h) {
			aElem = h.getElementsByTagName("h2");
			new Insertion.Top(aElem[0],  "<a href='#' onclick=\"" + onclickStr + "\"><img src=\"" + imgSrc + "\" border='0' style='margin-top:3px;margin-right:3px;' align='right' alt='" + alt + "' title='" + alt + "'></a>");
		}
	}
	
	function setIcon(imgSrc) {
		h_setModuleContainerIcon(this.moduleID, imgSrc);
	}

	function setTitle(title) {
		h_setModuleContainerTitle(this.moduleID, title);
	}

	function getTitle() {
		return h_getModuleContainerTitle(this.moduleID);
	}

	// Attach functions to the prototype of this object
	// (this is what creates the actual "methods" of the object)
	moduleClient.prototype.init = init;
	moduleClient.prototype.getView = getView;
	moduleClient.prototype.doAction = doAction;
	moduleClient.prototype.doFormAction = doFormAction;
	moduleClient.prototype.clearActionOutput = clearActionOutput;

	moduleClient.prototype.getPopupView = getPopupView;
	moduleClient.prototype.openWindow = openWindow;
	moduleClient.prototype.isWindowOpen = isWindowOpen;
	moduleClient.prototype.closeWindow = closeWindow;
	moduleClient.prototype.setMessage = setMessage;
	moduleClient.prototype.raiseEvent = raiseEvent;

	moduleClient.prototype.attachIcon = attachIcon;
	moduleClient.prototype.setIcon = setIcon;
	moduleClient.prototype.setTitle = setTitle;
	moduleClient.prototype.getTitle = getTitle;
	
}