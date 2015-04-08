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

%% Extract features form the arbitrary data set (negative examples)
%
X_N = getTelematicMeasurements(negative_sample,verbose);
F_N = extractSpeedQuantiles(X_N,20,verbose); % 20 speed quantiles

%% Extract features form the driver of interest trips' batch (positive examples)
%
X_P = getTelematicMeasurements(positive_sample,verbose);
F_P = extractSpeedQuantiles(X_P,20,verbose); % 20 speed quantiles

%% Setup K-fold cross validation
%
K=10; % Number of folds

X = [F_N;F_P];
Nneg = size(F_N,1);
Npos = size(F_P,1);
labels = nominal([zeros(Nneg,1);ones(Npos,1)]);

rng(2015); % Set seed number
[AUC_Mean,AUC_Var] = cvModel(X,labels,K,verbose); % Evaluate Model
AUC_Mean,sqrt(AUC_Var)
