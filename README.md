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

### 3.1 Export VIIRS time series from GEE

code: VIIRS_timeseries/VIIRS time series output

objecgive: stack and export the cf_cvg and avg_rad images

instruction: 

(1) select the roi, for this example is Hangzhou;

(2) set the start and end of the study period;

(3) use "cf_cvg" and "avg_rad" seperately to output cloud free observation and averaged monthly radiance data of each roi;
