%% transform .csv files to geotiff images

clear;
clc;
close all;

% set a random image of the targe region (e.g., avg_rad_NewYork.tif) to get the georeference information
path_img='C:\Users\Qiming Zheng\Desktop\test1\BristolViirsAvg.tif';

% set input folder that stores the .csv files of the same region
path_folder='C:\Users\Qiming Zheng\Desktop\test1\variables\';

% set output folder
path_out_folder='C:\Users\Qiming Zheng\Desktop\test1\variables\';
files=dir([path_folder,'*','.csv']);

[img,R]=geotiffread(path_img);
info=geotiffinfo(path_img);
[row,col,obs]=size(img);

flag=1; 
% flag=1: avg_rad/cf_cvg .csv files; as these .csv files have an index
% column and header row
% flag=0: others

for k=1:length(files)    
    ts= csvread([path_folder,files(k).name],flag,flag);
    img_all=zeros(row,col,obs);
    for i=1:obs
        img_all(:,:,i)=reshape(ts(:,i),[col,row])';
    end
    out_name=files(k).name;     
    geotiffwrite([path_out_folder,out_name(1:end-4),'.tif'],img_all,R,'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
end
