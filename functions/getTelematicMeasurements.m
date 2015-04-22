function [new_trip_structure] = getTelematicMeasurements(trip_structure,verbose)
% getPhysicalMeasurements calculate important physical measurements from
% the raw data
%
if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Get physical measurements'); end
tic

% new_trip_structure = trip_structure;
K = size(trip_structure.Dataset,2);
new_trip_structure = trip_structure;
for k = 1:K
    % ------------------------------------------------------------------- %
    % 1. Original trajectory
    % 1.1. Get the original X,Y coordinates
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
    % 1.4. Angle between pair of successive points
    Angle = [0;atan2(diff(Y),diff(X))];
    % 1.5. Calculate trip speed [m/s]
    Speed = [0;sqrt(diff(X).^2+diff(Y).^2)];
    % 1.6. Calculate trip acceleration [m/s^2]
    Acceleration = [0;diff(Speed)];
    % 1.7. Calculate trip distance [m]
    Distance = cumsum(Speed);
    % 1.8. Distance between pair of successive points
%     dDistance = [0;diff(Distance)];
    % ------------------------------------------------------------------- %
    % 3. Store results
    new_trip_structure.Dataset{1,k} = ...
        dataset(...
        X, Y, Speed, Acceleration, Distance, Angle);
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
end

if (verbose)
    fprintf(['\n%% Calculated physical measurements for ',num2str(K),...
        ' trips in ',num2str(toc),'[sec]\n']);
end

end

