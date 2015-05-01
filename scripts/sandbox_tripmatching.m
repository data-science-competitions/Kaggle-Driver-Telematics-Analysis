%% Trip Match Sandbox
% author: Harel Lustiger
%

%% Initialization
%
clear all, clc, close all, format short, rng(2015); slCharacterEncoding('ISO-8859-1')
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

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
N = 1; % Number of values to try
K = 5;  % Number of folds for CV
NumBind = 16;
scale_feature = false;
AUC_Per = zeros(K,N);
F_P1 = extractHoGFeatures(X_P,NumBind,false,scale_feature,false);
F_N1 = extractHoGFeatures(X_N,NumBind,false,scale_feature,false);
F_P2 = extractMiscFeatures(X_P);
F_N2 = extractMiscFeatures(X_N);
Npos = size(F_P1,1);
Nneg = size(F_N1,1);
% Calculate similarities
X_Dis1 = pdist([F_P1;F_N1],'cosine');
X_Dis2 = pdist([F_P2;F_N2],'seuclidean');
W1 = 1./(1+squareform(X_Dis1));
W2 = 1./(1+squareform(X_Dis2));
D1 = diag(sum(W1,2));
D2 = diag(sum(W2,2));
W1_Normalized = D1^(-1/2)*W1*D1^(-1/2);
W2_Normalized = D2^(-1/2)*W2*D2^(-1/2);
[~,~,V] = svd(W1_Normalized);
Q = quantile(W1(:),[0.01,0.99])
Free_Param = round(logspace(log10(Q(1)),log10(Q(2)),N),4);
parfor_progress(N); % Initialize progress monitor
for n=1:N
    % Count similar trips
    H = repmat(quantile(W1(201:400,1:400),0.995)',1,400);
    F = sum(W1>H)'-1;
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
Matches = find(W1(2,:)>0.95)%quantile(W1(2,201:400),0.99))
% Matches = [2,7,37,38,41,90,101,108,110,115,166,175,180];
% Matches = [2,7,38,1];
figure;
% k=16;
% plotAXA('trajectories',X_P,find(W1(k,:)>quantile(W1(k,201:400),0.99)))
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
plotAXA('trajectories',X_P,Matches)
% plotAXA('guns and roses',X_P,Matches,8,false)
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% figure; plotAXA('guns and roses',X_P,[1,6,9,11,12,17],16,false)
% figure; plotAXA('guns and roses',X_N,[147],16,false)

