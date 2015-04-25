%% Trip Match Sandbox
% author: Harel Lustiger
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
scale_feature = true;
NumBind = 8;
%% Extract features form the arbitrary data set (negative examples)
%
X_N = negative_sample;
X_N.Dataset = X_N.Spatial;
X_N = rmfield(X_N,'Spatial');

%% Extract features form the driver of interest trips' batch (positive examples)
%
X_P  = positive_sample;
X_P.Dataset = X_P.Spatial;
X_P = rmfield(X_P,'Spatial');

%% Grid search for HoG parameters
%
N = 10; % Number of values to try
K = 5;  % Number of folds for CV
NumBind = 32;
scale_feature = false;
AUC_Per = zeros(K,N);
F_P = extractHoGFeatures(X_P,NumBind,false,scale_feature,false);
F_N = extractHoGFeatures(X_N,NumBind,false,scale_feature,false);
Npos = size(F_P,1);
Nneg = size(F_N,1);
X = [F_P;F_N];
% TF-IDF Weighting
%X = transpose(tfidf2(X'));
% Step 1: Calculate similarities
%X_Dis = pdist(X,'cosine');
X_Dis = pdist(X,'seuclidean');
W = 1./(1+squareform(X_Dis));
% Calculate D
D = diag(sum(W,2));
% Normolize W
W_norm = D^(-1/2)*W*D^(-1/2);
% Step 2:
[eig_vectors,eig_values] = eig(W_norm);
% Q = quantile(W_norm(:),[0.01,0.99])
Free_Param = 1:N;%round(logspace(log10(Q(1)),log10(Q(2)),N),4);%ceil(linspace(8,16,N));
parfor_progress(N); % Initialize progress monitor
for n=1:N
    % Count similar trips
    %     F = sum(W_norm>Free_Param(n))'-1;
    F = eig_vectors(:,1:n);
    labels = [ones(Npos,1);zeros(Nneg,1)];
    rng(2015); % Set seed number
    [~,AUC_Per(1:K,n)] = cvModel(F,labels,K,false); % Evaluate Model
    clear F_N F_P
    parfor_progress;
end
parfor_progress(0); % Clean up progress monitor
figure
boxplot(AUC_Per,Free_Param); refline(0,0.5); refline(0,1)
mx = mean(AUC_Per); hold on; text(1:N,mx,num2cell(round(mx,3)))
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% p_value = [];
% h = [];
% for (k=1:400)
%     % H0: populations with equal means
%     % H1: populations with unequal means
%     [h(k),p_value(k)] = ttest(...
%         W(k,1:200), mean(W(k,201:400)),...
%         'Alpha',0.005);
% end
% A = [h',p_value'];

%% Plots
% [2,7,38,41,110,185]
% [27,91,100]
% figure
% plotAXA('trajectories',X_P,[2,7,38,115])
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% plotAXA('guns and roses',X_P,find(W(27,:)>0.91),16,false)
% figure; plotAXA('guns and roses',X_P,[1,6,9,11,12,17],16,false)
% figure; plotAXA('guns and roses',X_N,[147],16,false)

