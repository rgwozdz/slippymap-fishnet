This set of commands should be run once at the outset after postgres instance setup
```sql
CREATE DATABASE map_analysis;
CREATE EXTENSION POSTGIS;
CREATE EXTENSION PLV8;
```

This loads in the land polygons

```bash
shp2pgsql -s 3857 -g geom  -I /home/postgres/src/land-polygons-complete-3857/land_polygons.shp land_polygons | psql -U postgres -d map_analysis
```

This loads the OSM data (currently subset on Washington state);
```bash
osm2pgsql -c -d map_analysis -P 5432 --number-processes 4 --slim -C 4000 --flat-nodes /usr/osm-cache/flat.nodes /home/postgres/src/washington-latest.osm.pbf
```
Or whole planet:  

```bash
osm2pgsql -c -d map_analysis -P 5432 --number-processes 4 --slim -C 4000 --flat-nodes /usr/osm-cache/flat.nodes /home/postgres/src/washington-latest.osm.pbf
```