

///// Code in Google Earth Engine Code Editor///


// stack image band from image collection to a single image with multi-bands
// (1) select the roi, for this example is Hangzhou;
// (2) set the start and end of the study period;
// (3) use "cf_cvg" and "avg_rad" seperately to output cloud free observation and averaged monthly radiance data of each roi;

///// *****************////


var roi=ee.FeatureCollection(Hangzhou);
// set the start and end of the study period
var VIIRS=ee.ImageCollection('NOAA/VIIRS/DNB/MONTHLY_V1/VCMCFG').filterBounds(roi).filterDate('2012-04-01','2019-04-01');  

Map.addLayer(VIIRS.first(),{min:0,max:50})
print(VIIRS);
print('Number of image in Collection:',VIIRS.size());

// export cf_cvg: number of cloud free image per month
var renameVIIRS=function(scene){
  var NTL=ee.Image(scene.select(['cf_cvg'])).float(); // be careful about the data type rad float;cvg_unsign 16
  var NTL_idx=ee.String('cvg_').cat(ee.String(scene.get('system:index')));
  return NTL.rename(NTL_idx);
};

var VIIRS_Month_Collection=VIIRS.map(renameVIIRS);

var stackCollection=function(collection){
  var first=ee.Image(collection.first()).select([]);
  var appendBands = function(image, previous) {
    return ee.Image(previous).addBands(image);
  };
  return ee.Image(collection.iterate(appendBands, first));
};
var stacked = stackCollection(VIIRS_Month_Collection);
print('stacked image', stacked);

var stacked = stacked.reproject('EPSG:4326', null, 500);
print(stacked);

Export.image.toDrive({
  image: stacked.clip(roi),
  description: 'cf_cvg',
  scale: 500,
  region: roi
});


// export avg_rad: averaged monthly radiance

var renameVIIRS=function(scene){
  var NTL=ee.Image(scene.select(['avg_rad'])).float(); // be careful about the data type rad float;cvg_unsign 16
  var NTL_idx=ee.String('avg_').cat(ee.String(scene.get('system:index')));
  return NTL.rename(NTL_idx);
};

var VIIRS_Month_Collection=VIIRS.map(renameVIIRS);

var stackCollection=function(collection){
  var first=ee.Image(collection.first()).select([]);
  var appendBands = function(image, previous) {
    return ee.Image(previous).addBands(image);
  };
  return ee.Image(collection.iterate(appendBands, first));
};
var stacked = stackCollection(VIIRS_Month_Collection);
print('stacked image', stacked);
var stacked = stacked.reproject('EPSG:4326', null, 500);
print(stacked);

Export.image.toDrive({
  image: stacked.clip(roi),
  description: 'avg_rad',
  scale: 500,
  region: roi
});
          
