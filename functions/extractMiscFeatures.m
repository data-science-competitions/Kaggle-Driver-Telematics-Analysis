function [Misc_Features] = extractMiscFeatures(trip_struct,verbose)
%extractMiscFeatures extract miscellaneous features from the data
%   INPUT:
%   trip_struct; A structure created by importTripsFromFileList and
%   getPhysicalMeasurements
%   scale_feature; Logical to normalize the matrix by cols. [false]
%   verbose; Logical to show process in command window
%   OUTPUT:
%   Misc_Features; Matrix where each row correspond to an observation,
%   and each col correspond to a feature
%
if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Extracting miscellaneous features\n'); end

Nfeaturs = 20;
K = size(trip_struct.Dataset,2);
Misc_Features = single(zeros(K,Nfeaturs));
tic

for k = 1:K
    %% Load Variables
    X = single(trip_struct.Dataset{1,k}(:,'X'));
    Y = single(trip_struct.Dataset{1,k}(:,'Y'));
    phi = atan2(Y,X);
    angle = [0;atan2(diff(Y),diff(X))];
    %% Feature 1: Sum of Angles Shift of the Trip
    Misc_Features(k,1) = sum(abs([0;diff(phi)]));
    Misc_Features(k,2) = sum(abs([0;angle]));
    %% Feature 3: Total Trip Distance
    Distance = cumsum([0;sqrt(diff(X).^2+diff(Y).^2)]);
    Misc_Features(k,3) = Distance(end);
    %% Feature 4: Number of Steps/Total Trip Distance
    Misc_Features(k,4) = length(X)./Misc_Features(k,3);
    %% Feature 5: Centroid mean
    Misc_Features(k,5) = (1/length(X))*sum(X);
    %% Feature 6: Angle Variance 
    Misc_Features(k,6) = var(phi);
    %% Feature 7: Last Coordinate Record
    Misc_Features(k,7:8) = [X(end),Y(end)];
    
    %% Status
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
end
% End zeros columns
Misc_Features(:,~any(Misc_Features,1)) = [];
if (verbose)
    fprintf(['\n%% Extracted misc features for ',num2str(k),...
        ' trips in ',num2str(toc),'[sec]\n']);
end
end

