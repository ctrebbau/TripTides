using CSV, DataFrames
using Dates
using LightOSM
using OpenStreetMapX
import Base.Threads: @sync, @spawn

@__DIR__
const ctr = GeoLocation(40.416775, -3.703790) # Sol
const radius = 50 # km

mkdir(joinpath(@__DIR__, "osm_maps"))
mapspath = joinpath(@__DIR__, "osm_maps")
const dist_datafile = joinpath(@__DIR__, "osm_maps", "dist_sol_$(radius)km.osm")
const time_datafile = joinpath(@__DIR__, "osm_maps", "time_sol_$(radius)km.osm")

# g_dist = LightOSM.graph_from_download(
#                                     :point,
#                                     point=ctr,
#                                     radius=radius,
#                                     weight_type=:distance,
#                                     download_format=:osm,
#                                     save_to_file_location=dist_datafile
#                                     )

# g_time = LightOSM.graph_from_download(
#                                     :point,
#                                     point=ctr,
#                                     radius=radius,
#                                     weight_type=:time,
#                                     download_format=:osm,
#                                     save_to_file_location=time_datafile
#                                     )

const g_dist = LightOSM.graph_from_file(
                            dist_datafile, 
                            weight_type=:distance, 
                            precompute_dijkstra_states=false, 
                            largest_connected_component=true,
                        )

g_time = LightOSM.graph_from_file(
                            time_datafile, 
                            weight_type=:time, 
                            precompute_dijkstra_states=false, 
                            largest_connected_component=true
                            )

function get_distance(g::LightOSM.Graph, from::GeoLocation, to::GeoLocation)
    from_node = LightOSM.nearest_node(g, from)
    to_node = LightOSM.nearest_node(g, to)
    return LightOSM.dijkstra(g, from_node, to_node)
end

demofeats = split("oDT,oLat,oLng,oNode,oGeom,oBar,oDens,oMnAge,oMdAge,oYthPrp,oOldPrp,oOld+Prp,oOldIndx,oYthIndx,oDpndnIndx,oActvIndx,oRplcIndx,oProgRte,oFrgnProp,oNotSpnrd,oImmgrnt,dDT,dLat,dLng,dNode,dGeom,dBar,dDens,dMnAge,dMdAge,dYthPrp,dOldPrp,dOld+Prp,dOldIndx,dYthIndx,dDpndnIndx,dActvIndx,dRplcIndx,dProgRte,dFrgnProp,dNotSpnrd,dImmgrnt", ",")
df = CSV.read(joinpath(@__DIR__, "..", "..", "assets", "demographic_features.csv"), DataFrame)

function route_distance(g::OSMGraph, o_d_nodes::Vector{Tuple{Int64, Int64}})
    routes = Dict{Tuple{Int64, Int64}, Vector{Any}}()
    distances = Dict{Tuple{Int64, Int64}, Float64}()
        @sync for (o, d) in o_d_nodes
            @spawn begin
                # !haskey(distances, (o.id, d.id)) ?  route = shortest_path(g, o, d) : continue
                route = shortest_path(g, o, d)
                !isnothing(route) ? routes[(o.id, d.id)] = route : routes[(o.id, d.id)] = []
                !isnothing(route) ? distances[(o.id, d.id)] = cumsum(weights_from_path(g, route))[end] : distances[(o.id, d.id)] = Inf    
            end
        end
    return distances
end

LightOSM.nearest_node(g_dist, ptsOrig)[1]

oNodes = df[:, :oNode]
dNodes = df[:, :dNode]
nodes = collect(zip(oNodes, dNodes))[1:100]
typeof(nodes)
route_distances = route_distance(g_dist, nodes)

