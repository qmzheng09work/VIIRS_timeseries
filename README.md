# VIIRS_timeseries

## 1. Objectives

The codes of this repository is for characterising diverse types of urban land changes. Sepcifically, it comprises three key component:
(1) Modelling V1 monthly VIIRS time series with a logistic-harmonic model (LogH);
(2) Extracted temporal features and spectral features from the fitting results;
(3) Classify urban built-up area and disentangle different types of urban land changes;

## 2. Version info

Updated: Dec 20, 2020
Version: V1.0

The V1.0 is the unpolished version of the entire methhod framework. It works well, but it combines codes from GEE (javascript), matlab and python. We will try to update the algorihtm and compile all the codes into python.

## 3. Brief introduction of the work flow

By following the introduction below you will be able to run all the codes and get the results you want.

### 3.1 Export VIIRS time series from GEE [[code](https://github.com/qmzheng09work/VIIRS_timeseries/blob/main/VIIRS%20time%20series%20output)].

Stack and export the cf_cvg and avg_rad images.


### 3.2 Time series modelling [code](https://github.com/qmzheng09work/VIIRS_timeseries/tree/main/Time%20Series%20fitting

(1) convert cf_cvg and avg_rad images to pixel time series in .csv files 

(2) fit the pixel time series of each target region (or city) 
