CREATE OR REPLACE FUNCTION ___recursive_grid(x_in integer, y_in integer, z_in integer, z_limit_in integer) RETURNS BOOLEAN
LANGUAGE plv8
AS $_$

function lonDegrees2meters(lon) {
    var x = lon * 20037508.34 / 180;
    return x;
}

function latDegrees2meters(lat) {
    var y = Math.log(Math.tan((90 + lat) * Math.PI / 360)) / (Math.PI / 180);
    y = y * 20037508.34 / 180;
    return y;
}

function tileIndexToBBox(x,y,z){
  "use strict";
  let n = Math.pow(2, z);

  let lonW = lonDegrees2meters((x / n * 360.0) - 180.0);
  let lonE = lonDegrees2meters(((x+1) / n * 360.0) - 180.0);
  let latN = latDegrees2meters((Math.atan(Math.sinh(Math.PI * (1 - 2 * y / n))) * 180)/Math.PI);
  let latS = latDegrees2meters((Math.atan(Math.sinh(Math.PI * (1 - 2 * (y+1) / n))) * 180)/Math.PI);

  return [lonW, latS, lonE, latN];
}

// JavaScript here
function recursiveGrid(x,y,z, zLimit){
  "use strict";

  if(z > zLimit) {
    return true;
  }

   let bBox = tileIndexToBBox(x,y,z);

  // Does bBox contain an landforms?

  let osmLineIntersections = plv8.execute("SELECT gid FROM land_polygons WHERE ST_INTERSECTS(ST_MakeEnvelope(" + bBox.join(',') + ",3857), geom) LIMIT 1;");

  if(osmLineIntersections.length === 0) {
    return false
  }

  plv8.execute("INSERT INTO osm_grid_" + z +"(x,y,geom) VALUES ("+ [x,y].join(',') + ",ST_MakeEnvelope (" + bBox.join(',') + ",3857))");


  if(z+1 > zLimit) {
    return false;
  }
  // Upper Left
  recursiveGrid(2*x, 2*y, z+1, zLimit);

  // Upper Right
  recursiveGrid(2*x+1, 2*y, z+1, zLimit);

  // Lower Left
  recursiveGrid(2*x, 2*y+1, z+1, zLimit);

  // Lower Right
  recursiveGrid(2*x+1, 2*y+1, z+1, zLimit);

}

recursiveGrid(x_in,y_in,z_in, z_limit_in);
return true;

$_$;
