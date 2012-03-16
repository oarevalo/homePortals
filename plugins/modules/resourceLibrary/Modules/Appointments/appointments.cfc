<cfcomponent displayname="appointments" extends="homePortals.plugins.modules.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var csCfg = this.controller.getContentStoreConfigBean();
			
			cfg.setModuleClassName("appointments");
			cfg.setView("default", "main");
			cfg.setView("htmlHead", "htmlHead");
	
			csCfg.setDefaultName("myAppointments");
			csCfg.setRootNode("calendar");
		</cfscript>	
	</cffunction>

	<!---------------------------------------->
	<!--- saveAppointment                  --->
	<!---------------------------------------->
	<cffunction name="saveAppointment" access="remote" output="true">
		<cfargument name="id" type="string" required="true">
		<cfargument name="description" type="string" default="">
		<cfargument name="time" type="string" default="">
		<cfargument name="date" type="string" default="">
		<cfargument name="subject" type="string" default="">
	
		<cfscript>
			var moduleID = this.controller.getModuleID();
			var aUpdateNode = 0;
			var myContentStore = 0;
			var xmlDoc = 0;
			var tmpDate = 0;

			// validate form
			if(arguments.time eq "" and arguments.subject eq "") throwException("Both time and subject cannot be empty");
			if(arguments.date eq "") throwException("Please enter the date of the appointment");
			
			// check for recognized values of date and time
			if(arguments.date eq "today") arguments.date = now();
			if(arguments.date eq "tomorrow") arguments.date = dateAdd("d",1,now());
			if(arguments.date eq "yesterday") arguments.date = dateAdd("d",-1,now());
			
			if(Not isDate(arguments.date)) throwException("Please enter a valid date");
			
			// parse date
			tmpDate = dateFormat(arguments.date,"mm/dd/yyyy");
			
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();
	
			// check that we are updating the blog from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throwException("Only the owner can make changes.");
			}
		
			aUpdateNode = xmlSearch(xmlDoc, "//item[@id='#arguments.id#']");
			
			if(arguments.id eq "" or arrayLen(aUpdateNode) eq 0) {
				// create new node
				newNode = xmlElemNew(xmlDoc,"item");
				newNode.xmlText = arguments.description;
				newNode.xmlAttributes["time"] = xmlFormat(arguments.time);
				newNode.xmlAttributes["date"] = dateFormat(tmpDate,"mm/dd/yyyy");
				newNode.xmlAttributes["subject"] = xmlFormat(arguments.subject);
				newNode.xmlAttributes["id"] = createUUID();
				arrayAppend(xmlDoc.xmlRoot.xmlChildren, newNode);
	
			} else {
				// update node
				aUpdateNode[1].xmlText = arguments.description;
				aUpdateNode[1].xmlAttributes["time"] = xmlFormat(arguments.time);
				aUpdateNode[1].xmlAttributes["date"] = dateFormat(tmpDate,"mm/dd/yyyy");
				aUpdateNode[1].xmlAttributes["subject"] = xmlFormat(arguments.subject);
	
			}
			
			// save changes to document
			myContentStore.save(xmlDoc);
			
			// notify client of change
			this.controller.setEventToRaise("onSave");
			this.controller.setMessage("Appointment Saved");
			this.controller.setScript("#moduleID#.getView()");			
		</cfscript>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- deleteAppointment                --->
	<!---------------------------------------->
	<cffunction name="deleteAppointment" access="remote" output="true">
		<cfargument name="id" type="string" required="true">
		<cfargument name="date" type="string" default="1/1/1800">
		
		<cfscript>
			var xmlDoc = 0;
			var myContentStore = 0;
			var i = 0;
			var tmpNode = 0;
			
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();
	
			// check that we are updating the content store from the owners page
			if(this.controller.getUserInfo().username neq myContentStore.getOwner()) {
				throwException("You must be signed-in and be the owner of this page to make changes.");
			}
	
			tmpNode = xmlDoc.xmlRoot;
			for(i=1;i lte ArrayLen(tmpNode.xmlChildren);i=i+1) {
				if(StructKeyExists(tmpNode.xmlChildren[i].xmlAttributes,"id") and tmpNode.xmlChildren[i].xmlAttributes.id eq arguments.id)
					ArrayClear(tmpNode.xmlChildren[i]);
			}	
			
			myContentStore.save(xmlDoc);
			this.controller.setEventToRaise("onDelete");
			this.controller.setMessage("Appointment Deleted");
			this.controller.setScript("#moduleID#.getView('','',{date:'#arguments.date#'})");			
		</cfscript>
	</cffunction>	
	
	<!---------------------------------------->
	<!--- saveSettings                     --->
	<!---------------------------------------->		
	<cffunction name="saveSettings" access="public" output="true">
		<cfargument name="url" type="string" default="">
		
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var tmpScript = "";
			var regExp = "^\w+$";
	
			if(arguments.url neq "" and not REFind(regExp, arguments.url))
				this.controller.setMessage("Names may only contain alphabet letters and the _ character.");
			else {
				cfg.setPageSetting("calendarURL", arguments.url);
				this.controller.setMessage("Settings changed");
				this.controller.setScript("#moduleID#.getView();");
				this.controller.savePageSettings();
			}
		</cfscript>
	</cffunction>
	
	
	
	<!---- *********************** PRIVATE FUNCTIONS *************************** --->
	
	<!-------------------------------------->
	<!--- setContentStoreURL             --->
	<!-------------------------------------->
	<cffunction name="setContentStoreURL" access="private" output="false"
				hint="Sets the content store URL specified on the page.">
		<cfscript>
			var tmpURL = "";
			var cfg = 0;
			var cs_cfg = 0;
			
			// get environment info 
			cfg = this.controller.getModuleConfigBean();
			cs_cfg = this.controller.getContentStoreConfigBean();
			
			// get the URL provided by the user
			tmpURL = cfg.getPageSetting("calendarURL");
			
			cs_cfg.setURL(tmpURL);
		</cfscript>
	</cffunction>
	
	
	<!-------------------------------------->
	<!--- getAppointmentsData            --->
	<!-------------------------------------->
	<cffunction name="getAppointmentsData" access="private" output="false" returntype="query"
				hint="Returns a query with appointments data">
		<cfscript>
			var myContentStore = 0;
			var xmlDoc = 0;
			var qryData = 0;
			var aGroups = 0;
			var tmpNode = 0;
			var tmpDate = 0;
			var i = 0;
			
			// get content store
			setContentStoreURL();
			myContentStore = this.controller.getContentStore();
			xmlDoc = myContentStore.getXMLData();
	
			// put data in a query so it can be searched easier 
			qryData = QueryNew("eventDate,eventDay,eventWeek,eventMonth,eventYear,eventTime,description,subject,id");
				
			for(i=1;i lte ArrayLen(xmlDoc.xmlroot.xmlChildren);i=i+1) {
				tmpNode = xmlDoc.xmlroot.xmlChildren[i];
				if(not structKeyExists(tmpNode.xmlAttributes,"date")) tmpNode.xmlAttributes["date"] = "";
				if(not structKeyExists(tmpNode.xmlAttributes,"subject")) tmpNode.xmlAttributes["subject"] = "";
	
				tmpDate = tmpNode.xmlAttributes.date;
				
				if(isDate(tmpDate)) {
					QueryAddRow(qryData);
					QuerySetCell(qryData,"eventDate", tmpDate);
					QuerySetCell(qryData,"eventDay", day(tmpDate));
					QuerySetCell(qryData,"eventWeek", week(tmpDate));
					QuerySetCell(qryData,"eventMonth", month(tmpDate));
					QuerySetCell(qryData,"eventYear", year(tmpDate));
					QuerySetCell(qryData,"eventTime", tmpNode.xmlAttributes.time);
					QuerySetCell(qryData,"description", tmpNode.xmlText);
					QuerySetCell(qryData,"subject", tmpNode.xmlAttributes.subject);
					QuerySetCell(qryData,"id", tmpNode.xmlAttributes.id);
				}
			}		
		</cfscript>
		<cfreturn qryData>
	</cffunction>
	
	
	<!-------------------------------------->
	<!--- getAppointments		         --->
	<!-------------------------------------->
	<cffunction name="getAppointments" access="private" output="false" returntype="query"
				hint="Returns a query with appointments for the given scope (day,week,month)">
		<cfargument name="date" type="date" required="true">
		<cfargument name="type" type="string" required="false" default="day" hint="day|week|month|agenda">
	
		<cfset var qryData = getAppointmentsData()>
		<cfset var tmpDateStr = dateFormat(arguments.date,"mm/dd/yyyy")>
		<cfset var tmpEndDate = "">
		
		<cfswitch expression="#arguments.type#">
			<cfcase value="day">
				<cfset tmpDate = createODBCDate(arguments.date)>
				<cfquery name="qryData" dbtype="query">
					SELECT *
						FROM qryData
						WHERE eventDate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpDateStr#">
						ORDER BY eventDate, eventTime
				</cfquery>
			</cfcase>
			
			<cfcase value="week">
				<cfquery name="qryData" dbtype="query">
					SELECT *
						FROM qryData
						WHERE eventWeek = #week(arguments.date)#
							AND eventYear = #Year(arguments.date)#
						ORDER BY eventDate, eventTime
				</cfquery>
			</cfcase>
			
			<cfcase value="month">
				<cfquery name="qryData" dbtype="query">
					SELECT *
						FROM qryData
						WHERE eventMonth = #Month(arguments.date)#
							AND eventYear = #Year(arguments.date)#
						ORDER BY eventDate, eventTime
				</cfquery>
			</cfcase>

			<cfcase value="agenda">
				<cfset tmpEndDate = dateFormat(dateAdd("d",45,arguments.date),"mm/dd/yyyy")>
				<cfquery name="qryData" dbtype="query">
					SELECT *
						FROM qryData
						WHERE eventDate >= <cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpDateStr#">
							AND eventDate <= <cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpEndDate#"> 
						ORDER BY eventDate, eventTime
				</cfquery>
			</cfcase>
		</cfswitch>
		<cfreturn qryData>
	</cffunction>
	
	<!-------------------------------------->
	<!--- getAppointmentByID	         --->
	<!-------------------------------------->
	<cffunction name="getAppointmentByID" access="private" output="false" returntype="query"
				hint="Returns a query with the appointment with the given ID">
		<cfargument name="id" type="string" required="false" default="">
	
		<cfset var qryData = getAppointmentsData()>
		<cfquery name="qryData" dbtype="query">
			SELECT *
				FROM qryData
				WHERE id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.id#">
		</cfquery>
		<cfreturn qryData>
	</cffunction>	
	
	<cffunction name="dump" access="private">
		<cfargument name="data">
		<cfdump var="#data#">
	</cffunction>
	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>
</cfcomponent>
