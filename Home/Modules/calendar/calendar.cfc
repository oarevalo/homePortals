<cfcomponent displayname="calendar">

	<!---------------------------------------->
	<!--- getCalendar                      --->
	<!---------------------------------------->
	<cffunction name="getCalendar" access="remote" output="true">
		<cfargument name="instanceName" type="string" default="cal">
		<cfargument name="date" type="string" default="#Now()#">
				
		<cfset var tmpHTML = "">

		<cfif arguments.date eq "">
			<cfset arguments.date = Now()>
		</cfif>
				
		<cftry>
			<cfsavecontent variable="tmpHTML">
				<cfscript>
					// Calculate dates and weeks to show on the table 
					if(Not IsDate(arguments.date)) arguments.date=Now();
					CurrentDate = DateFormat(arguments.date,"mm/dd/yyyy"); 
					currentYear = Year(currentDate);
					currentMonth = Month(currentDate);
					locvar_MagicDay = 7;
					Month_StartDate = CreateDate(CurrentYear,CurrentMonth,1);
					Month_EndDate = CreateDate(CurrentYear,CurrentMonth,DaysInMonth(Month_StartDate));
					Month_StartDay = DayOfWeek(Month_StartDate);
					if(Month_StartDay lte locvar_MagicDay) 
						Distance = locvar_MagicDay - Month_StartDay;
					else Distance = 7 + locvar_MagicDay - Month_StartDay;
					NewDate = DateAdd('D', Distance, Month_StartDate);
					Distance2 = day(month_enddate) - day(newdate);
					NumberOfValidWeeks = int(distance2/7)+1;				
					
					prevYear = DateFormat(DateAdd("y",-1,currentDate),"mm/dd/yyyy");
					nextYear = DateFormat(DateAdd("y",1,currentDate),"mm/dd/yyyy");
					prevMonth = DateFormat(DateAdd("m",-1,currentDate),"mm/dd/yyyy");
					nextMonth = DateFormat(DateAdd("m",1,currentDate),"mm/dd/yyyy");
				</cfscript>
				
				<div class="Calendar">
					<table border="0" align="center" cellpadding="0" cellspacing="0" class="CalendarTable">
						<tr> 
						  <td rowspan="8" valign="middle" nowrap align="center">  
							  <b>#CurrentYear#</b><br>
							  <a href="##" onclick="#Arguments.InstanceName#.getCalendar('#prevYear#');"><img src="/home/modules/calendar/i_previous_cal.gif" border="0" align="absmiddle" alt="Previous Year"></a>&nbsp;
							  <a href="##" onclick="#Arguments.InstanceName#.getCalendar('#nextYear#');"><img src="/home/modules/calendar/i_next_cal.gif" border="0" align="absmiddle" alt="Next Year"></a>
						  </td>
						  <td colspan="7" align="center">
								<b>#Left(MonthAsString(CurrentMonth),3)#</b>
								<a href="##" onclick="#Arguments.InstanceName#.getCalendar('#prevMonth#');"><img src="/home/modules/calendar/i_previous_cal.gif" border="0" align="absmiddle" alt="Previous Month"></a>&nbsp;
								<a href="##" onclick="#Arguments.InstanceName#.getCalendar('#nextMonth#');"><img src="/home/modules/calendar/i_next_cal.gif" border="0" align="absmiddle" alt="Next Month"></a>
						  </td>
						</tr>
						<tr> 
						  <cfloop index="intDay" from="1" to="7">
							  <td align="center">
								&nbsp;<b>#Left(DayOfWeekAsString(intDay),2)#</b>&nbsp;
							  </td>
						  </cfloop>
						</tr>
						<cfset ThisDay = "">
						<cfloop index="intWeek" from="1" to="6">
						<tr>
							<cfloop index="intDay" from="1" to="7">
								<td align="center">
									<cfif intWeek is 1 and intDay is Month_StartDay>
										<cfset ThisDay=1>
									</cfif>
									<cfif ThisDay is not "">
										<cfset NewCurrentDate = "#CurrentMonth#/#ThisDay#/#CurrentYear#">
										<a href="javascript:h_raiseEvent('calendar','onSelectDate','#NewCurrentDate#');#Arguments.InstanceName#.getCalendar('#NewCurrentDate#');" 
											class="DateLink"
											<cfif NewCurrentDate is CurrentDate>
												style="background-color:##CCCCCC;"
											</cfif>								
											>#ThisDay#</a>
				
										<cfif ThisDay lt Day(month_enddate)>
											<cfset ThisDay=ThisDay+1>
										<cfelse>
											<cfset ThisDay = "">
										</cfif>
									</cfif>
								</td>
							</cfloop>
						</tr>
						</cfloop>
					</table>
				</div>
			</cfsavecontent>
		
			#tmpHTML#

			<cfcatch type="any">
				<b>Error:</b><br>
				#cfcatch.Message#<br>
				#cfcatch.Detail#
			</cfcatch>
		</cftry>
	</cffunction>
</cfcomponent>