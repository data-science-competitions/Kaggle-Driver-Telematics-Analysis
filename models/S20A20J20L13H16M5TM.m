%% Submission - S20A20J20L13H16M5TM
% author: Harel Lustiger
%
% This script is a submission for the competition, featuring:
%
% # QoD with 1 and 3 lags of:
%     * 20 speed quantiles 
%     * 20 acceleration quantiles
%     * 20 jerks quantiles%
% # HoG: 16 bins angle histograms of distances
% # Trip Matching utilizing Ncuts of 7 eig vectors
% # 5 Misc Features

%% Initialization
%
clear all, clc, close all, format bank, rng(2015)
slCharacterEncoding('ISO-8859-1')
verbose = true;
% sourcePath = 'C:/Dropbox/Datasets/Driver-Telematics-Analysis-Processed';
sourcePath = 'D:/Driver-Telematics-Analysis-Processed';
destFile   = ['./submission/submission_',date,'.csv'];
if(exist('submission','dir')==0) mkdir('submission'); end
% QoD arguments
remove_zeros = false;

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
X_N = negative_sample;
F_N1 = extractQoDFeatures(X_N,{'Distance','Speed','Acceleration'},[1,3],20,remove_zeros,verbose);
X_N.Dataset = X_N.Spatial; X_N = rmfield(X_N,'Spatial');
F_N2 = extractHoGFeatures(X_N,16,false,false,true);
F_N3 = extractMiscFeatures(X_N,true);
%% Build Model for Each Driver
%
parfor_progress(nFileParts); % Initialize progress monitor
driver_trip = {}; prob = {}; tnumber={}; tbatch={};
for k=1:nFileParts
    % 1. Load a part of the processed dataset
    % (see **preprocess_the_dataset.m**)
    load(fileList{k},'trips_structure');
    % 2. Load one batch
    batch_number = unique(cell2mat(trips_structure.Batch));
    partial_driver_trip = {}; partial_prob = {}; partial_tnumber={}; partial_tbatch={};
    parfor b=1:length(batch_number)
        batch_indices = find(batch_number(b)==cell2mat(trips_structure.Batch));
        batch_structure = structfun(@(v) v(batch_indices),trips_structure,'Uniform',0);
        % 3. Feature Engineering
        X_P = batch_structure;
        F_P1 = extractQoDFeatures(X_P,{'Distance','Speed','Acceleration'},[1,3],20,remove_zeros);
        X_P.Dataset = X_P.Spatial; X_P = rmfield(X_P,'Spatial');
        F_P2 = extractHoGFeatures(X_P,16,false,false,false);
        F_P3 = extractMiscFeatures(X_P,false);
        F1 = [F_P1;F_N1];
        F2 = [F_P2;F_N2];
        F3 = [F_P3;F_N3];
        % 4. Template Matching
        % 4.1. Calculate similarities
        F4_Dis = pdist(F2,'seuclidean');
        W = 1./(1+squareform(F4_Dis));
        % 4.2. Calculate D
        D = diag(sum(W,2));
        % 4.3. Normolize W
        W_norm = D^(-1/2)*W*D^(-1/2);
        % 4.4. Find eigen vectors
        [eig_vectors,eig_values] = eig(W_norm);
        F4 = eig_vectors(:,1:7);
        % 5. Classification
        F = [F1,F2,F3,F4];
        lP = 200; lN = 200;
        labels = nominal([ones(lP,1);zeros(lN,1)]);
        % Build random forest
        learners = 'tree'; ntrees = 100;
        BagModel = TreeBagger(...
            ntrees,F,labels,'method','classification','MinLeaf',10);
        % Predict
        [~,scores] = predict(BagModel,F);
        % 6. Store results
        b_n = uint32(batch_number(b));
        scores = scores(:,2);
        partial_driver_trip{b} = batch_structure.ID';
        partial_prob{b} = scores(1:200);
        partial_tnumber{b} = batch_structure.Number;
        partial_tbatch{b} = batch_structure.Batch;
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
    prob        = [prob,partial_prob];
    tnumber     = [tnumber,partial_tnumber];
    tbatch      = [tbatch,partial_tbatch];
end

%% Save submission file
%
sampleSubmission = ...
    dataset({repmat({'NA'},3612*200,1),'driver_trip'},{repmat(0,3612*200,1),'prob'});

for l=1:length(driver_trip)
    trip_ind = double((cell2mat(tbatch{1,l})-1))*200+double(cell2mat(tnumber{1,l}));
    sampleSubmission(trip_ind,{'driver_trip'}) = cell2dataset(driver_trip{1,l},'VarNames',{'driver_trip'});
    sampleSubmission(trip_ind,{'prob'}) = dataset(prob{1,l});
end

% Remove empty rows
emptyrows = find(strcmp(sampleSubmission.driver_trip,'NA'));
sampleSubmission(emptyrows,:)=[];

% Export file
if(exist('submission','dir')==0) mkdir('submission'); end
export(sampleSubmission,'File',destFile,'Delimiter',',')
gzip(destFile)
delete(destFile)

%% Close threads
%
parfor_progress(0); % Clean up progress monitor
delete(gcp)
% system('shutdown -s')

