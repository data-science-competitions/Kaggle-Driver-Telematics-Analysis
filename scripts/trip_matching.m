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
t=46; % trip number \in {1,2,...,200}
X = single(positive_sample.Dataset{1,t}(:,'X'));
Y = single(positive_sample.Dataset{1,t}(:,'Y'));

PointList_reduced = RDPKernel([X,Y], 'AUTO', verbose);
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
shingle_size = 10; % shingle size
X_N = getSpatialMeasurements(negative_sample,step_size,shingle_size,verbose);
X_P = getSpatialMeasurements(positive_sample,step_size,shingle_size,verbose);

b = 8;  % number of angles bins








