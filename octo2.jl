#=
octo2:
- Julia version: 1.4.1
- Author: royja
- Date: 2021-09-12
=#
using Base64
using Dates
using DataFrames
using CSV
using Query

#consumptionDF = CSV.File("consumption.csv"; dateformat="yyyy-mm-ddTHH:MM:SS", DataFrame)
#costsDF = CSV.File("costs.csv"; dateformat="yyyy-mm-ddThh:MM:ss") # DataFrame)
consumptionDF = CSV.read("consumption.csv",dateformat="yyyy-mm-ddTHH:MM:SS", DataFrame)
costsDF = CSV.read("costs.csv",dateformat="yyyy-mm-ddTHH:MM:SS", DataFrame)

accountDF = leftjoin(consumptionDF, costsDF, on = :interval_start => :valid_from)

accountDF = filter(:value_inc_vat => value_inc_vat -> !(ismissing(value_inc_vat) || isnothing(value_inc_vat) || isnan(value_inc_vat)), accountDF)



chargesDF = accountDF |> @mutate(charge = _.consumption * _.value_inc_vat,
                                date = popfirst!(split(_.interval_start, "T")),
                                start_time = pop!(split(_.interval_start, "T" ))) |> DataFrame

#
# TODO convert all datetime fields to 'Z' or GMT as the octopus data includes the BST time change for one set but not rthe other
date_format = DateFormat("y-m-d")
using DataFramesMeta
@with(chargesDF, Date(:date,date_format))
#df[:Date] = Date.(df[:Date],date_format)
##[:Ddate] = Date.(df[:Ddate],date_format)

grouped_chargesDF = groupby(chargesDF, :date) # |> DataFrame

#daily_chargeDF = combine(grouped_chargesDF, sum, :date => sum => sum)
first(grouped_chargesDF)
daily_chargeDF = combine(grouped_chargesDF, :charge => sum )
#daily_chargeDF = combine(grouped_chargesDF, date, :charge => sum => :sum)

first(grouped_chargeDF,5)
first(daily_chargeDF,5)