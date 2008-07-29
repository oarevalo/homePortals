<?xml version="1.0"?> 
<xsl:stylesheet version="1.1" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" />
	<xsl:variable name="HomePortalsPath" select="'/Home/'" />
	
	 <xsl:template match="/">
		<html>
			<head>	
				<script>
					var renderURL = "<xsl:value-of select="$HomePortalsPath" />?currentHome=" + document.location.pathname;
					window.location.replace(renderURL);
				</script>
				<style type="text/css">
					body {
						font-weight:bold;
						font-size:11px;
						font-family:verdana;
					}
				</style>
			</head>
			<body>
				<img align="absmiddle">
					<xsl:attribute name="src">
						<xsl:value-of select="$HomePortalsPath" />
						Common/Images/loading_ring.gif
					</xsl:attribute>
				</img>
				Please wait while loading page...
			</body>
		</html>
	 </xsl:template>
	 	
</xsl:stylesheet>