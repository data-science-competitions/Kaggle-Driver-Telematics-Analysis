function [shingle_matrix] = bindShingles(trip_structure,NumBind,UseSignedOrientation,verbose)
%bindShingles bind angle vector into bins.
%   INPUT:
%   trip_struct; A structure created by getSpatialMeasurements
%   NumBind; Number of orientation histogram bins
%   UseSignedOrientation; Selection of orientation values:
%   * [false] - [0,pi]
%   * [true]  - [-pi,pi]
%   verbose; Logical to show process in command window
%   OUTPUT:
%   shingle_matrix; A Matrix with NumBind feaures of shingles counts
%                   for each angle bin.
%
if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Binding Shingles'); end
K = size(trip_structure.Dataset,2);
shingle_matrix = zeros(K,NumBind);
tic

for k=1:K
    phi = single((trip_structure.Dataset{1,k}(:,'Shingles')));
    shingle_matrix(k,:) = bindShinglesKernel(phi,NumBind,UseSignedOrientation);
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
    clear phi
end

if (verbose)
    fprintf(['\n%% Shingled ',num2str(K),' trips ',num2str(toc),'[sec]\n']);
end

end

