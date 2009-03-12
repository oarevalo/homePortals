<cfcomponent displayname="simpleAdapter" extends="Home.components.baseModule">

	<cffunction name="init">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			
			cfg.setModuleClassName("simpleAdapter");
			cfg.setView("default", "simpleAdapter");

			// make sure we create a space for the current adapters inputs
			if(not structKeyExists(session,"adaptersData")) session.adaptersData = structNew();
			if(this.controller.getExecMode() eq "local") session.adaptersData[moduleID] = structNew();
		</cfscript>	
	</cffunction>
	
	<cffunction name="setInput" access="public">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var lstOutputs = "";
			
			// clear previous inputs
			session.adaptersData[moduleID] = structNew();
		
			// update inputs
			for(a in arguments) {
				if(not ListFindNoCase("METHOD,MODULEID,FIELDNAMES,_",a)) {
					session.adaptersData[moduleID][a] = arguments[a];
				}
			}
		
			// get outputs
			stOutputs = evaluateOutput();
			for(o in stOutputs) {
				lstOutputs = listAppend(lstOutputs,"#o#:#stOutputs[o]#");
			}
		
			this.controller.setEventToRaise("onInputReceived",lstOutputs);
			this.controller.setMessage("Adapter input received");
			this.controller.setScript("#moduleID#.getView();");
		</cfscript>
	</cffunction>
	
	<cffunction name="setOutput" access="public">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var lstArgs = "";
			var a = "";
		
			for(a in arguments) {
				if(listLen(a,"_") gt 1 and listFirst(a,"_") eq "outputName") {
					argName = listRest(a,"_");
					if(arguments[a] neq "") {
						if(listlen(arguments[a]," ") gt 1) throw("Output argument names cannot contain spaces");
						cfg.setPageSetting("outputs_#argName#", arguments["outputExpr_#argName#"]);
						lstArgs = listAppend(lstArgs,argName);
					} else {
						cfg.deletePageSetting("outputs_#argName#");
					}
				}
			}

			if(arguments.outputName neq "") {
				cfg.setPageSetting("outputs_" & arguments.outputName, arguments.outputExpr);
				lstArgs = listAppend(lstArgs, arguments.outputName);
			}

			this.controller.savePageSettings();

			this.controller.setMessage("Adapter output saved");
			this.controller.setScript("#moduleID#.getPopupView('simpleAdapterConfig');");
		</cfscript>
	</cffunction>

	<cffunction name="fireOutput" access="public">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var stOutputs = evaluateOutput();
			var o = "";
			var lstOutputs = "";
			
			for(o in stOutputs) {
				lstOutputs = listAppend(lstOutputs,"#o#:#stOutputs[o]#");
			}
		
			this.controller.setEventToRaise("onOutputFired",lstOutputs);
			this.controller.setMessage("Output has been fired");
			this.controller.setScript("#moduleID#.getView();");
		</cfscript>
	</cffunction>
	
	<cffunction name="getInputs" access="public" returntype="struct">
		<cfscript>
			var moduleID = this.controller.getModuleID();
			return session.adaptersData[moduleID];	
		</cfscript>
	</cffunction>

	<cffunction name="getOutputs" access="public" returntype="struct">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var stOutputs = structNew();
			var s = "";
			var	stPageSettings = cfg.getPageSettings();
			var argName = "";
			
			for(s in stPageSettings) {
				if(left(s,8) eq "outputs_" and listLen(s,"_") gt 1) {
					argName = listRest(s,"_");
					stOutputs[argName] = stPageSettings[s];
				}
			}	

			return stOutputs;	
		</cfscript>
	</cffunction>


	<cffunction name="evaluateOutput" access="private" returntype="struct">
		<cfscript>
			var cfg = this.controller.getModuleConfigBean();
			var moduleID = this.controller.getModuleID();
			var stInputs = getInputs();
			var stOutputs = getOutputs();
			var s = "";
			var lstInputs = "";
			var numOutputs = 0;
		
			for(o in stOutputs) {
				expr = stOutputs[o];
				if(structKeyExists(stInputs,expr))
					val = "'#jsstringFormat(stInputs[expr])#'";
				else 
					val = expr;
				stOutputs[o] = val;
			}
		</cfscript>
		<cfreturn stOutputs>
	</cffunction>

	<cffunction name="dump" access="private">
		<cfargument name="data" type="any" required="yes">
		<cfdump var="#arguments.data#">
	</cffunction>	
	<cffunction name="abort" access="private">
		<cfabort>
	</cffunction>	

</cfcomponent>