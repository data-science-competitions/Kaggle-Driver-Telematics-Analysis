function [new_trip_structure] = getSpatialMeasurements(trip_structure,verbose)
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
    % 1.3. Rotate the trajectories with respect to the centroid mean
    X_c = (1/length(X))*sum(X);
    Y_c = (1/length(Y))*sum(Y);
    phi = atan2(Y,X);
    r   = sqrt(X.*X+Y.*Y);
    phi_c = atan2(Y_c,X_c);
    X = r.*cos(phi-phi_c);
    Y = r.*sin(phi-phi_c);
    % Simplifying trips
    PointList_reduced = RDPKernel([X,Y], 'AUTO', false);
    X = PointList_reduced(:,1);
    Y = PointList_reduced(:,2);
    new_trip_structure.Dataset{1,k} = dataset(X,Y);
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
    clear X Y %Shingles
end

if (verbose)
    fprintf(['\n%% Simplified ',num2str(K),' trips ',num2str(toc),'[sec]\n']);
end

end

