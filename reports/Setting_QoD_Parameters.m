%% Setting QoD Parameters
% author: Harel Lustiger
%
% # QQ plot to choose number of quantiles
% # ACF and PACF to choose time lags


%% Initialization
%
slCharacterEncoding('ISO-8859-1')
clear all, clc, close all, format bank, rng(2015)
verbose = true;

% Load the sampled dataset created in **sample_the_dataset.m**
load('data/sampled_dataset.mat')

% Trip to Explore $t \in {1,2,...,200}$
t0=2; 
t1=1;
%% Q: Number of Quantiles Parameter
% 
positive_sample = getTelematicMeasurements(positive_sample,verbose);
% QQ plot for the speed of trip t
t0_Speed = single(positive_sample.Dataset{1,t0}(:,'Speed'))*3.6;
t0_Acceleration = single(positive_sample.Dataset{1,t0}(:,'Acceleration'));
t1_Speed = single(positive_sample.Dataset{1,t1}(:,'Speed'))*3.6;

figure;

subplot(1,2,1); h0 = normplot(t0_Speed); 
hold on; h1 = normplot(t1_Speed); axis square
set(h1(1),'marker','^','markersize',2,'markeredgecolor',[0 1 0]); xlabel('KPH')
title('Speed Normal Probability Plot');

subplot(1,2,2); h3 = qqplot(t0_Speed);
hold on; h4 = qqplot(t1_Speed); axis square 
set(h3(1),'marker','^','markersize',2,'markeredgecolor',[0 1 0]); ylabel('KPH')
title('Speed QQ-Plot');

set(gcf, 'units','normalized','outerposition',[0 0 1 1]);

%% lag: Lagged Time Parameter
%
figure;
subplot(2,2,1); autocorr(t0_Speed); title(['Speed Autocorrelation of Trip ',num2str(t0)])
subplot(2,2,3); parcorr(t0_Speed); title(['Speed Partial Autocorrelation of Trip ',num2str(t0)])
subplot(2,2,2); autocorr(t0_Acceleration); title(['Acceleration Autocorrelation of Trip ',num2str(t0)])
subplot(2,2,4); parcorr(t0_Acceleration); title(['Acceleration Partial Autocorrelation of Trip ',num2str(t0)])
set(gcf, 'units','normalized','outerposition',[0 0 1 1]);



