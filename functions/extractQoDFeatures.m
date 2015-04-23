function [M] = extractQoDFeatures(trip_struct,var_names,lag,Q,remove_zeros,verbose)
% extractQoDFeaturesKernel extract the quantiles values over lagged time
% derivative vector. 
%   INPUT:
%   trip_struct; A structure created by importTripsFromFileList and
%                getPhysicalMeasurements.
%   var_names; A cell of strings with the names of the variables to extract.
%   lag; scalar or vector of lag value. If lag=0, the function returns the
%   feature quantiles.
%   Q; number of quantiles to extract.
%   remove_zeros; Logical to ignore zeros from the calculation that is:
%                 if a<|eps|; eps=0.001 then a = []. [false]
%   verbose; Logical to show process in command window. [false]
%   OUTPUT:
%   M; Feature Matrix [nxq*lag*var_names].

%% Initialization
%
if (~exist('verbose','var')) verbose=false; end
if (~exist('remove_zeros','var')) remove_zeros=false; end

if (verbose) fprintf('\n%% Extracting QoD features'); end

tic
l = length(lag);
s = size(var_names,2);
d = length(trip_struct.Dataset);

%% Extrac Features
%
M = zeros(d,l*Q*s);
for k=1:d
    F = [];
    for vnames = var_names
        V = single(trip_struct.Dataset{1,k}(:,vnames));
        D = extractQoDFeaturesKernel(V,lag,Q,remove_zeros);
        F = [F,D];
    end
    M(k,:) = F;
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
end

if (verbose)
    fprintf(['\n%% Extracted QoD features for ',num2str(d),...
        ' trips in ',num2str(toc),'[sec]\n']);
end

M = single(M);
end

