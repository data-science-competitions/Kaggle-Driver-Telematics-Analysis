%% Preprocess the Dataset
% author: Harel Lustiger
%
% This script takes the raw data set as given by the competition
% organizers, pre-process the whole dataset, and save it in several parts.
%

%% Initialization
%
clear all, clc, close all, format bank, rng(2015)%, warning('off','all')
slCharacterEncoding('ISO-8859-1')
verbose = true;
sourcePath = 'D:/Driver-Telematics-Analysis';
destPath   = 'D:/Driver-Telematics-Analysis-Processed';
% sourcePath = 'C:/Dropbox/Datasets/Driver-Telematics-Analysis';
% destPath   = 'C:/Dropbox/Datasets/Driver-Telematics-Analysis-Processed';
if(exist(destPath,'dir')==0) mkdir(destPath); end
Nparts = 32;

%% Data Pre-Preocessing
% Open parallel pool
pools = matlabpool('size');
cpus = feature('numCores');
if pools ~= (2*cpus - 1)
    if pools > 0
        matlabpool('close');
    end
    matlabpool('open', cpus*2 - 1);
end

% Get all folder paths (2736)
fileList = getAllFiles(sourcePath,verbose);
K = length(fileList);

% Set parts indices
inPart = round(linspace(1,K/200,Nparts+1));

% Process the data in parts
parfor_progress(Nparts); % Initialize progress monitor

parfor k=1:Nparts
    % Import data set to main memory
    partial_fileList = fileList(((inPart(k)-1)*200+1):inPart(k+1)*200);
    trips_structure = importTripsFromFileList(partial_fileList,false);
    % Get telematic measurements
    X1 = getTelematicMeasurements(trips_structure,false);
    % Get spatial measurements
    X2 = getSpatialMeasurements(trips_structure,false);
    % Combine measurements
    trips_structure = X1;
    trips_structure.Spatial = X2.Dataset;
    % Save the processed part on the hard drive
    save_for_parfor([destPath,'/','part_',num2str(k),'.mat'],trips_structure)
    parfor_progress;
end
parfor_progress(0); % Clean up progress monitor
delete(gcp)
% system('shutdown -s')


