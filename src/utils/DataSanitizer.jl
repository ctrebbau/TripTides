module DataSanitizer

using CSV
using DataFrames
using Dates
using Statistics
using JSON3

assetspath = joinpath(@__DIR__, "..", "..", "assets")
featspath = joinpath(assetspath, "demographic_features.csv")

df = df[df[!, :dist] .< quantile(df[!, :dist], 0.9), :]
df = df[df[!, :dist] .> quantile(df[!, :dist], 0.1), :]

df = CSV.read(featspath, DataFrame)
df = select(df, :oDT, :oLat, :oLng)
df = sort(df, :oDT)
df[:, :date] = [ Dates.Date(d) for d in df[:, :oDT] ]
df[:, :hour] = [ Dates.hour(d) for d in df[:, :oDT] ]
df[:, :dt] = [ DateTime.(df.date) .+ Hour(df.hour) for df in eachrow(df) ]
df = select(df, :dt, Not([:oDT, :date, :hour]))

end