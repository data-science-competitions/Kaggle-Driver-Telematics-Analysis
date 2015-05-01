%% Removing Time Dimension
% author: Harel Lustiger
%
% Algorithm pipeline:
%
% # Simplify trips using RDP (Ramer–Douglas–Peucker)
% # Divide the trip to equally steps intervals


%% Initialization
%
slCharacterEncoding('ISO-8859-1')
clear all, clc, close all, format bank, rng(2015)
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

% Trip to Explore $t \in {1,2,...,200}$
t=2; 
X1 = single(positive_sample.Dataset{1,t}(:,'X'));
Y1 = single(positive_sample.Dataset{1,t}(:,'Y'));

%% Step 1: Simplify trips using RDP
%
positive_RDP = getSpatialMeasurements(positive_sample,verbose);
X2 = single(positive_RDP.Dataset{1,t}(:,'X'));
Y2 = single(positive_RDP.Dataset{1,t}(:,'Y'));

%% Step 2: Trip interpolation
% We divide the trip to have equally steps intervals utilizing linear
% interpulations.
interval = 50; % In meters
positive_interpolate = tm_InterpolateTrips(positive_RDP,interval,verbose);
X3 = single(positive_interpolate.Dataset{1,t}(:,'X'));
Y3 = single(positive_interpolate.Dataset{1,t}(:,'Y'));

%% Visualisation
%
figure
subplot(1,3,1); plot(X1,Y1,'r',X1,Y1,'o'), axis square
title(['Original Data Points of Trip ',num2str(t)])
subplot(1,3,2); plot(X2,Y2,'r',X2,Y2,'o'), axis square
title(['RDP Data Points of Trip ',num2str(t)])
subplot(1,3,3); plot(X3,Y3,'r',X3,Y3,'o'), axis square
title(['Interpolated Data Points of Trip ',num2str(t)])
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
