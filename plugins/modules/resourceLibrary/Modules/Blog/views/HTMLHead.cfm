<cfscript>
	// get module path
	cfg = this.controller.getModuleConfigBean();
	tmpModulePath = cfg.getModuleRoot();

	// get content store
	setContentStoreURL();
	myContentStore = this.controller.getContentStore();
	xmlDoc = myContentStore.getXMLData();
		
	// url to rss feed
	rssURL = "http://" & cgi.SERVER_NAME & getDirectoryFromPath(tmpModulePath) & "rss?blog=" & myContentStore.getURL();

	// get blog title
	if(StructKeyExists(xmlDoc.xmlRoot.xmlAttributes, "title"))
		blogTitle = xmlDoc.xmlRoot.xmlAttributes.title;
	else
		blogTitle = rssURL; 
</cfscript>

<cfif this.controller.isFirstInClass()>
<style type="text/css">
	.BlogPostBar {
		font-size:11px;
		font-weight:bold;
		border:1px solid silver;
		background-color:#fefcd8;
	}	
	.BlogPostContent {
		background-color:#fff;
	}	
	.BlogCodeBlock {
		font-family: courier,monospace;
		font-size: .7em;
		color: black;
		border: solid thin #0000cc;
		background-color: #ffffcc;
		overflow: auto;
		max-height: 200px;
	    padding: 4px 4px 4px 4px;
	    line-height: 15px;
		 margin:5px 0 5px 0;	
	}
</style>
<script language="JavaScript">
    var tab = "\t";

	function BlogCheckTab(evt) {
		var t = evt.target;
		var ua = navigator.userAgent.toLowerCase(); 
		var isFirefox = (ua.indexOf('mozilla') != -1); 
		var isOpera = (ua.indexOf('opera') != -1); 
		var isIE  = (ua.indexOf('msie') != -1 && !isOpera && (ua.indexOf('webtv') == -1) ); 
		if(!isIE) {
			var ss = t.selectionStart;
			var se = t.selectionEnd;
			
			/* Tab key - insert tab expansion*/
			if (evt.keyCode == 9) {
			    evt.preventDefault();
			    
			    /* Special case of multi line selection*/
			    if (ss != se && t.value.slice(ss,se).indexOf("\n") != -1) {
			        /* In case selection was not of entire lines (e.g. selection begins in the middle of a line)
			        // we ought to tab at the beginning as well as at the start of every following line. */
			        var pre = t.value.slice(0,ss);
			        var sel = t.value.slice(ss,se).replace(/\n/g,"\n"+tab);
			        var post = t.value.slice(se,t.value.length);
			        t.value = pre.concat(tab).concat(sel).concat(post);
			        t.selectionStart = ss + tab.length;
			        t.selectionEnd = se + tab.length;
			    }
			    
			    /* "Normal" case (no selection or selection on one line only) */
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
			
			/* Backspace key - delete preceding tab expansion, if exists */
			else if (evt.keyCode==8 && t.value.slice(ss - tab.length,ss) == tab) {
			    evt.preventDefault();
			    t.value = t.value.slice(0,ss - tab.length).concat(t.value.slice(ss,t.value.length));
			    t.selectionStart = t.selectionEnd = ss - tab.length;
			}
			
			/* Delete key - delete following tab expansion, if exists */
			else if (evt.keyCode==46 && t.value.slice(se,se + tab.length) == tab) {
			    evt.preventDefault();
			    t.value = t.value.slice(0,ss).concat(t.value.slice(ss + tab.length,t.value.length));
			    t.selectionStart = t.selectionEnd = ss;
			}
			
			/* Left/right arrow keys - move across the tab in one go */
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
  function BlogCheckTabIE() {
	var ua = navigator.userAgent.toLowerCase(); 
	var isFirefox = (ua.indexOf('mozilla') != -1); 
	var isOpera = (ua.indexOf('opera') != -1); 
	var isIE  = (ua.indexOf('msie') != -1 && !isOpera && (ua.indexOf('webtv') == -1) ); 

	if(isIE && event.srcElement.value) {
	   if (event.keyCode == 9) {  /* tab character */
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
</script>	
</cfif>

<cfoutput>
<link rel="alternate" type="application/rss+xml" title="#blogTitle#" href="#rssURL#" />
</cfoutput>
