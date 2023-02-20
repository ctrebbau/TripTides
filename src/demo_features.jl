import ArchGDAL as AG
using CSV, DataFrames
using GeoDataFrames; const GDF = GeoDataFrames
import GeoFormatTypes as GFT

# Load the shapefiles into GeoDataFrames
barrio = AG.read("/Users/ct/GeoDownloads/InstitutoEstadistica/20220101_estructura_demografica_barrio.shp")
distrito = AG.read("/Users/ct/GeoDownloads/InstitutoEstadistica/20220101_estructura_demografica_distrito.shp")
seccion = AG.read("/Users/ct/GeoDownloads/InstitutoEstadistica/20220101_estructura_demografica_seccion.shp")

# extract the CRS from the shapefile (CRS is the same for all shapefiles)
sourceproj = read("/Users/ct/GeoDownloads/InstitutoEstadistica/20220101_estructura_demografica_barrio.prj", String) |> chomp |> String
sourceproj = GFT.ESRIWellKnownText(sourceproj)
# sourceproj = AG.importWKT(shpproj) |> AG.toPROJ4 |> AG.importPROJ4

# Read the CSV file into a DataFrame
trips = DataFrame(CSV.File("assets/cabify_trips_w_nodes.csv"))

# include idx as column for merging
trips[:, :idx] = 1:size(trips, 1)

# create origin and destination DataFrames
orig = select(trips, Not([:dDT, :dLat, :dLng, :dNode]))
dest = select(trips, Not([:oDT, :oLat, :oLng, :oNode]))

# add geometry column
orig[:, :geometry] = [AG.createpoint(lat, lng) for (lat, lng) in zip(orig.oLat, orig.oLng)]
dest[:, :geometry] = [AG.createpoint(lat, lng) for (lat, lng) in zip(dest.dLat, dest.dLng)]

targetproj = GFT.EPSG(4326)
barrio = AG.getlayer(barrio, 0) |> DataFrame ; rename!(barrio, Symbol("") => :geometry)
barrio[!, :geometry] = AG.reproject(barrio.geometry, sourceproj, targetproj)

# Perform spatial join of orig with barrio
using FlexiJoins
using ArchGDAL: within
#innerjoin(orig.geometry, barrio.geometry, by_pred(identity, within, identity), mode=FlexiJoins.Mode.NestedLoop(), loop_over_side=1)
#X = crossjoin(barrio, orig, makeunique=true)
#subset!(X, [:geometry, :geometry_1] => (a, b) -> within.(b, a))



# create an email regex and comment each line
source = AG.importEPSG(2927)
target = AG.importEPSG(4326)
import GeoFormatTypes as GFT
df.geom = reproject(df.geom, GFT.EPSG(4326), GFT.EPSG(28992))
reproject(barrio.geometry, GFT.CRS(source), GFT.CRS(target))