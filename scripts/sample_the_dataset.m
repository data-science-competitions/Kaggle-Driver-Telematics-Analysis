%% Sample the Dataset
% author: Harel Lustiger
%
% This script is about the following topics:
%
% # Loading the raw data and representing it in the main memory.
% # Generating a represented data sample for local evaluation purposes.
%
% For local evaluation purposes, we sample one arbitrary trip from each
% batch (a total of 2736 trips) and assign them as negative class.
% In addition, we take one arbitrary batch (in this case the 10th batch)
% and assign all the trips within it as positive class.
%

%%
%
clear all, clc, close all, format bank, rng(2015)
slCharacterEncoding('ISO-8859-1')
verbose = true;
%%%
% Get all folder paths (2736)
dirName = 'D:/Driver-Telematics-Analysis';
% dirName = 'C:/Dropbox/Datasets/Driver-Telematics-Analysis';
fileList = getAllFiles(dirName,verbose);
K = length(fileList);
% Trip matching parmeters
step_size = 50; % In meters
shingle_size = 12; % diff lag size
NumBind = 80; % Number of angles tokens

%%%
% Example: Read an arbitrary trip using importSingleTrip
%
%   arbitrary_trip = importSingleTrip(fileList{p,1})
%
%%%
% Example: Read an arbitrary trip using importTripsFromFileList
%
%   arbitrary_trip = importTripsFromFileList(fileList(p,1),verbose)
%

%% Generating a represented data set
%%%
% *Positive dataset*:
% Choose the driver of intersts. Specifiy a number in the range: [1,2736]
doi = 5;
psfl = fileList((doi-1)*200+1:doi*200);
positive_sample = importTripsFromFileList(psfl,verbose);
% Get telematic measurements
X1 = getTelematicMeasurements(positive_sample,verbose);
% Get spatial measurements
X2 = getSpatialMeasurements(positive_sample,step_size,shingle_size,verbose);
% Combine measurements
positive_sample = X1;
positive_sample.Spatial = X2.Dataset;
%%%
% *Negative dataset*:
% Choose how many irelevent trips to assigned for the *negative data set*.
% Specifiy a number in the range: [200,2736]. Use 200 for balanced classes.
itta = 200;
n1 = randperm(200,1);
n2 = 200*2736-randperm(200,1);
nsfl = fileList(round(linspace(n1,n2,itta)));
negative_sample = importTripsFromFileList(nsfl,verbose);
% Get telematic measurements
X1 = getTelematicMeasurements(negative_sample,verbose);
% Get spatial measurements
X2 = getSpatialMeasurements(negative_sample,step_size,shingle_size,verbose);
% Combine measurements
negative_sample = X1;
negative_sample.Spatial = X2.Dataset;

%% Save files to data folder
%
if(exist('data','dir')==0) mkdir('data'); end
save('./data/sampled_dataset','negative_sample','positive_sample')