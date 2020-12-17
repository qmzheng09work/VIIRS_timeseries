# -*- coding: utf-8 -*-
"""
Created on Thu Dec 17 23:08:06 2020

@author: Qiming Zheng
"""



import numpy as np
import pandas as pd
from scipy.misc import derivative
import math
import os

def log_func(t,para):
    c1,c2,c3,c4=para.tolist()    
    return c1+c2/(1+np.exp(-c3*t+c4))


def linear_func(t,para):
    b1,b2=para.tolist()
    return b1+b2*t

def full_func(t,para):
    c1,c2,c3,c4,c5,c6,c7,c8=para.tolist() 
    return c1+c2/(1+np.exp(-c3*t+c4))+c5*np.sin(2*t*np.pi/12)+c6*np.cos(2*t*np.pi/12)+c7*np.sin(4*t*np.pi/12)+c8*np.cos(4*t*np.pi/12)

def sigmoid_turning_points(para):
    c1,c2,c3,c4=para.tolist() 
    t=np.linspace(-150,150,num=2000)
    def sig(t):
        return c1+c2/(1+np.exp(-c3*t+c4))
    dt1=[derivative(sig,i,dx=2,n=1) for i in list(t)] 
    log_est=sig(t)
    if log_est[0]<log_est[-1]:   
        dt1_point=t[dt1.index(max(dt1))]
    else: 
        dt1_point=t[dt1.index(min(dt1))]
    dt2=[derivative(sig,i,dx=2,n=2) for i in list(t)]
    dt2_max=t[dt2.index(max(dt2))]
    dt2_min=t[dt2.index(min(dt2))]
    cp1_temp=min(dt2_max,dt2_min)
    cp3_temp=max(dt2_max,dt2_min)
    cp1=cp1_temp*2-dt1_point
    cp3=cp3_temp*2-dt1_point
    return [dt1_point,cp1,cp3,dt1,dt2]


def get_general_features(para,idx):
        
        
    k=para[idx,10]    
    
    if k in [2,3]: 
        print('Change is detected.')
        [cp2,cp1,cp3,dt1,dt2]=sigmoid_turning_points(para[idx,0:4])
        flag=sum([1*(x>=0 and x<=84) for x in [cp1,cp2,cp3]])
        
        if flag>1:

            # magnitude 
            mag2=log_func(cp2,para[idx,0:4])
            mag1=log_func(cp1,para[idx,0:4])
            mag3=log_func(cp3,para[idx,0:4])

            # change features
            change_mag=mag3-mag1
            change_duration=cp3-cp1
            change_rate=change_mag/change_duration            
        
        else:
            cp1=1
            cp2=42
            cp3=84

                       
            mag2=log_func(cp2,para[idx,0:4])
            mag1=log_func(cp1,para[idx,0:4])
            mag3=log_func(cp3,para[idx,0:4])
            
            change_mag=mag3-mag1
            change_duration=cp3-cp1
            change_rate=change_mag/change_duration 
        magSeason=math.sqrt(para[idx,4]**2+para[idx,5]**2)+math.sqrt(para[idx,6]**2+para[idx,7]**2)
        return [cp1,cp2,cp3,mag1,mag2,mag3,change_mag,change_duration,change_rate,magSeason]
    
    else:
        print('No change is detected. Using linear model instead.')
        [b1,b2]=para[idx,0:2]
        cp1=1
        cp2=42
        cp3=84
                
        mag2=linear_func(cp2,para[idx,0:2])
        mag1=linear_func(cp1,para[idx,0:2])
        mag3=linear_func(cp3,para[idx,0:2])
        
        change_mag=mag3-mag1
        change_duration=cp3-cp1
        change_rate=change_mag/change_duration   
        magSeason=math.sqrt(para[idx,2]**2+para[idx,3]**2)+math.sqrt(para[idx,4]**2+para[idx,5]**2)
        return [cp1,cp2,cp3,mag1,mag2,mag3,change_mag,change_duration,change_rate,magSeason]


def output_features(para):
    num_idx=para.shape[0]
    # output features list
    column_name=['cp1','cp2','cp3','mag1','mag2','mag3','change_mag','change_duration','change_rate','MagSeason']
    list0=[]
    flag=0
    for i in range(0,num_idx):
        para_idx=get_general_features(para,i)
        list0.append(para_idx)
        if round(i/num_idx*100/5)>flag:
            flag=round(i/num_idx*100/5)
            print(round(i/num_idx*100,2),'%')
    df=pd.DataFrame(data=np.array(list0),columns=column_name)
    return df


# paras=[c_est1,c_est2,c_est3,c_est4,Rc_est5,c_est6,c_est7,c_est8,RMSE,Rsquare,k];
# k=0; no change； k=1 false change; k=2 nlinfit wins; k=3 lsqcurvefit wins;
# k4= linear better than log

# set folder directory of the estimiated model parameters
path=r'F:\OneDrive\Research\Black Marble Art\Paras2'+'\\'
files=[i for i in os.listdir(path) if os.path.splitext(i)[1]=='.csv']

# set output folder directory
out_path=r'F:\OneDrive\Research\Black Marble Art\Features2'+'\\'

for i in files:
    input_file=path+i;
    output_file=out_path+i.replace('paras','features',1)
    para=np.array(pd.read_csv(input_file,header=None))
    output_path=output_file
    df=output_features(para)
    df.to_csv(output_path)

