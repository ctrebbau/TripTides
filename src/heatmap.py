import json 
import folium as flm
import folium.plugins as plugins
from datetime import datetime, timedelta

with open('assets/heatdata.json') as f: 
    data = json.load(f)


# DateTime("2017-03-01T00:00:00"):Hour(1):DateTime("2019-01-22T12:00:00")
# create a list of datetime objects from 2017-03-01T00:00:00 to 2019-01-22T12:00:00
# with a step of 1 hour
ts = [datetime(2017, 3, 1, 0, 0, 0) + timedelta(hours=x) for x in range(0, len(data))]

# create a list of strings from the datetime objects
def to_str(t):
    return t.strftime('%Y-%m-%d %H')
# for t in ts:
    # t.strftime('%Y-%m-%d %H')
    
ts_str = list(map(to_str, ts))

m = flm.Map(location=[40.41704559338255, -3.7026244464229516], zoom_start=12, tiles="Stamen Terrain")
hm = plugins.HeatMapWithTime(data, index=ts_str, auto_play=True, max_opacity=0.8)
hm.add_to(m)

m.save("plots/heatmap.html")
