<!--- Weather.cfm

This module displays weather information from the Weather Channel

1/7/06 - oarevalo - created

Catalog entry:
<!-- ********   weather  ************ -->
<module access="general" id="WeatherChannel" name="weather">
	<description>
		Weather information from the Weather Channel.
	</description>
	<attributes>
		<attribute description="Zip-code" name="ZipCode" required="true"/>
	</attributes>
</module>
--->
<cfset args = Attributes.Module.xmlAttributes>

<cfparam name="args.zipcode" type="string" default="">

<cfset baseURL = "http://voap.weather.com/weather/oap/" & args.zipcode>
<cfset key = "55c0c97e028b5dfa67930e84e9643ae7">
<cfset template = "GENXH">
<cfset par = "1003790258">
<cfset unit = "0">

<cfif args.zipcode eq "">
	<p align="center">
		Please use the control panel to enter the zip code to display weather information.
	</p>
<cfelse>
	<cfoutput>
		<div align="center">
			<script src="#baseURL#?template=#template#&par=#par#&unit=#unit#&key=#key#"></script>
		</div>
	</cfoutput>
</cfif>


