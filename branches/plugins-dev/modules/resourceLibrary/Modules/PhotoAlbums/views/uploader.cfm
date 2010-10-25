<cfparam name="moduleID">
<cfparam name="albumName">
<cfparam name="pageHREF">
<cfparam name="appRoot">
<cfparam name="maxFiles" default="20">

<cfoutput>
	<html>
		<head>
			<script src="/homePortals/plugins/modules/resourceLibrary/Modules/PhotoAlbums/scripts/multifile.js"></script>
			<style type="text/css">
				body {
					font-family:arial;
					font-size:11px;
				}
				##files_list {
					font-size:12px;
					line-height:18px;
					border:1px solid ##ccc;
				}
			</style>
		</head>
		<body>
			<form enctype="multipart/form-data" action="#appRoot#/gateway.cfm" method="post">
				<input type="hidden" name="moduleID" value="#moduleID#">
				<input type="hidden" name="method" value="getView">
				<input type="hidden" name="view" value="processUpload">
				<input type="hidden" name="albumName" value="#albumName#">
				<input type="hidden" name="pageHREF" value="#pageHREF#">
				Select one or more images to upload:<br />
				<input id="my_file_element" type="file" name="file_1" >
				<br />
				<input type="submit" value="Upload">
			</form>
			Selected Files:
			<ol id="files_list"></ol>
			<script>
				<!-- Create an instance of the multiSelector class, pass it the output target and the max number of files -->
				var multi_selector = new MultiSelector( document.getElementById( 'files_list' ), #val(maxFiles)# );
				<!-- Pass in the file element -->
				multi_selector.addElement( document.getElementById( 'my_file_element' ) );
			</script>
		</body>
	</html>
</cfoutput>


