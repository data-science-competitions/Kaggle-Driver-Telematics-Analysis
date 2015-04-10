function [new_trip_structure] = getSpatialMeasurements(trip_structure,step_size,shingle_size,verbose)
%getSpatialMeasurements calculate important spatial measurements from
% the raw data
%   INPUT:
%   trip_struct; A structure created by importTripsFromFileList 
%   step_size; length of each trip steps [meters]
%   shingle_size; 
%   verbose; Logical to show process in command window
%
if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Get spatial measurements'); end
K = size(trip_structure.Dataset,2);
new_trip_structure = trip_structure;
tic
for k = 1:K
    X = single(trip_structure.Dataset{1,k}(:,{'X'}));
    Y = single(trip_structure.Dataset{1,k}(:,{'Y'}));
    % Simplifying trips 
    PointList_reduced = RDPKernel([X,Y], 'AUTO', false);
    X = PointList_reduced(:,1);
    Y = PointList_reduced(:,2);
    % Interpolating trips
    dx = diff(X);
    dy = diff(Y);
    total_length = sum(sqrt(dx.*dx+dy.*dy));
    P = interparc(linspace(0,1,ceil(total_length/step_size)),X,Y,'linear');
    X = P(:,1);
    Y = P(:,2);
    % Constructing shingles
    Shingles = atan2(Y(shingle_size+1:end),X(shingle_size+1:end))-atan2(Y(1:end-shingle_size),X(1:end-shingle_size));
    if isempty(Shingles)
        X = 0; Y = 0; Shingles = 0;
        new_trip_structure.Dataset{1,k} = dataset(X,Y,Shingles);
    else
        Shingles(1)=[];
        Shingles = [zeros(shingle_size+1,1);Shingles];
        new_trip_structure.Dataset{1,k} = dataset(X,Y,Shingles);
    end
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
    clear X Y Shingles
end

if (verbose)
    fprintf(['\n%% Simplified ',num2str(K),' trips ',num2str(toc),'[sec]\n']);
end

end

