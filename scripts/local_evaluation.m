%% Local Evaluation
% author: Harel Lustiger
%
% This script is contains a frame work to evaluate model AUC performance
% utilizing K-fold cross validation:
%

%% Initialization
%
clear all, clc, close all, format short, rng(2015); slCharacterEncoding('ISO-8859-1')
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

% QoD arguments
remove_zeros = true;
% HoG arguments
scale_feature = false;

%% Extract features form the arbitrary data set (negative examples)
%
X_N = negative_sample;
F_N1 = extractQoDFeatures(X_N,{'Distance','Speed','Acceleration'},[1,3],20,remove_zeros,true); % 20 speed quantiles
X_N.Dataset = X_N.Spatial; X_N = rmfield(X_N,'Spatial');
F_N2 = extractHoGFeatures(X_N,16,false,scale_feature,true);
F_N4 = extractMiscFeatures(X_N,true);
%% Extract features form the driver of interest trips' batch (positive examples)
%
X_P = positive_sample;
F_P1 = extractQoDFeatures(X_P,{'Distance','Speed','Acceleration'},[1,3],20,remove_zeros,true); % 20 speed quantiles
X_P.Dataset = X_P.Spatial; X_P = rmfield(X_P,'Spatial');
F_P2 = extractHoGFeatures(X_P,16,false,scale_feature,true);
F_P4 = extractMiscFeatures(X_P,verbose);

%% Weighting Factor
%
% 1. Temporal Features
F1 = [F_P1;F_N1];
% 2. Spatial Features
F2 = [F_P2;F_N2]; 
% 3. Template Matching
% 3.1. Calculate similarities
F3_Dis = pdist(F2,'seuclidean');
W = 1./(1+squareform(F3_Dis));
% 3.2. Calculate D
D = diag(sum(W,2));
% 3.3. Normolize W
W_norm = D^(-1/2)*W*D^(-1/2);
% 3.4. Find eigen vectors
[eig_vectors,eig_values] = eig(W_norm);
F3 = eig_vectors(:,1:7);
% 4. Misc Features
F4 = [F_P4;F_N4]; 

%% Setup K-fold cross validation
%
K=10; % Number of folds

X = [F1,F2,F3,F4];
%X = F3;
Npos = size(X_P.Dataset,2);
Nneg = size(X_N.Dataset,2);
labels = nominal([ones(Npos,1);zeros(Nneg,1)]);

rng(2015); % Set seed number
[AUC_mean,AUC_Per] = cvModel(X,labels,K,verbose); % Evaluate Model
AUC_mean
figure;
boxplot(AUC_Per); refline(0,0.5); refline(0,1)

%% Prediction
%
% BagModel = TreeBagger(100,X,labels,'method','classification','MinLeaf',10);
% [~,scores] = predict(BagModel,X);
% scores(:,1)=[];
% [B,I] = sort(scores,'descend');
% B(1:8);I(1:8);
