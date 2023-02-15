module HeatData

using CSV
using DataFrames
using Dates
using Statistics
using JSON3

assetspath = joinpath(@__DIR__, "..", "assets")
featspath = joinpath(assetspath, "demographic_features.csv")

df = CSV.read(featspath, DataFrame)

df = select(df, :oDT, :oLat, :oLng)
df = sort(df, :oDT)
df[:, :date] = [ Dates.Date(d) for d in df[:, :oDT] ]
df[:, :hour] = [ Dates.hour(d) for d in df[:, :oDT] ]
df[:, :dt] = [ DateTime.(df.date) .+ Hour(df.hour) for df in eachrow(df) ]
df = select(df, :dt, Not([:oDT, :date, :hour]))

mindate, maxdate = extrema(df.dt)
timerange = mindate:Dates.Hour(1):maxdate

function heatdata(df::DataFrame, timerange::StepRange{DateTime, Hour})
    data = Dict{DateTime, Vector{Tuple{Float64, Float64, Float64}}}()
    
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

heat = heatdata(df, timerange)

tup2vec(tup) = [tup[1], tup[2], tup[3]]
heat = [map(tup2vec, heat[i]) for i ∈ keys(heat)]

JSON3.write(joinpath(assetspath, "heatdata.json"), heat)
end