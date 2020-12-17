%%%%%%%%%%%%%%%%%%

% fitting VIIRS time series 
% Input: 
% <path> of the folding containing all the avg_rad and cf_cvg .csv files

% Output:
% export fitted model parameters and model performance variables to folder <out_path>

% output parameters:

% When:
% k=2 nlinfit algorihtm procudes the best estimation
% k=3 lsqcurvefit algorithm procudes the best estimation
% The time series is fitted by Logistic-Harmonic model (LogH):
% fun_full=inline('c(1)+c(2)./(1+exp(-c(3).*t+c(4)))+c(5).*sin(2*t*pi./12)+c(6).*cos(2*t*pi./12)+c(7).*sin(4*t*pi./12)+c(8).*cos(4*t*pi./12)','c','t');
% c(1)-c(8):c_est1,c_est2,c_est3,c_est4,c_est5,c_est6,c_est7,c_est8 
% RMSE,Rsquare


% When£º
% k=0 no change
% k=1 false change;
% k=4 LinH has a better fitting performance than LogH
% The time series is fitted by Linear-Harmonic model (LinH):
% fun_full_linear=inline('c(1)+c(2).*t+c(3).*sin(2*t*pi./12)+c(4).*cos(2*t*pi./12)+c(5).*sin(4*t*pi./12)+c(6).*cos(4*t*pi./12)','c','t');
% c(1)-c(6):c_est1,c_est2,c_est3,c_est4,c_est5,c_est6
% c_est7,c_est8=0;

%%%%%%%%%%%%%%%%%%
%% 
clear;
close all;
clc;

path='F:\OneDrive\Research\Black Marble Art\DataTest2\';
out_path='F:\OneDrive\Research\Black Marble Art\Paras2\';
files = dir([path,'*.','csv']);
num_file=length(files)/2;


 for j=1:num_file
    
    path_rad=[path,files(j*2-1).name];
    path_cvg=[path,files(j*2).name];
    
    rad= csvread(path_rad,1,1);
    cvg=csvread(path_cvg,1,1);
    
    if sum(rad(end,:))==0
        rad(end,:)=[];
    end
    
    if sum(cvg(end,:))==0
        cvg(end,:)=[];
    end
    
    num_obs=size(rad,2);
    num_record=size(rad,1);
    t=1:num_obs;
    
    k=zeros(num_record,1);
    c_est1=zeros(num_record,1);
    c_est2=zeros(num_record,1);
    c_est3=zeros(num_record,1);
    c_est4=zeros(num_record,1);
    c_est5=zeros(num_record,1);
    c_est6=zeros(num_record,1);
    c_est7=zeros(num_record,1);
    c_est8=zeros(num_record,1);
    RMSE=zeros(num_record,1);
    Rsquare=zeros(num_record,1);
    
    parfor i=1:num_record
        
        [k_temp,c_est_temp,RMSE_temp,Rsquare_temp]=logistic_fitting_v1(t,rad,cvg,i);
        k(i,1)=k_temp;
        if length(c_est_temp)==6
            c_est1(i,1)=c_est_temp(1);
            c_est2(i,1)=c_est_temp(2);
            c_est3(i,1)=c_est_temp(3);
            c_est4(i,1)=c_est_temp(4);
            c_est5(i,1)=c_est_temp(5);
            c_est6(i,1)=c_est_temp(6);
            
        else
            c_est1(i,1)=c_est_temp(1);
            c_est2(i,1)=c_est_temp(2);
            c_est3(i,1)=c_est_temp(3);
            c_est4(i,1)=c_est_temp(4);
            c_est5(i,1)=c_est_temp(5);
            c_est6(i,1)=c_est_temp(6);
            c_est7(i,1)=c_est_temp(7);
            c_est8(i,1)=c_est_temp(8);
        end
        RMSE(i,1)=RMSE_temp;
        Rsquare(i,1)=Rsquare_temp;
        
        fprintf('i=%d\n',i);
    end
    
    paras=[c_est1,c_est2,c_est3,c_est4,c_est5,c_est6,c_est7,c_est8,RMSE,Rsquare,k];
    outName=files(j*2-1).name;
    outFile=[out_path,outName(1:(strfind(files(j*2-1).name,'Viirs')-1)),'_paras.csv'];
    csvwrite(outFile,paras);
 end