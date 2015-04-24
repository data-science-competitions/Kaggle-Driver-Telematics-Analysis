%% Local Evaluation
% author: Harel Lustiger
%
% This script is contains a frame work to evaluate model AUC performance
% utilizing K-fold cross validation:
%

%% Initialization
%
clear all, clc, close all, format bank, rng(2015); slCharacterEncoding('ISO-8859-1')
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

% QoD arguments
remove_zeros = true;
% HoG arguments
scale_feature = false;

%% Extract features form the arbitrary data set (negative examples)
%
X_N = getTelematicMeasurements(negative_sample,verbose);
F_N1 = extractQoDFeatures(X_N,{'Distance','Speed','Acceleration'},[1,3],20,remove_zeros,true); % 20 speed quantiles
F_N2 = extractHoGFeatures(X_N,16,false,scale_feature,true);

%% Extract features form the driver of interest trips' batch (positive examples)
%
X_P = getTelematicMeasurements(positive_sample,verbose);
F_P1 = extractQoDFeatures(X_P,{'Distance','Speed','Acceleration'},[1,3],20,remove_zeros,true); % 20 speed quantiles
F_P2 = extractHoGFeatures(X_P,16,false,scale_feature,true);

%% Weighting Factor
%
F1 = [F_P1;F_N1];
F2 = [F_P2;F_N2];
% F2 = transpose(tfidf2(F2'));

%% Setup K-fold cross validation
%
K=10; % Number of folds

X = [F1,F2];
Nneg = size(F_N1,1);
Npos = size(F_P1,1);
labels = nominal([ones(Npos,1);zeros(Nneg,1)]);

rng(2015); % Set seed number
[AUC_mean,AUC_Per] = cvModel(X,labels,K,verbose); % Evaluate Model
AUC_mean
figure;
boxplot(AUC_Per); refline(0,0.5); refline(0,1)
