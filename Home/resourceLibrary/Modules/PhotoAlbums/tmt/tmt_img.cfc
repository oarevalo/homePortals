<!--- 
/** 
* Copyright 2004 massimocorner.com
* tmt_img ColdFusion Component 
* Get dimensions, crop or resize jpg and png files. Require ColdFusion 6.1 or above
* @output      supressed 
* @author      Massimo Foti (massimo@massimocorner.com). Very special thanks to Rudi
* @version     2.0.3, 2005-10-18
 */
  --->
<cfcomponent hint="Get dimensions, crop or resize jpg and png files. Require ColdFusion 6.1 or above" output="false">

	<!--- Ensure this file gets compiled using iso-8859-1 charset --->
	<cfprocessingdirective pageencoding="iso-8859-1">
	
	<!--- Set instance variables --->
	<cfscript>
	// Default imageType is jpg
	variables.imgType = "jpg";
	// By default the CFC throws an exception if it fails to save an image to disk
	variables.throwOnSave = true;
	// Rendering hints used for transformations
	variables.jHints = createObject("java","java.awt.RenderingHints");
	// Set Bilinear as default interpolation type. It may be turned to nearest-neighbor or bicubic using the init() method
	variables.interpolationType = variables.jHints.VALUE_INTERPOLATION_BILINEAR;
	// Default to a rendering algorithm with a preference for output quality. It may be turned off using the init() method
	variables.renderQuality = variables.jHints.VALUE_RENDER_QUALITY;
	// Default color rendering to quality. It may be set using the init() method
	variables.colorRendering = variables.jHints.VALUE_COLOR_RENDER_QUALITY;
	// Dithering is turned on by default. It may be turned off using the init() method 
	variables.dithering = variables.jHints.VALUE_DITHER_ENABLE;
	// Antialiasing is turned off by default. It may be turned on using the init() method 
	variables.antialiasing = variables.jHints.VALUE_ANTIALIAS_OFF;
	// Default to an image-scaling algorithm that gives higher priority to image smoothness than scaling speed. It may be turned on using the init() method 
	variables.scalingQuality = createObject("java","java.awt.Image").SCALE_SMOOTH;
    </cfscript>
	
	<!--- 
	/** 
	* Pseudo-constructor, it ensure custom settings are loaded inside the CFC. 
		Use it only if you want to modify default settings
	* @access      public
	* @output      suppressed 
	* @param       imgType (string)              Optional. Default to jpg. Image type used by the CFC (only jpg or png allowed). Default to jpg
	* @param       interpolationType (string)    Optional. Default to bilinear. By default the CFC use a bilinear algorithm for image interpolation; you can set it to nearest_neighbor or bicubic. 
					Please note bicubic works only on Java 1.5. See http://java.sun.com/j2se/1.5.0/docs/guide/2d/new_features.html
	* @param       scalingQuality (boolean)      Optional. Default to true. By default the CFC use an image-scaling algorithm that gives higher priority to image smoothness rather than scaling speed. 
					This is often the most important among all the quality related settings for resize operations. 
					Turn it off if you prefer to emphasize speed
	* @param       throwOnSave (boolean)         Optional. Default to true. By default the CFC throws an exception if it fails to save an image on disk. 
					Set this to false if you prefer to have the CFC returning false instead
	* @param       renderQuality (boolean)       Optional. Default to true. By default the CFC use a rendering algorithm with a preference for output quality. 
					Turn it off if you prefer to emphasize speed
	* @param       colorRendering (boolean)      Optional. Default to true. By default the CFC use a color rendering algorithm with a preference for output quality. 
					Turn it off if you prefer to emphasize speed
	* @param       dithering (boolean)           Optional. Default to true. By default dithering is turned on, set it to false if you want to turn it off
	* @param       antialiasing (boolean)        Optional. Default to false. By default antialiasing is turned off, set it to false if you want to turn it on
	* @exception   tmt_img
	 */
	  --->
	<cffunction name="init" access="public" output="false" hint="
		Pseudo-constructor, it ensure custom settings are loaded inside the CFC. 
		Use it only if you want to modify default settings">
		<cfargument name="imgType" type="string" required="false" default="jpg" hint="
			Image type used by the CFC (only jpg or png allowed). Default to jpg">
		<cfargument name="interpolationType" type="string" required="false" default="bilinear" hint="
			By default the CFC use a bilinear algorithm for image interpolation; you can set it to nearest_neighbor or bicubic. 
			Please note bicubic works only on Java 1.5. See http://java.sun.com/j2se/1.5.0/docs/guide/2d/new_features.html">
		<cfargument name="scalingQuality" type="boolean" required="false" default="true" hint="
			By default the CFC use an image-scaling algorithm that gives higher priority to image smoothness rather than scaling speed. 
			This is often the most important among all the quality related settings for resize operations. 
			Turn it off if you prefer to emphasize speed">
		<cfargument name="throwOnSave" type="boolean" required="false" default="true" hint="
			By default the CFC throws an exception if it fails to save an image on disk. 
			Set this to false if you prefer to have the CFC returning false instead">
		<cfargument name="renderQuality" type="boolean" required="false" default="true" hint="
			By default the CFC use a rendering algorithm with a preference for output quality. 
			Turn it off if you prefer to emphasize speed">
		<cfargument name="colorRendering" type="boolean" required="false" default="true" hint="
			By default the CFC use a color rendering algorithm with a preference for output quality. 
			Turn it off if you prefer to emphasize speed">
		<cfargument name="dithering" type="boolean" required="false" default="true" hint="
			By default dithering is turned on, set it to false if you want to turn it off">
		<cfargument name="antialiasing" type="boolean" required="false" default="false" hint="
			By default antialiasing is turned off, set it to true if you want to turn it on">
		<cfif ListFind("jpg,png", arguments.imgType) NEQ 0>
			<cfset variables.imgType=arguments.imgType>
		<cfelse>
			<cfthrow message="Only jpg or png allowed" type="tmt_img">
		</cfif>
		<cfif ListFind("bilinear,nearest_neighbor,bicubic", arguments.interpolationType) NEQ 0>
			<cfscript>
			if(arguments.interpolationType EQ "bilinear"){
				variables.interpolationType = variables.jHints.VALUE_INTERPOLATION_BILINEAR;
			}
			if(arguments.interpolationType EQ "nearest_neighbor"){
				variables.interpolationType = variables.jHints.VALUE_INTERPOLATION_NEAREST_NEIGHBOR;
			}		
			if(arguments.interpolationType EQ "bicubic"){
				variables.interpolationType = variables.jHints.VALUE_INTERPOLATION_BICUBIC;
			}		
			</cfscript>
		<cfelse>
			<cfthrow message="Only bilinear, nearest_neighbor and bicubic interpolation are supported" type="tmt_img">
		</cfif>
		<cfscript>
		if(arguments.throwOnSave){
			variables.throwOnSave = true;
		}
		else{
			variables.throwOnSave = false;
		}
		// Scaling quality heavily affect the output
		if(arguments.scalingQuality){
			variables.scalingQuality = createObject("java","java.awt.Image").SCALE_SMOOTH;
		}
		else{
			variables.scalingQuality = createObject("java","java.awt.Image").SCALE_FAST;
		}	
		// Set rendering hints used for transformations, choosing between quality and speed
		if(arguments.renderQuality){
			variables.renderQuality = variables.jHints.VALUE_RENDER_QUALITY;
		}
		else{
			variables.renderQuality = variables.jHints.VALUE_RENDER_SPEED;
		}
		if(arguments.colorRendering){
			variables.colorRendering = variables.jHints.VALUE_COLOR_RENDER_QUALITY;
		}
		else{
			variables.colorRendering = variables.jHints.VALUE_COLOR_RENDER_SPEED;
		}
		if(arguments.dithering){
			variables.dithering = variables.jHints.VALUE_DITHER_ENABLE;
		}
		else{
			variables.dithering = variables.jHints.VALUE_DITHER_DISABLE;
		}	
		if(arguments.antialiasing){
			variables.antialiasing = variables.jHints.VALUE_ANTIALIAS_ON;
		}
		else{
			variables.antialiasing = variables.jHints.VALUE_ANTIALIAS_OFF;
		}		
		</cfscript>
		<!--- Return the current instance of the CFC --->
		<cfreturn this>
	</cffunction>
	
	<!--- 
	/** 
	* Resize a jpg or png image file
	* @access      public
	* @output      suppressed 
	* @param       source (string)               Required. Original image path, either local or absolute
	* @param       destination (string)          Optional. Default to #addPrefix(arguments.source)#. Resized image path, either local or absolute
	* @param       newWidth (numeric)            Optional. Default to 100. New width (pixels). Default to 100
	* @return      boolean
	 */
	  --->
	<cffunction name="resize" access="public" output="false" returntype="boolean" hint="Resize a jpg or png image file">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addPrefix(arguments.source)#" hint="Resized image path, either local or absolute">
		<cfargument name="newWidth" type="numeric" required="false" default="100" hint="New width (pixels). Default to 100">
		<cfscript>
		var jFileIn = urlToJavaFile(arguments.source, true);
		var jFileOut = urlToJavaFile(arguments.destination);
		// Convert the file.io object into a buffered image
		var imgBuffer = javaFileToJavaImg(jFileIn);
		// Resize the buffered image
		var thumb = bufferedResize(imgBuffer, arguments.newWidth);
		// Write the resized image to disk
		return  saveJavaImg(thumb, jFileOut);
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Resize a buffered image
	* @access      private
	* @output      suppressed 
	* @param       imgBuffer                     Required. Java buffered image
	* @param       newWidth (numeric)            Optional. Default to 100. New width (pixels). Default to 100
	* @exception   tmt_img
	 */
	  --->
	<cffunction name="bufferedResize" access="private" output="false" hint="Resize a buffered image">
		<cfargument name="imgBuffer" required="true" hint="Java buffered image">
		<cfargument name="newWidth" type="numeric" required="false" default="100" hint="New width (pixels). Default to 100">
		<cfscript>
		// Read original image dimensions
		var imhW = arguments.imgBuffer.getWidth();
		var imgH = arguments.imgBuffer.getHeight();
		// Calculate scale
		var scale = arguments.newWidth / imhW;
		// Define new dimensions
		var scaledW = Int((scale * imhW));
		var scaledH = Int((scale * imgH));
		// Create the new image object
		var outBufferedImg = createJavaImg(scaledW, scaledH);
		// Create the Graphics2D object	
		var jGraphics2D = getJavaGraphics2D(outBufferedImg);
		// Creates a scaled version of the source image
		var scaledImg = arguments.imgBuffer.getScaledInstance(JavaCast("int", scaledW), JavaCast("int", scaledH), variables.scalingQuality);	
		</cfscript>
		<cftry>
			<cfscript>
			// Draw the image
			jGraphics2D.drawImage(scaledImg, JavaCast("int", 0), JavaCast("int", 0), createJavaObserver());
			jGraphics2D.dispose();
			</cfscript>
			<cfcatch type="any">
				<cfthrow message="Failed to resize image #cfcatch.Message#" type="tmt_img">
			</cfcatch>
		</cftry>
		<cfreturn outBufferedImg>
	</cffunction>
	
	<!--- 
	/** 
	* Create a subimage, defined by a specified rectangular region, out of a jpg or png image file
	* @access      public
	* @output      suppressed 
	* @param       source (string)               Required. Original image path, either local or absolute
	* @param       destination (string)          Optional. Default to #addPrefix(arguments.source, 'crop_')#. Cropped image path, either local or absolute
	* @param       areaWidth (numeric)           Optional. Default to 100. Width of the specified rectangular region (pixel). Default to 100
	* @param       areaHeight (numeric)          Optional. Default to 100. Height of the specified rectangular region (pixel). Default to 100
	* @param       x (numeric)                   Optional. Default to 0. Starting coordinate in the x axis (pixel). Default to 0
	* @param       y (numeric)                   Optional. Default to 0. Starting coordinate in the y axis (pixel). Default to 0
	* @return      boolean
	 */
	  --->
	<cffunction name="crop" access="public" output="false" returntype="boolean" hint="Create a subimage, defined by a specified rectangular region, out of a jpg or png image file">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addPrefix(arguments.source, 'crop_')#" hint="Cropped image path, either local or absolute">
		<cfargument name="areaWidth" type="numeric" required="false" default="100" hint="Width of the specified rectangular region (pixel). Default to 100">
		<cfargument name="areaHeight" type="numeric" required="false" default="100" hint="Height of the specified rectangular region (pixel). Default to 100">
		<cfargument name="x" type="numeric" required="false" default="0" hint="Starting coordinate in the x axis (pixel). Default to 0">
		<cfargument name="y" type="numeric" required="false" default="0" hint="Starting coordinate in the y axis (pixel). Default to 0">
		<cfscript>
		var jFileIn = urlToJavaFile(arguments.source, true);
		var jFileOut = urlToJavaFile(arguments.destination);
		// Convert the file.io object into a buffered image
		var imgBuffer = javaFileToJavaImg(jFileIn);
		// Create the buffered cropped image
		var crop = bufferedCrop(imgBuffer, arguments.areaWidth, arguments.areaHeight, arguments.x, arguments.y);
		// Write the thumbnail image to disk
		return saveJavaImg(crop, jFileOut);
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* First resize, then create a subimage, defined by a specified rectangular region, out of a jpg or png image file
	* @access      public
	* @output      suppressed 
	* @param       source (string)               Required. Original image path, either local or absolute
	* @param       destination (string)          Optional. Default to #addPrefix(arguments.source, 'crop_')#. Cropped/resized image path, either local or absolute
	* @param       resizeTo (numeric)            Optional. Default to 200. Width used to resize the original image. Default to 200
	* @param       areaWidth (numeric)           Optional. Default to 100. Width of the specified rectangular region. Default to 100
	* @param       areaHeight (numeric)          Optional. Default to 100. Height of the specified rectangular region. Default to 100
	* @param       x (numeric)                   Optional. Default to 0. Starting coordinate in the x axis (pixel). Default to 0
	* @param       y (numeric)                   Optional. Default to 0. Starting coordinate in the y axis (pixel). Default to 0
	* @return      boolean
	 */
	  --->
	<cffunction name="cropResize" access="public" output="false" returntype="boolean" hint="First resize, then create a subimage, defined by a specified rectangular region, out of a jpg or png image file">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addPrefix(arguments.source, 'crop_')#" hint="Cropped/resized image path, either local or absolute">
		<cfargument name="resizeTo" type="numeric" required="false" default="200" hint="Width used to resize the original image. Default to 200">
		<cfargument name="areaWidth" type="numeric" required="false" default="100" hint="Width of the specified rectangular region. Default to 100">
		<cfargument name="areaHeight" type="numeric" required="false" default="100" hint="Height of the specified rectangular region. Default to 100">
		<cfargument name="x" type="numeric" required="false" default="0" hint="Starting coordinate in the x axis (pixel). Default to 0">
		<cfargument name="y" type="numeric" required="false" default="0" hint="Starting coordinate in the y axis (pixel). Default to 0">
		<cfscript>
		var jFileIn = urlToJavaFile(arguments.source, true);
		var jFileOut = urlToJavaFile(arguments.destination);
		// Convert the file.io object into a buffered image
		var imgBuffer = javaFileToJavaImg(jFileIn);
		// First resize the image and store the resulting buffer
		var thumb = bufferedResize(imgBuffer, arguments.resizeTo);	
		// Create the buffered cropped image
		var crop = bufferedCrop(thumb, arguments.areaWidth, arguments.areaHeight, arguments.x, arguments.y);
		// Write the resized/cropped image to disk
		return saveJavaImg(crop, jFileOut);
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Create a buffered subimage, defined by a specified rectangular region, out of buffered image
	* @access      private
	* @output      enabled 
	* @param       imgBuffer                     Required. Java buffered image
	* @param       areaWidth (numeric)           Optional. Default to 100. Width of the specified rectangular region. Default to 100
	* @param       areaHeight (numeric)          Optional. Default to 100. Height of the specified rectangular region. Default to 100
	* @param       x (numeric)                   Optional. Default to 0. Starting coordinate in the x axis (pixel). Default to 0
	* @param       y (numeric)                   Optional. Default to 0. Starting coordinate in the y axis (pixel). Default to 0
	* @exception   tmt_img
	 */
	  --->
	<cffunction name="bufferedCrop" access="private" output="true" hint="Create a buffered subimage, defined by a specified rectangular region, out of buffered image">
		<cfargument name="imgBuffer" required="true" hint="Java buffered image">
		<cfargument name="areaWidth" type="numeric" required="false" default="100" hint="Width of the specified rectangular region. Default to 100">
		<cfargument name="areaHeight" type="numeric" required="false" default="100" hint="Height of the specified rectangular region. Default to 100">
		<cfargument name="x" type="numeric" required="false" default="0" hint="Starting coordinate in the x axis (pixel). Default to 0">
		<cfargument name="y" type="numeric" required="false" default="0" hint="Starting coordinate in the y axis (pixel). Default to 0">
		<cfscript>
		// Read image dimensions
		var imgW = arguments.imgBuffer.getWidth();
		var imgH = arguments.imgBuffer.getHeight();
		// Create image output
		var outBufferedImg = createJavaImg(imgW, imgH);
		// Initialize a Graphics2D object
		var jGraphics2D = getJavaGraphics2D(outBufferedImg);
		// Perform the crop operation
		var jCrop = outBufferedImg.getSubimage(JavaCast("int", arguments.x),JavaCast("int", arguments.y), JavaCast("int", arguments.areaWidth), JavaCast("int", arguments.areaHeight)); 
		</cfscript>
		<cftry>
			<cfscript>
		// Draw the cropped image
		jGraphics2D.drawImage(arguments.imgBuffer, JavaCast("int", 0), JavaCast("int", 0), createJavaObserver());
		jGraphics2D.dispose();
		</cfscript>
			<cfcatch type="any">
				<cfthrow message="Failed to crop image #cfcatch.Message#" type="tmt_img">
			</cfcatch>
		</cftry>
		<cfreturn jCrop>
	</cffunction>
	
	<!--- Dimensions related methods --->
	
	<!--- 
	/** 
	* Returns a structure containing the dimensions (pixels) of a jpg, png or gif image file. Keys are: width and height
	* @access      public
	* @output      suppressed 
	* @param       imgPath (string)              Required. Image path, either local or absolute
	* @exception   tmt_img
	* @return      struct
	 */
	  --->
	<cffunction name="getDimensions" access="public" output="false" returntype="struct" hint="Returns a structure containing the dimensions (pixels) of a jpg, png or gif image file. Keys are: width and height">
		<cfargument name="imgPath" type="string" required="true" hint="Image path, either local or absolute">
		<cfscript>
		var imgStruct = StructNew();
		var jFile = urlToJavaFile(arguments.imgPath, true);
		var jBufferedImg = javaFileToJavaImg(jFile);
		</cfscript>
		<cftry>
			<!--- Get the info and store them into the structure --->
			<cfset imgStruct.width=jBufferedImg.getWidth()>
			<cfset imgStruct.height=jBufferedImg.getHeight()>
			<cfcatch type="any">
				<cfthrow message="Failed to read image dimensions. The component can read only jpg, gif and png files" type="tmt_img">
			</cfcatch>
		</cftry>
		<cfreturn imgStruct>
	</cffunction>
	
	<!--- 
	/** 
	* Returns the width (pixels) of a jpg, png or gif image file
	* @access      public
	* @output      suppressed 
	* @param       imgPath (string)              Required. Image path, either local or absolute
	* @return      numeric
	 */
	  --->
	<cffunction name="getWidth" access="public" output="false" returntype="numeric" hint="Returns the width (pixels) of a jpg, png or gif image file">
		<cfargument name="imgPath" type="string" required="true" hint="Image path, either local or absolute">
		<cfreturn getDimensions(imgPath).width>
	</cffunction>
	
	<!--- 
	/** 
	* Returns the height (pixels) of a jpg, png or gif image file
	* @access      public
	* @output      suppressed 
	* @param       imgPath (string)              Required. Image path, either local or absolute
	* @return      numeric
	 */
	  --->
	<cffunction name="getHeight" access="public" output="false" returntype="numeric" hint="Returns the height (pixels) of a jpg, png or gif image file">
		<cfargument name="imgPath" type="string" required="true" hint="Image path, either local or absolute">
		<cfreturn getDimensions(imgPath).height>
	</cffunction>
	
	<!--- 
	/** 
	* Returns the size (KB) of a jpg, png or gif image file
	* @access      public
	* @output      suppressed 
	* @param       imgPath (string)              Required. Image path, either local or absolute
	* @return      numeric
	 */
	  --->
	<cffunction name="getSize" access="public" output="false" returntype="numeric" hint="Returns the size (KB) of a jpg, png or gif image file">
		<cfargument name="imgPath" type="string" required="true" hint="Image path, either local or absolute">
		<cfreturn urlToJavaFile(arguments.imgPath, true).length()/1000>
	</cffunction>
	
	<!--- Private utility methods --->
	
	<!--- 
	/** 
	* Adds a prefix to a filename
	* @access      private
	* @output      enabled 
	* @param       pathToPrefix (string)         Required. File path, either local or absolute
	* @param       prefixString (string)         Optional. Default to thumb_. String used as prefix
	* @return      string
	 */
	  --->
	<cffunction name="addPrefix" access="private" output="true" returntype="string" hint="Adds a prefix to a filename">
		<cfargument name="pathToPrefix" type="string" required="yes" hint="File path, either local or absolute">
		<cfargument name="prefixString" type="string" required="no" default="thumb_" hint="String used as prefix">
		<cfscript>
		var prefixedPath = "";
		var dirPath = GetDirectoryFromPath(arguments.pathToPrefix);
		var filename=GetFileFromPath(arguments.pathToPrefix);
		// If the directory is the current one, skip it
		if((dirPath EQ "/") OR (dirPath EQ "\")){
			dirPath = "";
		}
		return dirPath & arguments.prefixString & filename;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Create a java.awt.image.BufferedImage object
	* @access      private
	* @output      suppressed 
	* @param       imgWidth (numeric)            Required. Default to 100. Image width. Default to 100
	* @param       imgHeight (numeric)           Required. Default to 100. Image height. Default to 100
	 */
	  --->
	<cffunction name="createJavaImg" access="private" output="false" hint="Create a java.awt.image.BufferedImage object">
		<cfargument name="imgWidth" type="numeric" required="yes" default="100" hint="Image width. Default to 100">
		<cfargument name="imgHeight" type="numeric" required="yes" default="100" hint="Image height. Default to 100">
		<cfreturn createObject("java","java.awt.image.BufferedImage").init(JavaCast("int", arguments.imgWidth), JavaCast("int", arguments.imgHeight), JavaCast("int", 1))>
	</cffunction>
	
	<!--- 
	/** 
	* Create a dummy Java ImageObserver object. Since CFML can't create Java nulls, we use this hack
	* @access      private
	* @output      suppressed 

	 */
	  --->
	<cffunction name="createJavaObserver" access="private" output="false" hint="Create a dummy Java ImageObserver object. Since CFML can't create Java nulls, we use this hack">
		<cfreturn createObject("java","java.awt.Container").init()>
	</cffunction>
	
	<!--- 
	/** 
	* Turn any system path, either local or absolute, into a fully qualified one
	* @access      private
	* @output      suppressed 
	* @param       path (string)                 Required. Abstract pathname
	* @return      string
	 */
	  --->
	<cffunction name="getAbsolutePath" access="private" output="false" returntype="string" hint="Turn any system path, either local or absolute, into a fully qualified one">
		<cfargument name="path" type="string" required="true" hint="Abstract pathname">
		<cfscript>
		var jFile = createObject("java","java.io.File").init(arguments.path);
		if(jFile.isAbsolute()){
			return arguments.path;
		}
		else{
			return ExpandPath(arguments.path);
		}
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Get a Java Graphics2D object out of a BufferedImage using the current settings
	* @access      private
	* @output      suppressed 
	* @param       imgBuffer (string)            Required. Java buffered image
	 */
	  --->
	<cffunction name="getJavaGraphics2D" access="private" output="false" hint="Get a Java Graphics2D object out of a BufferedImage using the current settings">
		<cfargument name="imgBuffer" type="string" required="true" hint="Java buffered image">
		<cfscript>
		// Create the Graphics2D object	
		var jGraphics2D = arguments.imgBuffer.createGraphics();
		// Set interpolation type
		jGraphics2D.setRenderingHint(variables.jHints.KEY_INTERPOLATION, variables.interpolationType);
		// Set rendering algorithms
		jGraphics2D.setRenderingHint(variables.jHints.KEY_RENDERING, variables.renderQuality);
		jGraphics2D.setRenderingHint(variables.jHints.KEY_COLOR_RENDERING, variables.colorRendering);		
		jGraphics2D.setRenderingHint(variables.jHints.KEY_DITHERING, variables.dithering);
		jGraphics2D.setRenderingHint(variables.jHints.KEY_ANTIALIASING, variables.antialiasing);
		return jGraphics2D;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Turn a file path into a java.io.File object
	* @access      private
	* @output      suppressed 
	* @param       imgPath (string)              Required. File path, either local or absolute
	* @param       checkExist (boolean)          Optional. Default to false. Throw an exception if the file doesn't exists
	* @exception   tmt_img
	 */
	  --->
	<cffunction name="urlToJavaFile" access="private" output="false" hint="Turn a file path into a java.io.File object">
		<cfargument name="imgPath" type="string" required="true" hint="File path, either local or absolute">
		<cfargument name="checkExist" type="boolean" required="no" default="false" hint="Throw an exception if the file doesn't exists">
		<cfset var absolutePath=getAbsolutePath(arguments.imgPath)>
		<!--- Validate file existance --->
		<cfif arguments.checkExist AND (NOT FileExists(absolutePath))>
			<cfthrow message="#absolutePath# does not exist" type="tmt_img">
		</cfif>
		<cfreturn createObject("java","java.io.File").init(absolutePath)>
	</cffunction>
	
	<!--- 
	/** 
	* Turn a java.io.File object into a javax.imageio.ImageIO object
	* @access      private
	* @output      suppressed 
	* @param       jFile                         Required. Java File object
	 */
	  --->
	<cffunction name="javaFileToJavaImg" access="private" output="false" hint="Turn a java.io.File object into a javax.imageio.ImageIO object">
		<cfargument name="jFile" required="yes" hint="Java File object">
		<cfreturn createObject("java","javax.imageio.ImageIO").read(arguments.jFile)>
	</cffunction>
	
	<!--- 
	/** 
	* Save a Java image to disk
	* @access      private
	* @output      suppressed 
	* @param       imgBuffer                     Required. Java buffered image (source)
	* @param       imgBufferOut                  Required. Java buffered image (destination)
	* @exception   tmt_img
	* @return      boolean
	 */
	  --->
	<cffunction name="saveJavaImg" access="private" output="false" returntype="boolean" hint="Save a Java image to disk">
		<cfargument name="imgBuffer" required="yes" hint="Java buffered image (source)">
		<cfargument name="imgBufferOut" required="yes" hint="Java buffered image (destination)">
		<cfset var fileSaved=true>
		<cftry>
			<cfset fileSaved=createObject("java","javax.imageio.ImageIO").write(arguments.imgBuffer, variables.imgType, arguments.imgBufferOut)>
			<cfcatch type="any">
				<!--- Failed to save the file. Depending on the current settings, we either throw an exception or return false --->
				<cfif variables.throwOnSave>
					<cfthrow message="Failed to save image" type="tmt_img">
				</cfif>
				<cfset fileSaved=false>
			</cfcatch>
		</cftry>
		<cfreturn fileSaved>
	</cffunction>
	
</cfcomponent>