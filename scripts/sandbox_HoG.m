%% Feature Engineering
% author: Harel Lustiger
%

%% Initialization
%
clear all, clc, close all, format bank, rng(2015); slCharacterEncoding('ISO-8859-1')
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

%% HoG
% Kernel
NumBind = 8;
UseSignedOrientation = false;
scale_feature = false;
% X = single(positive_sample.Dataset{1,6}(:,'X'))
% Y = single(positive_sample.Dataset{1,6}(:,'Y'))
% theta = [0;atan2(diff(Y),diff(X))];
% rho = [0;diff(cumsum([0;sqrt(diff(X).^2+diff(Y).^2)]))];
% [HoG_Magnitude,HoG_Phase,HoG_Labels] = extractHoGFeaturesKernel(theta,rho,NumBind,UseSignedOrientation);

%% Grid search for HoG parameters
%
N = 40; % Number of different angle bins sizes
K = 5; % Number of folds for CV
NumBind = ceil(linspace(8,48,N));
UseSignedOrientation = false; % Selection of orientation values
scale_feature = false;
AUC_Per = zeros(K,N);

parfor_progress(N); % Initialize progress monitor
X_P = positive_sample;
X_N = negative_sample;
for n=1:N
    F_P = extractHoGFeatures(X_P,NumBind(n),UseSignedOrientation,scale_feature,false);
    F_N = extractHoGFeatures(X_N,NumBind(n),UseSignedOrientation,scale_feature,false);
    Npos = size(F_P,1);
    Nneg = size(F_N,1);
    X = [F_P;F_N];
    % TF-IDF Weighting
    %X = transpose(tfidf2(X'));
    labels = [ones(Npos,1);zeros(Nneg,1)];
    rng(2015); % Set seed number
    [~,AUC_Per(1:K,n)] = cvModel(X,labels,K,false); % Evaluate Model
    clear F_N F_P
    parfor_progress;
end
parfor_progress(0); % Clean up progress monitor

figure
boxplot(AUC_Per,NumBind); refline(0,0.5); refline(0,1)

NumBind = 16; UseSignedOrientation = false;
% figure
% plotAXA('roses',positive_sample,[2,7],NumBind,UseSignedOrientation)
figure
plotAXA('guns and roses',positive_sample,[2,7,11,13],NumBind,UseSignedOrientation)
% figure
% plotAXA('trajectories',positive_sample,[2,7])
