%% Trip Matching
% author: Harel Lustiger
%
% Algorithm pipeline:
%
% # Simplify trips using RDP (Ramer–Douglas–Peucker)
% # Divide the trip to equally steps intervals
% # Represent trips as sets using k-shingles
% # Find similar trips in the corpus
%


%% Initialization
%
slCharacterEncoding('ISO-8859-1')
clear all, clc, close all, format bank, rng(2015)
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

%% Step 1: Simplify trips using RDP
%
t=84; % trip number \in {1,2,...,200}
X = single(positive_sample.Dataset{1,t}(:,'X'));
Y = single(positive_sample.Dataset{1,t}(:,'Y'));

PointList_reduced = RDPKernel([X,Y], 'AUTO', verbose);
title('Simplify trips using RDP')
X_re = PointList_reduced(:,1);
Y_re = PointList_reduced(:,2);

%% Step 2: Trip interpolation
% We divide the trip to have equally steps intervals utilizing linear
% interpulations.
step_size = 50; % In meters
dx = diff(X_re);
dy = diff(Y_re);
total_length = sum(sqrt(dx.*dx+dy.*dy));

figure
P = interparc(linspace(0,1,ceil(total_length/step_size)),X_re,Y_re,'linear');
X_step = P(:,1);
Y_step = P(:,2);
plot(X,Y,X_step,Y_step,'ro'), axis square
title('Trip interpolation')
%% Step 3: Represent trips as sets using k-shingles
% Define a k-shingle for a trip to be any successive points with lag k
% found within the trip. Then, we may associate with each trip the set of
% k-shingles that appear one or more times within that trip.
% For example: if k=10 and step_size = 50 then 10*50 = 500 meters shingles.
%
% 3.1. Choosing the number of angles bins
% We need to setup the number of angle bins to use and to set each
% angle bin range. Assume we make equily spaced b partitions in [-pi,pi].
%
% 3.2. Choosing the shingle Size
% We can pick k to be any constant we like. However, if we pick k too
% small, then we would expect most sequences of k angles to appear in
% most trips. Picking shingle size to be k, then there would be b^k
% possible shingles. If the typical trip is much smaller than b^k we would
% expect k to work well. However, the calculation is a bit more subtle.
% Suppose we have b different angles, not all angles appear with equal
% probability. Zeros dominate, while obtuse and reflex angles are rare.
%
step_size = 50; % In meters
shingle_size = 12; % diff lag size
NumBind = 80; % Number of angles tokens
UseSignedOrientation = false; % Selection of orientation values
X_N = getSpatialMeasurements(negative_sample,step_size,shingle_size,verbose);
X_P = getSpatialMeasurements(positive_sample,step_size,shingle_size,verbose);
F_N = bindShingles(X_N,NumBind,UseSignedOrientation);
F_P = bindShingles(X_P,NumBind,UseSignedOrientation);
X = [F_N;F_P];
% TF-IDF Weighting
W = (sum(X,1)/sum(sum(X,1))).^-1;
X = X.*repmat(W,400,1);

%% Step 4: Grid search for trip matching parameters
%
step_size = 50; % In meters
m = 10; % Number of differend angle token sizes
n = 10; % Number of differend shingle sizes
UseSignedOrientation = false; % Selection of orientation values
shingle_size = ceil(linspace(1,20,n)); % diff lag size
NumBind = ceil(linspace(10,100,m));
AUC_Mean = []; AUC_Var =[];

parfor_progress(n); % Initialize progress monitor
for p=1:n
    X_N = getSpatialMeasurements(negative_sample,step_size,shingle_size(p),false);
    X_P = getSpatialMeasurements(positive_sample,step_size,shingle_size(p),false);
    for l=1:m
        F_N = bindShingles(X_N,NumBind(l),UseSignedOrientation);
        F_P = bindShingles(X_P,NumBind(l),UseSignedOrientation);
        Nneg = size(F_N,1);
        Npos = size(F_P,1);
        X = [F_N;F_P];
        % TF-IDF Weighting
%         W = (sum(X,1)/sum(sum(X,1))).^-1;
%         X = X.*repmat(W,400,1);
        labels = [zeros(Nneg,1);ones(Npos,1)];
        rng(2015); % Set seed number
        [AUC_Mean(l,p),AUC_Var(l,p)] = cvModel(X,labels,5,false); % Evaluate Model
        clear F_N F_P X
    end
    parfor_progress;
end
parfor_progress(0); % Clean up progress monitor

figure
colormap('hot');   % set colormap
imagesc(AUC_Mean)
set(gca,...
    'YTick', 1:m, 'YTickLabel', NumBind,...
    'XTick', 1:n, 'XTickLabel', shingle_size)
ylabel('Number of differend angle token sizes')
xlabel('Number of differend shingle sizes')

%% Step 5: SVD
%
step_size = 50; % In meters
shingle_size = 12; % diff lag size
NumBind = 80; % Number of angles tokens
UseSignedOrientation = false; % Selection of orientation values
X_N = getSpatialMeasurements(negative_sample,step_size,shingle_size,verbose);
X_P = getSpatialMeasurements(positive_sample,step_size,shingle_size,verbose);
F_N = bindShingles(X_N,NumBind,UseSignedOrientation);
F_P = bindShingles(X_P,NumBind,UseSignedOrientation);
Nneg = size(F_N,1);
Npos = size(F_P,1);
X = [F_N;F_P];
[U,S,V] = svd(X,'econ')
labels = [zeros(Nneg,1);ones(Npos,1)];
AUC_Mean = []; AUC_Var =[];

parfor_progress(NumBind-1); % Initialize progress monitor
for k=NumBind-1:-1:1
    rng(2015); % Set seed number
    [AUC_Mean(k),AUC_Var(k)] = cvModel(X(:,1:k),labels,5,false);
    parfor_progress;
end
parfor_progress(0); % Clean up progress monitor

figure
plot(NumBind-1:-1:1,AUC_Mean)