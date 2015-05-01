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
NumBind = 16;

%% Extract features form the arbitrary data set (negative examples)
%
X_N = negative_sample;
F_N1 = [
    extractQoDFeatures(X_N,{'Distance'},[1,3,4],20,remove_zeros,true),... % 20 speed quantiles
    extractQoDFeatures(X_N,{'Speed'},[1,3],20,remove_zeros,true),...      % 20 acceleration quantiles
    extractQoDFeatures(X_N,{'Acceleration'},1:4,20,remove_zeros,true)];   % 20 jerks quantiles
X_N.Dataset = X_N.Spatial; X_N = rmfield(X_N,'Spatial');
F_N2 = extractHoGFeatures(X_N,NumBind,false,scale_feature,true);
F_N3 = extractMiscFeatures(X_N,true);
%% Extract features form the driver of interest trips' batch (positive examples)
%
X_P = positive_sample;
F_P1 = [
    extractQoDFeatures(X_P,{'Distance'},[1,3,4],20,remove_zeros,true),... % 20 speed quantiles
    extractQoDFeatures(X_P,{'Speed'},[1,3],20,remove_zeros,true),...    % 20 acceleration quantiles
    extractQoDFeatures(X_P,{'Acceleration'},1:4,20,remove_zeros,true)]; % 20 jerks quantiles
X_P.Dataset = X_P.Spatial; X_P = rmfield(X_P,'Spatial');
F_P2 = extractHoGFeatures(X_P,NumBind,false,scale_feature,true);
F_P3 = extractMiscFeatures(X_P,verbose);

%% Weighting Factor
%
% 1. Temporal Features
F1 = [F_P1;F_N1];
% 2. Spatial Features
F2 = [F_P2;F_N2];
% 3. Misc Features
F3 = [F_P3;F_N3];
% 4. Template Matching
X_Dis = pdist([F_P2;F_N2],'cosine');
W = 1./(1+squareform(X_Dis));
F4 = [];
for (k=1:400)
    % Get p-values
    [~,F4(k,1),~,~] = ttest2(W(setdiff(1:200,k),k),W(setdiff(201:400,k),k),...
        'Vartype','unequal','Tail','right');
end
F4(F4<=0.01) = 0;
F4(F4>0.01)  = 1;
% F4(201:400)  = 1;
% figure
% subplot(2,1,1); hist(F4(1:200),0:0.01:1)
% subplot(2,1,2); hist(F4(201:400),0:0.01:1)
% sum(F4(1:200)<0.05)
% sum(F4(201:400)<0.05)
%% Setup K-fold cross validation
%
K=10; % Number of folds
X = [F1,F2,F3,F4];

Npos = size(X_P.Dataset,2);
Nneg = size(X_N.Dataset,2);
labels = nominal([ones(Npos,1);zeros(Nneg,1)]);

rng(2015); % Set seed number
[AUC_mean,AUC_Per] = cvModel(X,labels,K,verbose); % Evaluate Model
disp([mean(AUC_Per),median(AUC_Per)])

figure;
boxplot(AUC_Per); refline(0,0.5); refline(0,1)

%% Prediction
%
% BagModel = TreeBagger(100,X,labels,'method','classification','MinLeaf',10);
% [~,scores] = predict(BagModel,X);
% scores(:,1)=[];
% [B,I] = sort(scores,'descend');
% B(1:8);I(1:8);
