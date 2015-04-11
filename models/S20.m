%% Submission - 20S
% author: Harel Lustiger
%
% This script is a submission for the competition, featuring:
%
% # QoG: 20 speed quantiles

%% Initialization
%
clear all, clc, close all, format bank, rng(2015)
slCharacterEncoding('ISO-8859-1')
verbose = true;
sourcePath = 'C:/Dropbox/Datasets/Driver-Telematics-Analysis-Processed';
destFile   = ['./submission/submission_',date,'.csv'];
if(exist('submission','dir')==0) mkdir('submission'); end

fileList = getAllFiles(sourcePath,verbose);
nFileParts = length(fileList);
% Open parallel pool
pools = matlabpool('size');
cpus = feature('numCores');
if pools ~= (cpus*2 - 1)
    if pools > 0
        matlabpool('close');
    end
    matlabpool('open', cpus*2 - 1);
end

%% Generate a represented data set (negative examples)
% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')
%%%
X_N1 = getTelematicMeasurements(negative_sample,verbose);
F_N1 = extractSpeedQuantiles(X_N1,20,verbose); % 20 speed quantiles

%% Build Model for Each Driver
%
parfor_progress(nFileParts); % Initialize progress monitor
driver_trip = {}; prob = {};
for k=1:nFileParts
    % 1. Load a part of the processed dataset
    % (see **preprocess_the_dataset.m**)
    load(fileList{k},'trips_structure');
    % 2. Load one batch
    batch_number = unique(cell2mat(trips_structure.Batch));
    partial_driver_trip = {}; partial_prob = {};
    parfor b=1:length(batch_number)
        batch_indices = find(batch_number(b)==cell2mat(trips_structure.Batch));
        batch_structure = structfun(@(v) v(batch_indices),trips_structure,'Uniform',0);
        % 3. Feature Engineering
        X_P1 = getTelematicMeasurements(batch_structure);
        F_P1 = extractSpeedQuantiles(X_P1,20); % 20 speed quantiles
        % 4. Classification
        F_P = [F_P1];
        F_N = [F_N1];
        F = [F_P;F_N];
        lP = size(F_P,1);
        lN = size(F_N,1);
        labels = nominal([ones(lP,1);zeros(lN,1)]);
        % Build random forest
        learners = 'tree'; ntrees = 100;
        BagModel = TreeBagger(...
            ntrees,F,labels,'method','classification','MinLeaf',10);
        % Predict
        [~,scores] = predict(BagModel,F);
        % 5. Store results
        b_n = uint32(batch_number(b));
        scores = scores(:,2);
        partial_driver_trip{b} = batch_structure.ID';
        partial_prob{b} = scores(1:200);
        if(prod(size(partial_prob{b})==size(partial_driver_trip{b}))==0)
            error('Number of Probabilities ~= Number of trips')
        end
    end
    if(length(batch_number)~=size(partial_prob,2))
        display(['part ',num2str(k),' of ',num2str(nFileParts)])
        display([num2str(length(batch_number)),'~=',num2str(size(partial_prob,2))])
        error('Unique batches ~= Number of models built')
    end
    parfor_progress;
    driver_trip = [driver_trip,partial_driver_trip];
    prob = [prob,partial_prob];
end
partial_driver_trip = [];
partial_prob = [];
for l=1:length(driver_trip)
    partial_driver_trip = [partial_driver_trip;driver_trip{1,l}];
    partial_prob = [partial_prob;prob{1,l}];
end
driver_trip = partial_driver_trip;
prob = partial_prob;
export(dataset(driver_trip,prob),'File',destFile,'Delimiter',',');


%% Close threads
%
parfor_progress(0); % Clean up progress monitor
% delete(gcp)

