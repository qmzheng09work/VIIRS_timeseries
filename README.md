# VIIRS_timeseries

## 1. Objectives

The codes of this repository is for characterising diverse types of urban land changes. Sepcifically, it comprises three key component:
(1) Modelling V1 monthly VIIRS time series with a logistic-harmonic model (LogH);
(2) Extracted temporal features and spectral features from the fitting results;
(3) Classify urban built-up area and disentangle different types of urban land changes;


## 2. Version info

Updated: Dec 20, 2020
Version: V1.0

The V1.0 is the unpolished version of the entire methhod framework. It works well but combines codes from GEE (javascript), matlab and python. We will try to update the algorihtm and compile all the codes into matlab or python later.


## 3. Brief introduction of the work flow

By following the introduction below you will be able to run all the codes and get the results you want.

You may either (1) use our codes (3.1 & 3.2) to fit monthly VIIRS time series and decomposite it into logistic trend, seasonality and error components or (2) follow the entire instruction of this section to map urban land change types.


### 3.1 Export VIIRS time series from GEE

Stack and export the cf_cvg and avg_rad images [[code](https://github.com/qmzheng09work/VIIRS_timeseries/blob/main/VIIRS%20time%20series%20output.js)].


### 3.2 Time series modelling

(1) convert cf_cvg and avg_rad images to pixel time series in .csv files [[code](https://github.com/qmzheng09work/VIIRS_timeseries/blob/main/Time%20Series%20fitting/Image_to_time_series.py)].

(2) fit the pixel time series of each target region [[code](https://github.com/qmzheng09work/VIIRS_timeseries/tree/main/Time%20Series%20fitting/fitting)].
    
   put all the avg_rad and cf_cvg files in the same folder directory <path>, e.g., avg_rad_NewYork.csv, cf_cvg_NewYork.csv, avg_rad_London.csv, cf_cvg_London.csv.....
    
   set <path> and <out_path> in TS_fitting_v1_batch.m and run.


### 3.3 Feature extraction

Extract trajectory features and spectral features (of each month) from the estimated model parameters in Section 3.2 [[code](https://github.com/qmzheng09work/VIIRS_timeseries/blob/main/Time%20Series%20fitting/feature_extraction.py)].


### 3.4 Urban built-up area mapping and urban land change type identification

Follow the detailed description in Section 3.3.3 and 3.3.4 of the paper to train Random Forest classifier, map monthly urban built-up area and identify urban land change types.

### 3.5 Convert .csv files back to geotiff

When necessary, you can use [[code](https://github.com/qmzheng09work/VIIRS_timeseries/blob/main/Time%20Series%20fitting/csv_to_geotiff.m)] to convert .csv files back to geotiff. 
