# -*- coding: utf-8 -*-
"""
Created on Thu Dec 17 00:29:31 2020

@author: Qiming Zheng
"""


#from osgeo import gdal 
import gdal
import os,time
import numpy as np
import pandas as pd

startTime=time.time()


# reading all the type1 files under path
def read_img_list(path,type1):
    dirs = os.listdir(path)
    list1=[path+x for x in dirs if os.path.splitext(x)[1]==type1]
    print('**************')
    print('Reading the path of',type1,' images as a list')
    print('**************')
    return list1

# read one multi-band image from img_path
def read_img(img_path):

    bandList=[]
    ds=gdal.Open(img_path)
    rows=ds.RasterYSize
    cols=ds.RasterXSize
    bands=ds.RasterCount
    for i in range (bands):
        band=ds.GetRasterBand(i+1)
        data=band.ReadAsArray(0,0,cols,rows)
        bandList.append(data)
    return bandList  ##bandList is a LIST but not a np.array

# writing img into 
def write_img(img_path,output_name,data,data_format="GTiff",data_type=gdal.GDT_Byte):
    #path img: get image information;
    #output_name: path of output file
    #data_format: to setup format driver;
    #datatype: Byte?gdal.GDT_Float32?
    
    ds=gdal.Open(img_path)
    bands=ds.RasterCount
    projInfo=ds.GetProjection()
    geoTransform=ds.GetGeoTransform()
    
    #get driver to transform to another data format
    driver=gdal.GetDriverByName(data_format)
    
    #create new dataset and give basic information, including projection and geotransformation
    output_data=driver.Create(output_name,ds.RasterXSize,ds.RasterYSize,
                           bands, data_type)
    output_data.SetGeoTransform(geoTransform )
    output_data.SetProjection(projInfo)
    
    #write as a layer-stacking imageS
    for i in range(bands):
        output_data.GetRasterBand(i+1).WriteArray(ds.ReadAsArray()[i])
    output_data.FlushCache()


# intput: a stacked image time seies (bands,rows,cols) (bands,rows*cols)
# output: time series
def output_ts(img_list):
    img1=np.array(img_list)
    bands,rows,cols=img1.shape
    ts=img1[0].flatten()
    for i in range(1,bands):
        ts=np.vstack((ts,img1[i].flatten()))     
    return ts    


# Write Time series to CSV
def ts_df(ts):
    Month=['APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC','JAN','FEB','MAR']
    numMonth=np.array(ts).shape[0]
    colName=[]
    for i in range(numMonth):
        name=str(int(2012+np.floor((i+3)/12)))+'_'+Month[i % 12]
        colName.append(name)
    df=pd.DataFrame(data=ts.transpose(),columns=colName)
    return  df


# set folder path of cv_cfg and avg_rad images
path=r'F:\OneDrive\Research\Black Marble Art\DataTest2'+'\\'

list1=read_img_list(path,'.tif')
for i in range(len(list1)):
    img0=read_img(list1[i])
    print('**************')
    print('Transform a stacked image list into time series from',list1[i])
    print('**************')
    ts=output_ts(img0)
    out_csv_path=list1[i][:-4]+'.csv'
    df=ts_df(ts)
    df.to_csv(out_csv_path)
    print('**************')
    print('Writing time series to ',out_csv_path)
    print('**************')
endTime=time.time()
print('**************************DONE*************************')
print('The script took '+str(round(endTime-startTime,4))+' seconds')
print('**************************DONE*************************')
