###otco.jl notebook ###
# v0.12.16

begin
	using Base64
	using JSON
	using DataFrames
	using JSON3
	using JSONTables
	using HTTP
	
	octopusWeb = "https://api.octopus.energy/v1/electricity-meter-points/2000001578751/meters/20L3199388/consumption/"
	apiKey = "sk_live_yovlqmdq08rDBKBJ8jCZRdVe:"
	temp = "Basic " * base64encode(apiKey)
	usr = Dict("Authorization" => temp)
	processDF = DataFrame(consumption=Any[],
						interval_start=Any[],
						interval_end=Any[])	
	
	while !isnothing(octopusWeb)
			
		returnData = String(HTTP.get(octopusWeb; headers=usr).body)
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
		print(consumptionData)
		print(nextString)
		#global octopusWeb = copy(df[1:1,[:next]])
		global octopusWeb = nextString
		append!(processDF, parsedData2)
	end
	tail(DataFrame(processDF))
end

