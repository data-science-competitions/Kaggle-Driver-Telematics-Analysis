function [HoG_Magnitude,HoG_Phase,HoG_Labels] = extractHoGFeaturesKernel(theta,rho,NumBind,UseSignedOrientation)
%extractHoGFeaturesKernel extract HoG features from 2 vectors: direction
%and length.
%   INPUT:
%   theta; A vector of angles (in rad) between pairs of successive points
%   rho; A vector of distances between pairs of successive points
%   NumBind; Number of orientation histogram bins [8]
%   UseSignedOrientation; Selection of orientation values [false]
%   OUTPUT:
%   HoG_Magnitude; Row vector of size NumBind
%   HoG_Phase; The corresponding angles (in rad) for HoG_Magnitude
%   HoG_labels; Col vector of the labels for each observation in theta
%   NOTE:
%   default values are marked with [] (Brackets)
%

%% Initialization
%
if (~exist('NumBind','var')) NumBind=8; end
if (~exist('UseSignedOrientation','var')) UseSignedOrientation=false; end
HoG_Magnitude = zeros(1,NumBind);
HoG_Labels = ones(length(theta),1);

%% Spatial/Orientation Binning
%
if UseSignedOrientation
    theta = theta;
    angleBins = linspace(-pi,pi,NumBind+1);
    HoG_Phase = linspace(-pi,pi,NumBind+1);
    HoG_Phase(1)=[];
else
    theta = abs(theta);
    angleBins = linspace(0,pi,NumBind+1);
    HoG_Phase = linspace(0,pi,NumBind+1);
    HoG_Phase(1)=[];
end

for k=2:NumBind
    HoG_Labels(theta>angleBins(k)) = k;
end

for k=1:NumBind
    HoG_Magnitude(k) = sum(rho(HoG_Labels==k));
end

HoG_Magnitude = single(HoG_Magnitude);
HoG_Phase = single(HoG_Phase);
HoG_Labels = single(HoG_Labels);
end

