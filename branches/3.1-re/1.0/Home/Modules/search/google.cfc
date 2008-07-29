<!---
/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Google.cfc
 *
 * The Initial Developer of the Original Code is Andy Edmonds, andy@uzilla.net.
 * Portions created by the Initial Developer are Copyright (C) 2003
 * the Initial Developer. All Rights Reserved.
 *

 * ***** END LICENSE BLOCK ***** */
--->
<cfcomponent displayname="Andyed's Google API Component">
	<cffunction name="search" access="public" returntype="struct" hint="Returns an array of structs." >
		<cfargument name="q" type="string" required="true">
		<cfargument name="start" default="1">
		<cfargument name="maxResults"  default="10">
		<cfargument name="filter" type="boolean" default="false">
		<cfargument name="safesearch" type="boolean" default="false">
		<cfargument name="lr" type="string" default="">
		<cfargument name="restrict" type="string" default="">
		<!--- Local Variable for Return --->
		<cfset var arResult = arrayNew(1)>
		<cfset var arResults = arrayNew(1)>
		<cfset var arReturn = arrayNew(1)>
		<cfset var startrow = arguments.start>
		<cfset var results = "">
		<cfset var stResults = StructNew()>
		
		<cfset stResults.results = ArrayNew(1)>
		
		
		<cfinvoke 
		 webservice="http://api.google.com/GoogleSearch.wsdl"
		 method="doGoogleSearch"
		 returnvariable="aGoogleSearchResult">
			<cfinvokeargument name="key" value="#arguments.key#"/>
			<cfinvokeargument name="q" value="#arguments.q#"/>
			<cfinvokeargument name="start" value="#arguments.start#"/>
			<cfinvokeargument name="maxResults" value="10"/>
			<cfinvokeargument name="filter" value="#arguments.filter#"/>
			<cfinvokeargument name="safeSearch" value="#arguments.safesearch#"/>
		
			<cfinvokeargument name="lr" value=""/>
			<cfinvokeargument name="ie" value="UTF-8"/>
			<cfinvokeargument name="oe" value="UTF-8"/>
			<cfinvokeargument name="restrict" value=""/>
		</cfinvoke>

		<cfset results = aGoogleSearchResult.getResultElements()>
		<cfset stResults.count = aGoogleSearchResult.getEstimatedTotalResultsCount()>
		
		<cfloop from="1" to="#arrayLen(results)#" index="i">
			<cfscript>
				stResults.results[i] = structNew();
				stResults.results[i].url = results[i].getURL();
				stResults.results[i].title = results[i].getTitle();
				stResults.results[i].summary = ListAppend(results[i].getSummary(), results[i].getSnippet(), "<br/>");
				stResults.results[i].hostname = results[i].getHostName();
				stResults.results[i].cachedsize = results[i].getCachedSize();
			</cfscript>
		</cfloop>
		

<!--- 
allintext,allintitle,allinanchor, allinurl

<cfdump var="#aGoogleSearchResult.getResultElements()#">
	<cfinvokeargument name="filter" value="false"/>
	<cfinvokeargument name="safeSearch" value="false"/>

?hl=en&ie=UTF-8&oe=UTF-8&q=foo&btnG=Google+Search
	<cfinvokeargument name="lr" value="enter_value_here"/>
	<cfinvokeargument name="ie" value="UTF-8"/>
	<cfinvokeargument name="oe" value="UTF-8"/>
		<cfinvokeargument name="restrict" value="false"/>
	
	
	Methods  	 hashCode (returns int)
equals (returns boolean)
getURL (returns java.lang.String)
setURL (returns void)
getHostName (returns java.lang.String)
getSerializer (returns interface org.apache.axis.encoding.Serializer)
getDeserializer (returns interface org.apache.axis.encoding.Deserializer)
setHostName (returns void)
setSnippet (returns void)
getTypeDesc (returns org.apache.axis.description.TypeDesc)
getSummary (returns java.lang.String)
setSummary (returns void)
getSnippet (returns java.lang.String)
getTitle (returns java.lang.String)
setTitle (returns void)
getCachedSize (returns java.lang.String)
setCachedSize (returns void)
isRelatedInformationPresent (returns boolean)
setRelatedInformationPresent (returns void)
getDirectoryCategory (returns GoogleSearch.DirectoryCategory)
setDirectoryCategory (returns void)
getDirectoryTitle (returns java.lang.String)
setDirectoryTitle (returns void)
getClass (returns java.lang.Class)
wait (returns void)
wait (returns void)
wait (returns void)
notify (returns void)
notifyAll (returns void)

Methods  	 hashCode (returns int)
equals (returns boolean)
getEndIndex (returns int)
setEndIndex (returns void)
getSerializer (returns interface org.apache.axis.encoding.Serializer)
getDeserializer (returns interface org.apache.axis.encoding.Deserializer)
getTypeDesc (returns org.apache.axis.description.TypeDesc)
isDocumentFiltering (returns boolean)
setDocumentFiltering (returns void)
getSearchComments (returns java.lang.String)
setSearchComments (returns void)
getEstimatedTotalResultsCount (returns int)
setEstimatedTotalResultsCount (returns void)
isEstimateIsExact (returns boolean)
setEstimateIsExact (returns void)
getResultElements (returns [LGoogleSearch.ResultElement;)
setResultElements (returns void)
getSearchQuery (returns java.lang.String)
setSearchQuery (returns void)
getStartIndex (returns int)
setStartIndex (returns void)
getSearchTips (returns java.lang.String)
setSearchTips (returns void)
getDirectoryCategories (returns [LGoogleSearch.DirectoryCategory;)
setDirectoryCategories (returns void)
getSearchTime (returns double)
setSearchTime (returns void)
getClass (returns java.lang.Class)
wait (returns void)
wait (returns void)
wait (returns void)
notify (returns void)
notifyAll (returns void)
toString (returns java.lang.String)

	--->


		<cfreturn stResults>
	</cffunction>
</cfcomponent>