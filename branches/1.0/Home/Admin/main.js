function removePlugin(pluginID) {
	if(confirm("Are you sure you wish to completely remove this plugin?"))
		document.location = "home.cfm?event=removePlugin&pluginID=" + pluginID;
}

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