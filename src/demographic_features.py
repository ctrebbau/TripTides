import osgeo.ogr as ogr
import geopandas as gpd
import pandas as pd
from shapely.geometry import Point
from pyproj import CRS
from pyproj import Proj

crs_proj = CRS("epsg:4326")
barrio_gdf = gpd.read_file('/Users/ct/GeoDownloads/InstitutoEstadistica/20220101_estructura_demografica_barrio.shp')
distrito_gdf = gpd.read_file('/Users/ct/GeoDownloads/InstitutoEstadistica/20220101_estructura_demografica_distrito.shp')
seccion_gdf = gpd.read_file('/Users/ct/GeoDownloads/InstitutoEstadistica/20220101_estructura_demografica_seccion.shp')
trips_df = pd.read_csv("assets/cabify_trips_w_nodes.csv")

# include idx to merge later
trips_df.index.name = "idx"

orig_df = trips_df.drop(columns=["dDT", "dLat", "dLng", "dNode"])
dest_df = trips_df.drop(columns=["oDT", "oLat", "oLng", "oNode"])

barrio_gdf.to_crs(crs_proj, inplace=True)

# Turn dfs into GeoDataFrame i.e. add geometry column
orig_gdf = gpd.GeoDataFrame(orig_df, geometry=gpd.points_from_xy(orig_df.oLng, orig_df.oLat), crs=crs_proj)
dest_gdf = gpd.GeoDataFrame(dest_df, geometry=gpd.points_from_xy(dest_df.dLng, dest_df.dLat), crs=crs_proj)

# Join with barrio
orig_gdf = gpd.sjoin(orig_gdf, barrio_gdf, how="inner", op="within") # 952227 points started outside of any barrio
dest_gdf = gpd.sjoin(dest_gdf, barrio_gdf, how="inner", op="within") # 991808 points ended outside of any barrio

# Merge orig_gdf and dest_gdf
od_gdf = orig_gdf.merge(dest_gdf, how="inner", on="idx", suffixes=["Orig", "Dest"])

# Clean up
od_gdf.drop(columns=["index_rightOrig",
                     "OBJECTIDOrig",
                     "COD_DISOrig", "COD_BAROrig",
                     "Shape_STArOrig",
                     "Shape_STLeOrig", 
                     "index_rightDest",
                     "OBJECTIDDest",
                     "COD_DISDest",
                     "COD_BARDest",
                     "Shape_STArDest", 
                     "Shape_STLeDest"], inplace=True)

new_col_names = {"geometryOrig" : "oGeom",
                "NOMBREOrig" : "oBar",
                "NOMBREDest" : "dBar",
                "oNodeIdOrig" : "oNodeId",
                "dNodeIdOrig" : "dNodeId",
                "DensidadOrig": "oDens", 
                "Edad_PromeOrig":"oMnAge",
                "Edad_MediaOrig" : "oMdAge", 
                "ProporcionOrig":"oYthPrp",
                "Proporci_1Orig" : "oOldPrp", 
                "Proporci_2Orig" : "oOld+Prp",
                "Indice_envOrig" : "oOldIndx", 
                "Indice_juvOrig" : "oYthIndx",
                "Indice_depOrig" : "oDpndnIndx", 
                "Indice_estOrig" : "oActvIndx",
                "Indice_reeOrig" : "oRplcIndx", 
                "Razon_progOrig" : "oProgRte",
                "Proporci_3Orig" : "oFrgnProp", 
                "Proporci_4Orig" : "oNotSpnrd",
                "Prop_inmigOrig" : "oImmgrnt", 
                "geometryDest" : "dGeom", 
                "DensidadDest": "dDens", 
                "Edad_PromeDest": "dMnAge", 
                "Edad_MediaDest" : "dMdAge", 
                "ProporcionDest":"dYthPrp",
                "Proporci_1Dest" : "dOldPrp", 
                "Proporci_2Dest" : "dOld+Prp",
                "Indice_envDest" : "dOldIndx", 
                "Indice_juvDest" : "dYthIndx",
                "Indice_depDest" : "dDpndnIndx", 
                "Indice_estDest" : "dActvIndx",
                "Indice_reeDest" : "dRplcIndx", 
                "Razon_progDest" : "dProgRte",
                "Proporci_3Dest" : "dFrgnProp", 
                "Proporci_4Dest" : "dNotSpnrd",
                "Prop_inmigDest" : "dImmgrnt"}

od_gdf.rename(columns=new_col_names, inplace=True)
od_gdf.to_csv("assets/demographic_features.csv", index=False)