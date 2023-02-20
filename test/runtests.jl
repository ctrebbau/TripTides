using TripTides
using Test


@testset "TripTides.jl" begin
    # Write your tests here.
end


include(joinpath(@__DIR__, "..", "src", "utils", "DataSanitizer.jl"))
using .DataSanitizer: df

@testset "DataSanitizer.jl" begin
    @testset "df" begin
        isa(df, DataFrame)
    end
end


using .HeatData
@testset "HeatData.jl" begin
    @testset "heatdata" begin
        timerange = DateTime(2020, 1, 1):Hour(1):DateTime(2020, 1, 2)
        @testset "empty df" begin
            df = DataFrame()
            @test_throws ArgumentError heatdata(df, timerange)
        end
        @testset "missing columns" begin
            df = DataFrame(oLat = [1, 2, 3], oLng = [4, 5, 6])
            @test_throws ArgumentError heatdata(df, timerange)
        end
    end
end