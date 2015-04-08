function [Speed_Quantiles] = extractSpeedQuantiles(trip_struct,Q,verbose)
%extractSpeedQuantiles extract Q quantiles from trip structure
%   INPUT:
%   trip_struct; A structure created by importTripsFromFileList and 
%   getPhysicalMeasurements
%   Q; Number of quantiles to extract
%   verbose; Logical to show process in command window
%   OUTPUT:
%   Speed_Quantiles; Matrix where each row correspond to an observation,
%   and each col correspond to a quantiles
%
if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Extract speed quantiles'); end
tic

K = size(trip_struct.Dataset,2);
Speed_Quantiles = zeros(K,Q);

for k = 1:K
    Speed_Quantiles(k,1:Q) = quantile(...
        single(trip_struct.Dataset{1,k}(:,'Speed')),linspace(0,1,Q));
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
end

if (verbose)
    fprintf(['\n%% Extracted speed quantiles for ',num2str(K),...
        ' trips in ',num2str(toc),'[sec]\n']);
end

end

