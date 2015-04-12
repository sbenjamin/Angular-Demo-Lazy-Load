<!--- Steven Benjamin : April 11, 2015 --->
<!--- Using Data Schema: Sakila ref: http://dev.mysql.com/doc/sakila/en/sakila-installation.html --->
<!--- www.stevenbenjamin.com --->


<cfcomponent>
	<cffunction name="ping" output="no" returntype="any" returnFormat="json" access="remote">
		<cfset var results = structNew() />
		<cfset results["ping"] = true>
		<cfreturn results />
	</cffunction>
	
	
	<cffunction name="getMovies" access="remote" returnType="any" returnFormat="plain" output="false">
		<cfargument name="callback" type="string" required="false">
		<cfargument name="page" default="0">
		<cfargument name="returnSet" default="50">
		<cfargument name="searchStr" default="">
		<cfargument name="token" default="">
		
		<!--- require a static key to access the service --->
		<cfif arguments.token NEQ "dhd7dteg56533d">
			<cfset var error = "Service Not Available" />
			<cfreturn error/>
		</cfif>
		
		<cfset var data = _getMovies(page=arguments.page,returnSet=arguments.returnSet,searchStr=arguments.searchStr)>
		
		<!--- serialize --->
		<cfset data = serializeJSON(data)>
		
		<!--- wrap --->
		<cfif structKeyExists(arguments, "callback")>
			<cfset data = arguments.callback & "(" & data & ")">
		<cfelse>
			<cfset data="{status:'noCallBack'}">	
		</cfif>
		
		<cfreturn data>
	</cffunction>
	
	<cffunction name="_getMovies" output="no" returntype="any" returnFormat="plain" access="private">
		<cfargument name="page" default="0">
		<cfargument name="returnSet" default="50">
		<cfargument name="searchStr" default="">
		
		<!--- adjust for page start count --->
		<!--- pagination :1-based and MYSQL:0-based --->
		<cfset arguments.page = arguments.page-1 />
		<cfif arguments.page LT 0>
			<cfset arguments.page = 0 />
		</cfif>
		
		<cfset var startCount = (arguments.page * arguments.returnSet)/>
		
		<cfset var results = structNew() />
		<cfset results["startRecord"] = startCount />
		
		<cfquery name="qry_getMovies" datasource="Sakila">
			SELECT title,film_id,description,poster
			FROM film
			<cfif LEN(arguments.searchStr)>
				WHERE title LIKE '#arguments.searchStr#%'
			</cfif>
			LIMIT #startCount#,#arguments.returnSet#
		</cfquery>
		
		<!--- There is no cache manager for this demo --->
		<!--- ordinarily the cache would be cleared when the movie count is changed. --->
		<cfquery name="qry_getMoviesCnt" datasource="Sakila">
			SELECT COUNT(film_id) as totalMovies
			FROM film
			<cfif LEN(arguments.searchStr)>
				WHERE title LIKE '#arguments.searchStr#%'
			</cfif>
		</cfquery>
		
		<cfset results["resultSet"] = qry_getMoviesCnt.totalMovies />
		<cfset results["dataSet"] = qry2json(querySet=qry_getMovies,lcase=true) />
		
		<cfreturn results />
	</cffunction>
	
	<!--- Convert Lucee Column-based json to Row-based json --->
    <cffunction name="qry2json" access="private" returntype="any" output="Yes">
        <cfargument name="querySet" type="query" required="yes">
        <cfargument name="convertLineBreaksForJSON" default="false" required="no">
		<cfargument name="escSpecChar" default="false" required="no">
        <cfargument name="startRow" required="no" default="1">
        <cfargument name="endRow" required="yes" default="#arguments.querySet.recordCount#">
		<cfargument name="lcase" type="boolean" default="false">
		<cfargument name="additionalAttributes" type="struct">
        <cfargument name="addArrayIdx" default="false">
            
        
        <cfset returnedRecordCount = (arguments.endRow-arguments.startRow)+1>
        <cfset  result = structNew()>
		
		<!--- if the querySet is not empty --->
        <cfif querySet.recordCount GT 0>
		<!--- Create an "ROWS" Array to hold the row objects --->
		<cfset ROWS = arrayNew(1)>
				<!---loop through each row in the record set--->
                <cfloop query="querySet" startrow="#arguments.startRow#" endrow="#arguments.endRow#">
					<!--- create an object for each row --->
					<cfset jsonObjItem = structNew()>
					<!--- loop for each column in the datasset --->
                    <cfloop index="columnName" list="#querySet.columnList#" delimiters=",">
						<cfset var thisValueItem = evaluate("querySet."&columnName)>
						<cfif arguments.escSpecChar>
							<cfset thisValueItem = cleanStringForJSON(thisValueItem)>
						</cfif>
						
						<!--- Handle Line Breaks in the value item --->
						<cfif convertLineBreaksForJSON EQ false>
			                <cfset thisValueItemLB = replaceNoCase(thisValueItem,"#chr(13)##chr(10)#","<br>","all")>
			                <cfset thisValueItemLB = replaceNoCase(thisValueItemLB,chr(13),"<br>","all")>
			                <cfset thisValueItemLB = replaceNoCase(thisValueItemLB,chr(10),"<br>","all")>        
			            <cfelse>
			                <cfset thisValueItemLB = replaceNoCase(thisValueItem,"#chr(13)##chr(10)#","\n\r","all")>
			                <cfset thisValueItemLB = replaceNoCase(thisValueItemLB,chr(13),"\n","all")>
			                <cfset thisValueItemLB = replaceNoCase(thisValueItemLB,chr(10),"\r","all")>
			            </cfif>
						
						<!---populate the object with a name:value pair for each column --->
						<cfif arguments.lcase EQ true>
							<cfset jsonObjItem["#lcase(columnName)#"] = thisValueItemLB>
						<cfelse>
							<cfset jsonObjItem["#columnName#"] = thisValueItemLB>
						</cfif>
                            
                        <cfif arguments.addArrayIdx EQ true>
                            <cfset jsonObjItem["arrayIdx"] = querySet.currentRow-1>
                        </cfif>    
						
						<!--- add the object to the ROWS array --->
						<cfset ROWS[querySet.currentRow] = jsonObjItem>
                    </cfloop>  
            	</cfloop>
				
			<cfset result.ROWS = ROWS>
			<cfset result.DATASET = INT(variables.returnedRecordCount)>
			<cfset result.RECORDSET = querySet.recordCount> 
			<cfset result["success"] = true>
			<!--- loop over the additionalAttributes and add them to the JSON packet. --->
			<cfif isDefined("additionalAttributes")>
				<cfloop collection="#additionalAttributes#" item="attrItem">
					<cfset result["#attrItem#"] = Evaluate("additionalAttributes.#attrItem#")>
				</cfloop>
			</cfif>
			
			
        <cfelse>
			<cfset result.ROWS = arrayNew(1)>
			<cfset result.DATASET = 0> 
			<cfset result.RECORDSET = querySet.recordCount> 
			<cfset result["success"] = false>
			<cfset result["msg"] = "No records found">
        </cfif>
            
       <cfreturn result>
    </cffunction>
</cfcomponent>