<cfoutput>
<cfset config = application["_modelglue"].configuration>
<div id="infobox">
<p>
    <b>ApplicationMapping:</b> #config.applicationMapping#<br>
    <b>EventValue:</b> #config.EVENTVALUE#<br>
    <b>DefaultEvent:</b> #config.DEFAULTEVENT#<br>
</p>
</div>
</cfoutput>

