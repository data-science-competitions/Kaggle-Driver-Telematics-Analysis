slCharacterEncoding('ISO-8859-1')
clear all, clc, close all, format bank, rng(2015)
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

step_size = 50; % In meters
shingle_size = 10; % diff lag size
X_Temoporal = positive_sample;
X_Spatial   = getSpatialMeasurements(positive_sample,step_size,shingle_size,verbose);

figure;
t=84;

subplot(1,2,1);
plot(single((X_Temoporal.Dataset{1,t}(:,'X'))),single((X_Temoporal.Dataset{1,t}(:,'Y'))),'+')
axis square; title(['Trip #',num2str(t),' Movement Pattern'])
subplot(1,2,2); 
plot(single((X_Spatial.Dataset{1,t}(:,'X'))),single((X_Spatial.Dataset{1,t}(:,'Y'))),'+')
axis square; title(['Trip #',num2str(t),' Spatial Shape'])
