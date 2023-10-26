//===========================================================================================
//                               Masterthesis LT
//             Title:  Analyzing the Strengths and Limitations of Satellite- and 
// Ground-Based Data for City-Scale Greenhouse Gas Emission Monitoring in Montreal, Canada
//                            
//               Nightlights before and after Lockdown in Montreal, Canada
//
//                        To toggle between different scales, 
//           use ARM (ARM), ARM_box (ARM box) or MTL_REG (regional) as a variable
//
//               ! The ARM region is manually imported as a shapefile -
//                    it is therefore missing in this code if executed ! 
//              
//===========================================================================================

// Define regions
var ARM_box = ee.Geometry.Polygon(
    [[[-73.9966, 45.3854],
      [-73.4739, 45.3854],
      [-73.4739, 45.7076],
      [-73.9966, 45.7076]]]);
var MTL_REG = ee.Geometry.Polygon(
    [[[-76, 44],
      [-71, 44],
      [-71, 47],
      [-76, 47]]]);
      
//define begin and end and area of interest for export
var early = '2012-04-01';
var late = '2023-04-01';
var early20 = '2020-04-01';

//////////////////////////////////////
// DEFINING COLLECTIONS (TIMEFRAMES) /
//////////////////////////////////////

//collection 1. long timeseries 2012-2023.
var Collection1 = ee.ImageCollection(NTL)
             .select('avg_rad')
             .filterDate(early, late);
             
//collection 2. covid times. 2020-2023
var Collection2 = ee.ImageCollection(NTL)
             .select('avg_rad')
             .filterDate(early20, late);

//calculating spatial statistics for all 3 scales 2012-2023

//MTL_ARM
var Collection1_ARM = Collection1.filterBounds(ARM);
var CollMEAN1_ARM = Collection1_ARM.median();
//MTL_ARM_box
var Collection1_ARM_box = Collection1.filterBounds(ARM_box);
var CollMEAN1_ARM_box = Collection1_ARM_box.median();
//MTL_REG
var Collection1_MTL_REG = Collection1.filterBounds(MTL_REG);
var CollMEAN1_MTL_REG = Collection1_MTL_REG.median();

//calculating spatial statistics for all 3 scales 2020-2023

//MTL_ARM
var Collection2_ARM = Collection2.filterBounds(ARM);
var CollMEAN2_ARM = Collection2_ARM.median();
//MTL_ARM_box
var Collection2_ARM_box = Collection2.filterBounds(ARM_box);
var CollMEAN2_ARM_box = Collection2_ARM_box.median();
//MTL_REG
var Collection2_MTL_REG = Collection2.filterBounds(MTL_REG);
var CollMEAN2_MTL_REG = Collection2_MTL_REG.median();

///////////////////
// VISUALIZATION //
///////////////////

//define style parameters
var style = {
    bands: ['avg_rad'],
    max: 175.71,
    palette: ['black', 'white', 'orange', 'yellow', 'red']
  };

///////////////////  
//Create a legend//
///////////////////

var vis = {min: '1,145', max: '175,71', palette: 'black, white, orange, yellow, red'};

// Creates a color bar thumbnail image for use in legend from the given color
// palette.
function makeColorBarParams(palette) {
  return {
    bbox: [0, 0, 1, 0.1],
    dimensions: '50x5',
    format: 'png',
    min: 0,
    max: 1,
    palette: palette,
  };
}

// Create the color bar for the legend.
var colorBar = ui.Thumbnail({
  image: ee.Image.pixelLonLat().select(0),
  params: makeColorBarParams(vis.palette),
  style: {stretch: 'horizontal', margin: '0px 8px', maxHeight: '24px'},
});

// Create a panel with three numbers for the legend.
var legendLabels = ui.Panel({
  widgets: [
    ui.Label(vis.min, {margin: '4px 8px'}),
    ui.Label(
        (vis.medium),
        {margin: '4px 8px', textAlign: 'center', stretch: 'horizontal'}),
    ui.Label(vis.max, {margin: '4px 8px'})
  ],
  layout: ui.Panel.Layout.flow('horizontal')
});

var legendTitle = ui.Label({
  value: 'Nightlights (nW/cm²/sr)',
  style: {fontWeight: 'bold'}
});

// Add the legendPanel to the map.
var legendPanel = ui.Panel([legendTitle, colorBar, legendLabels]);
Map.add(legendPanel);

////////////////////////////////////////
//////////DISPLAYING DATA //////////////
////////////////////////////////////////

Map.addLayer(CollMEAN1_ARM.clip(ARM), style, 'ARM Nightlights_2012-2023'); 
Map.addLayer(CollMEAN1_ARM_box.clip(ARM_box), style, 'ARM Box Nightlights_2012-2023');
Map.addLayer(CollMEAN1_MTL_REG.clip(MTL_REG), style, 'MTL Region Nightlights_Timeseries_2012-2023');
Map.addLayer(CollMEAN2_ARM.clip(ARM), style, 'ARM Nightlights_2020-2023'); 
Map.addLayer(CollMEAN2_ARM_box.clip(ARM_box), style, 'ARM Box Nightlights_2020-2023');
Map.addLayer(CollMEAN2_MTL_REG.clip(MTL_REG), style, 'MTL Region Nightlights_Timeseries_2020-2023');

Map.setCenter(-73.57290649414064,45.51257031594274, 10);

///////////////////////////////////////
///////EXPORTING THE DATA /////////////
///////////////////////////////////////

// Export the image, specifying scale and region.
Export.image.toDrive({
  image: CollMEAN1_ARM_box.clip(ARM_box),
  description: 'imageToDriveExampleclip',
  scale: 30,
  region: ARM_box
});

// Function to extract values from image collection based on point file and export as a table 
var fill = function(img, ini) {
  var inift = ee.FeatureCollection(ini);
  var ft2 = img.reduceRegions(ARM_box, ee.Reducer.first(), 30); // Use MTL directly as the region of interest
  var date = img.date().format("YYYY-MM-dd");
  
  // Convert the nightlight value from the result to a number
  var nightlightValue = ee.Number(ft2.first().get("first"));
  
  // Create a feature with the "date" and "nW" properties
  var feature = ee.Feature(null, {
    'date': date,
    'nW': nightlightValue
  });
  
  return inift.merge(feature);
};

// Create an empty FeatureCollection to pass as initial value for the iteration
var ft2 = ee.FeatureCollection([]);

// Iterates over the ImageCollection
var profile = ee.FeatureCollection(Collection1.iterate(fill, ft2));
print(profile, 'profile');

// DOWNLOAD CSV
Export.table.toDrive({
  collection: profile,
  description: "VIIRS-" + early + "-" + late,
  fileNamePrefix: "VIIRS-" + early + "-" + late,
  fileFormat: 'CSV',
  folder: 'Nightlights',
  selectors: ["date", "nW"] // Export only the "date" and "nW" properties to the CSV
});
