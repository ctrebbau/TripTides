module HeatData

using Dates
using DataFrames
include(joinpath(@__DIR__, "DataSanitizer.jl"))
using .DataSanitizer: df

export heatdata

TIMEAGG = Dates.Hour(1)

mindate, maxdate = extrema(df.dt)
timerange = mindate:TIMEAGG:maxdate


@doc raw"""
Given a DataFrame `df` that contains information about events with latitude, longitude,
and time, and a time range `timerange`, generates a dictionary that maps each time within
the `timerange` to a vector of tuples representing the latitude, longitude, and weight of
events that occurred during that time. 
If no events occurred at a particular time, a single tuple with coordinates (40.3, -3.7) 
and weight 0 is added to the output for that time. 

# Parameters
- `df::DataFrame`: A DataFrame that contains information about events with latitude, longitude, and time. 
- `timerange::StepRange{DateTime, typeof(TIMEAGG)}`: A time range that specifies the intervals for which to generate heat map data. 

# Returns
- A dictionary that maps each time within the `timerange` to a vector of tuples representing the latitude,
longitude, and weight of events that occurred during that time. 
"""
function heatdata(df::DataFrame, timerange::StepRange{DateTime, typeof(TIMEAGG)})
     data = Dict{DateTime, Vector{Tuple{Float64, Float64, Float64}}}()
    
    if isempty(df)
        throw(ArgumentError("df must not be empty"))
    end

    if !(:oLat ∈ names(df)) || !(:oLng ∈ names(df)) || !(:dt ∈ names(df))
        throw(ArgumentError("df must contain columns :oLat, :oLng, and :dt"))
    end

    for t ∈ timerange
        dfₜ = df[df[:, :dt] .== t, :]
        if isempty(dfₜ)
            data[t] = [(40.3, -3.7, 0)]
            continue
        end
        # weight = 1/size(dfₜ, 1)
        data[t] = zip(dfₜ[:, :oLat], dfₜ[:, :oLng], [1 for _ in 1:size(dfₜ, 1)]) |> collect
    end
    
    return data
end

# heat = heatdata(df, timerange)

tup2vec(tup) = [ tup[1], tup[2], tup[3] ]
# heat = [ map(tup2vec, heat[i]) for i ∈ keys(heat) ]
# JSON3.write(joinpath(assetspath, "heatdata.json"), heat)

end