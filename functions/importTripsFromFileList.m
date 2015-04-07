function [trip_bundle] = importTripsFromFileList(fileList,verbose)
%importTripsFromFileList returns all the driven trips in a specified file list.
%   INPUT:
%   * fileList; A cell array of K file paths.
%   OUTPUT:
%   * A; A cell arrat of size Kx3, such that:
%        A{k,1} Reserve for the file ID
%        A{k,2} contains the k's trip x and y coordinates
%        A{k,3} contains the k's trip batch
%        A{k,4} contains the k's trip name
%

if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Importing trip from file list') ; end
if (ischar(fileList)) fileList={fileList}; end

% warning('off')
tic
K = length(fileList);
trip_bundle = struct();

for k = 1:K
    % Import trip
    arbitrary_trip_dataset = importSingleTrip(fileList{k,1});
    % Extract trip's name
    [arbitrary_trip_ID,arbitrary_trip_number,arbitrary_trip_batch] = ...
        getTripNameFromPath(fileList{k,1});
    % Save the trip's data in the bundle
    trip_bundle.ID{k}      = arbitrary_trip_ID;
    trip_bundle.Number{k}  = arbitrary_trip_number;
    trip_bundle.Batch{k}   = arbitrary_trip_batch;
    trip_bundle.Dataset{k} = arbitrary_trip_dataset;
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
end

if (verbose)
    fprintf(['\n%% Imported ',num2str(K),' trips in ',...
        num2str(toc),'[sec]\n']);
end

end
