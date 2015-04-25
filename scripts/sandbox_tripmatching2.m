%% Trip Matching 2
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
clear all, clc, close all, format bank, rng(2015); slCharacterEncoding('ISO-8859-1')
verbose = true;
% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')
interval = 20; % In meters
stride = 5;
NumBind = 80; % Number of angles tokens

%% Extract features form the arbitrary data set (negative examples)
%
X_N = negative_sample;
X_N.Dataset = X_N.Spatial;
X_N = rmfield(X_N,'Spatial');
X_N = tm_InterpolateTrips(X_N,interval,verbose);

%% Extract features form the driver of interest trips' batch (positive examples)
%
X_P  = positive_sample;
X_P.Dataset = X_P.Spatial;
X_P = rmfield(X_P,'Spatial');
X_P = tm_InterpolateTrips(X_P,interval,verbose);

%% Sanity Check
%
% figure
% plotAXA('trajectories',X_P,[2,7,38,41])
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);


%% Step 3: Represent trips as sets using k-shingles
% Define a k-shingle for a trip to be any successive points with lag k
% found within the trip. Then, we may associate with each trip the set of
% k-shingles that appear one or more times within that trip.
% For example: if k=10 and step_size = 50 then 10*50 = 500 meters shingles.
%
% 3.1. Choosing the number of angles bins
% We need to setup the number of angle bins to use and to set each
% angle bin range. Assume we make equily spaced b partitions in [-pi,pi].
X_P = tm_ConstructShingles(X_P,stride,verbose);
X_N = tm_ConstructShingles(X_N,stride,verbose);

% 3.2. Choosing the shingle Size
% We can pick k to be any constant we like. However, if we pick k too
% small, then we would expect most sequences of k angles to appear in
% most trips. Picking shingle size to be k, then there would be b^k
% possible shingles. If the typical trip is much smaller than b^k we would
% expect k to work well. However, the calculation is a bit more subtle.
% Suppose we have b different angles, not all angles appear with equal
% probability. Zeros dominate, while obtuse and reflex angles are rare.
%
F_N = tm_BindShingles(X_N,NumBind,false,verbose);
F_P = tm_BindShingles(X_P,NumBind,false,verbose);
X = [F_N;F_P];
% TF-IDF Weighting
% X = transpose(tfidf2(X'));

%% Step 4: Grid search for trip matching parameters
%
M = 1; % Number of different angle token sizes
N = 1; % Number of different shingle sizes
K = 10; % Number of folds for CV
stride  = ceil(linspace(10,10,N)); % diff lag size
NumBind = ceil(linspace(100,100,M));
AUC_Per = zeros(M,N,K);

parfor_progress(N*M); % Initialize progress monitor
for n=1:N
    X_Ps = tm_ConstructShingles(X_P,stride(n));
    X_Ns = tm_ConstructShingles(X_N,stride(n));
    for m=1:M
        F_P = tm_BindShingles(X_Ps,NumBind(m),false);
        F_N = tm_BindShingles(X_Ns,NumBind(m),false);
        Npos = size(F_P,1);
        Nneg = size(F_N,1);
        X = [F_P;F_N];
        % TF-IDF Weighting
        % X = transpose(tfidf2(X'));
        labels = [ones(Npos,1);zeros(Nneg,1)];
        rng(2015); % Set seed number
        [~,AUC_Per(m,n,1:K)] = cvModel(X,labels,K,false); % Evaluate Model
        clear F_N F_P X
        parfor_progress;
    end
end
parfor_progress(0); % Clean up progress monitor

figure
colormap('hot');   % set colormap
AUC_Mean = mean(AUC_Per,3);
imagesc(AUC_Mean)
set(gca,...
    'YTick', 1:M, 'YTickLabel', NumBind,...
    'XTick', 1:N, 'XTickLabel', stride)
ylabel('Angles Bins')
xlabel('Strides')
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

% %% Step 5: SVD
% %
% step_size = 50; % In meters
% shingle_size = 12; % diff lag size
% NumBind = 80; % Number of angles tokens
% UseSignedOrientation = false; % Selection of orientation values
% X_N = getSpatialMeasurements(negative_sample,step_size,shingle_size,verbose);
% X_P = getSpatialMeasurements(positive_sample,step_size,shingle_size,verbose);
% F_N = bindShingles(X_N,NumBind,UseSignedOrientation);
% F_P = bindShingles(X_P,NumBind,UseSignedOrientation);
% Nneg = size(F_N,1);
% Npos = size(F_P,1);
% X = [F_N;F_P];
% [U,S,V] = svd(X,'econ')
% labels = [zeros(Nneg,1);ones(Npos,1)];
% AUC_Mean = []; AUC_Var =[];
%
% parfor_progress(NumBind-1); % Initialize progress monitor
% for k=NumBind-1:-1:1
%     rng(2015); % Set seed number
%     [AUC_Mean(k),AUC_Var(k)] = cvModel(X(:,1:k),labels,5,false);
%     parfor_progress;
% end
% parfor_progress(0); % Clean up progress monitor
%
% figure
% plot(NumBind-1:-1:1,AUC_Mean)