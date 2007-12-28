
<html>
	<head>
		<script src="/Home/Modules/PhotoAlbums/scripts/multifile_compressed.js"></script>
		<style type="text/css">
			body {
				font-family:arial;
				font-size:11px;
			}
			#files_list {
				font-size:9px;
				border:1px solid #ccc;
			}
			form {
				width:80%;
				text-align:center;
			}
		</style>
	</head>
	<body>
		<form enctype="multipart/form-data" action="/Home/Common/Templates/moduleGateway.cfm" method="post">
			<cfoutput>
				<input type="hidden" name="moduleID" value="#moduleID#">
				<input type="hidden" name="method" value="getView">
				<input type="hidden" name="view" value="processUpload">
				<input type="hidden" name="albumName" value="#albumName#">
			</cfoutput>
			<input id="my_file_element" type="file" name="file_1" >
			<input type="submit" value="Upload">
		</form>
		Files:
		<div id="files_list"></div>
		<script>
			<!-- Create an instance of the multiSelector class, pass it the output target and the max number of files -->
			var multi_selector = new MultiSelector( document.getElementById( 'files_list' ), 20 );
			<!-- Pass in the file element -->
			multi_selector.addElement( document.getElementById( 'my_file_element' ) );
		</script>
	</body>
</html>


