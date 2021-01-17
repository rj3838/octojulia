### octo2.jl ###

using Base64
using Dates
using DataFrames
using CSV

#consumptionDF = CSV.File("consumption.csv"; dateformat="yyyy-mm-ddTHH:MM:SS", DataFrame)
#costsDF = CSV.File("costs.csv"; dateformat="yyyy-mm-ddThh:MM:ss") # DataFrame)
consumptionDF = CSV.read("consumption.csv",dateformat="yyyy-mm-ddTHH:MM:SS", DataFrame)
costsDF = CSV.read("costs.csv",dateformat="yyyy-mm-ddTHH:MM:SS", DataFrame)

#print(typeof(costsDF))

consumptionDF
#println(String.(names(costsDF)))

accountDF = leftjoin(consumptionDF, costsDF, on = :interval_start => :valid_from)

#colwise((x)->convert.(Float64,x), df)
#getindex.(colwise((interval_start)->convert.(DateTime, interval_start), accountDF), 1)

accountDF = filter(:value_inc_vat => value_inc_vat -> !(ismissing(value_inc_vat) || isnothing(value_inc_vat) || isnan(value_inc_vat)), accountDF)

#println(String.(names(accountDF)))
accountDF[!,:value_exc_vat] = convert.(Float64, accountDF[!,:value_exc_vat])
accountDF[!,:value_inc_vat] = convert.(Float64, accountDF[!,:value_inc_vat])

# below does not work !
accountDF[!,:interval_start] = accountDF[!,:interval_start[1:18]]
accountDF[!,:interval_start] = Dates.parse(DateTime, accountDF[!,:interval_start],"yyyy-mm-ddTHH:MM:SSZ")

accountDF

#Dates.parse(DateTime, accountDF[!,:interval_start], dateformat"yyyy-mm-ddTHH:MM:SS")