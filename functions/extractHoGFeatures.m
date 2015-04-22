function [HoG_Magnitude] = extractHoGFeatures(trip_struct,NumBind,UseSignedOrientation,scale_feature,verbose)
%extractHoGFeatures extract HoG features from trips' trajectory.
%   INPUT:
%   trip_struct; A structure created by importTripsFromFileList and
%                getPhysicalMeasurements
%   NumBind; Number of orientation histogram bins. [8]
%   UseSignedOrientation; Logical specsifing selection of orientation
%                         values. [false]
%   scale_feature; Logical to normalize the matrix by rows. [false]
%   verbose; Logical to show process in command window. [false]
%   OUTPUT:
%   HoG_Magnitude; A matrix where each row correspond to an observation
%                  and each column correspond to a angle bin
%   NOTE:
%   default values are marked with [] (Brackets)
if (~exist('verbose','var')) verbose=false; end
if (~exist('scale_feature','var')) scale_feature=false; end
if (~exist('NumBind','var')) NumBind=8; end
if (~exist('UseSignedOrientation','var')) UseSignedOrientation=false; end
l = length(trip_struct.Dataset);
HoG_Magnitude = zeros(l,NumBind);

if (verbose) fprintf('\n%% Extracting HoG features'); end
tic

for k = 1:l
    X = single(trip_struct.Dataset{1,k}(:,'X'));
    Y = single(trip_struct.Dataset{1,k}(:,'Y'));
    % Angle between pair of successive points
    theta = [0;atan2(diff(Y),diff(X))];
    % Distance between pair of successive points
    rho = [0;diff(cumsum([0;sqrt(diff(X).^2+diff(Y).^2)]))];

    HoG_Magnitude(k,:) = extractHoGFeaturesKernel(...
        theta,rho,NumBind,UseSignedOrientation);
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
end

if (verbose)
    fprintf(['\n%% Extracted HoG features for ',num2str(l),...
        ' trips in ',num2str(toc),'[sec]\n']);
end

if(scale_feature) HoG_Magnitude=normr(HoG_Magnitude); end

end

