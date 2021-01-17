###otco.jl ###
# v0.12.16

begin
	using Base64
	using JSON
	using DataFrames
	using JSON3
	using JSONTables
	using HTTP
<<<<<<< Updated upstream
	using CSV
	#
	#
	const usageWeb = "https://api.octopus.energy/v1/electricity-meter-points/2000001578751/meters/20L3199388/consumption/"

	const ratesWeb = "https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-AGILE-18-02-21-H/standard-unit-rates/"

	const apiKey = "sk_live_yovlqmdq08rDBKBJ8jCZRdVe:"

	temp = "Basic " * base64encode(apiKey)
	usr = Dict("Authorization" => temp)
	usageDF = DataFrame(consumption=Any[],
						interval_start=Any[],
						interval_end=Any[])	

	ratesDF = DataFrame(value_exc_vat=Any[],
						value_inc_vat=Any[],
						valid_from=Any[],
						valid_to=Any[])

	function fnWebCall(octopusWeb, usr, processDF)::DataFrame

		print("in function")
		
		println(octopusWeb)
		println(usr)
		print(typeof(usr))
		println(processDF)

		global nextString = octopusWeb
		global localProcessDF = processDF
		global returnData = String("")

		while !isnothing(nextString)

			if isa(usr, String)
				nextString = string(nextString, usr)
				#println("usr string")
				#println(nextString)
				returnData = String(HTTP.get(nextString).body)
			else
				returnData = String(HTTP.get(nextString; headers=usr).body)
			end

			#println(returnData)
			#print(HTTP.get(octopusWeb; headers=usr))
			parsedData = JSON.parse(returnData::AbstractString; dicttype=Dict)
			
			#curl -u "sk_live_yovlqmdq08rDBKBJ8jCZRdVe:" 			    #"https://api.octopus.energy/v1/electricity-meter-#points/2000001578751/meters/20L3199388/consumption/"
			
			# unit rates
			# curl -u "sk_live_yovlqmdq08rDBKBJ8jCZRdVe:" #"https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-#AGILE-18-02-21-H/standard-unit-rates/"

			octopusData = JSON3.read(returnData)
			#print("results")
			parsedData2 = DataFrame(jsontable(octopusData["results"]))
			#parsedData3 = DataFrame(jsontable(consumptionData))
			#nextDF = DataFrame((consumptionData))
			nextString = octopusData["next"]
			#print("next string")
			#print(consumptionData)
			#print(nextString)
			#global octopusWeb = copy(df[1:1,[:next]])
			#global octopusWeb = nextString
			append!(localProcessDF, parsedData2)
		#	octopusWeb = nothing
			#print("in while loop")
			end
		print("after end while")
		#processDF = DataFrame()
		return localProcessDF
		end
	end
=======
	
	consumptionWeb = "https://api.octopus.energy/v1/electricity-meter-points/2000001578751/meters/20L3199388/consumption/"
	ratesWeb = "https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-#AGILE-18-02-21-H/standard-unit-rates/"
	apiKey = "sk_live_yovlqmdq08rDBKBJ8jCZRdVe:"
	temp = "Basic " * base64encode(apiKey)
	usr = Dict("Authorization" => temp)
	consumptionDF = DataFrame(consumption=Any[],
						interval_start=Any[],
						interval_end=Any[])	

	function webCall(webAddress, webHeaders, returnDF)
		
		while !isnothing(webAddress)
			
			returnData = String(HTTP.get(webAddress; headers=webHeaders).body)
		#print(HTTP.get(octopusWeb; headers=usr))
		
		#println(returnData)
		
		#println(typeof(JSON.parse(returnData::AbstractString; dicttype=Dict)))
		#parsedData = JSON.parse(returnData::AbstractString; dicttype=Dict)
		#print(parsedData)
		
		#df = DataFrame(parsedData)
		
		#curl -u "sk_live_yovlqmdq08rDBKBJ8jCZRdVe:" 			    #"https://api.octopus.energy/v1/electricity-meter-#points/2000001578751/meters/20L3199388/consumption/"
		
		# unit rates
		# curl -u "sk_live_yovlqmdq08rDBKBJ8jCZRdVe:" #"https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/E-1R-#AGILE-18-02-21-H/standard-unit-rates/"
		#using JSON3
		#using JSONTables
			consumptionData = JSON3.read(returnData)
			parsedData2 = DataFrame(jsontable(consumptionData["results"]))
		#parsedData3 = DataFrame(jsontable(consumptionData))
		#nextDF = DataFrame((consumptionData))
			nextString = consumptionData["next"]
			#print(consumptionData)
			#print(nextString)
		#global octopusWeb = copy(df[1:1,[:next]])
			global webAddress = nextString
			append!(returnDF, parsedData2)
		end
		#tail(DataFrame(returnDF))
	end	

	usageDF = webCall(consumptionWeb, usr, consumptionDF)

	costsDF = webCall(ratesWeb, usr, ratesDF)
	# tail(DataFrame(usageDF))
end
>>>>>>> Stashed changes

	consumptionDF = fnWebCall(usageWeb, usr, usageDF)

	print("function exit")

	CSV.write("consumption.csv", consumptionDF)

	#print(consumptionDF)

	#periods = "?period_from=2021-01-06T00:00:00Z&period_to=2021-01-07T00:00:00Z"

	costsDF = fnWebCall(ratesWeb, usr, ratesDF)

	#DataFrame.headers(costsDF)
	CSV.write("costs.csv", costsDF)