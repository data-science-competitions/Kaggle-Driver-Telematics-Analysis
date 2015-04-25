function plotAXA(plot_type,trip_struct,trip_indices,varargin)
%plotAXA Plots a verity of plots for the AXA data
%   INPUT:
%   plot_type; one of the following:
%   * 'trajectories': trips trajectories.
%   * 'roses': trips HoG compasses.
%   * 'guns and roses': trips trajectories and HoG compasses.
%   trip_struct; trip struct object created with importTripsFromFileList.
%   trip_indices; A vector containing the index number within trip_struct
%   of the trip to plot.
%   varargin; additional input arguments for te selected plot type:
%   * 'trajectories': Nothing
%   * 'roses':
%       + NumBind; Number of orientation histogram bins.
%       + UseSignedOrientation; Logical specifying selection of orientation values.
%   * 'guns and roses': same input argument as in 'roses'.

plot_type = lower(plot_type);
switch plot_type
    case 'trajectories'
        plotSeveralTrips(trip_struct,trip_indices);
    case 'roses'
        if (length(varargin)~=2)
            error('Please supply NumBind and UseSignedOrientation arguments')
        end
        NumBind = varargin{1};
        UseSignedOrientation = varargin{2};
        plotTripsHoGCompasses(trip_struct,trip_indices,NumBind,UseSignedOrientation);
    case 'guns and roses'
        if (length(varargin)~=2)
            error('Please supply NumBind and UseSignedOrientation arguments')
        end
        NumBind = varargin{1};
        UseSignedOrientation = varargin{2};
        plotTripsHoG(trip_struct,trip_indices,NumBind,UseSignedOrientation);
    otherwise
        disp('unknown plot')
end

end



% ----------------------------------------------------------------------- %
% plotSeveralTrips
% ----------------------------------------------------------------------- %
function plotSeveralTrips(trip_struct,trip_list)

Ntrips = length(trip_list(:));
Nalltrips = length(trip_struct.Dataset);

subplot(1,3,1)
for k=1:Nalltrips
    angle_shift = ((2*pi)./Nalltrips)*(k-1);
    X     = single(trip_struct.Dataset{1,k}(:,'X'));
    Y     = single(trip_struct.Dataset{1,k}(:,'Y'));
    rho   = sqrt(X.*X+Y.*Y);
    theta = atan2(Y,X);
    plot(rho.*cos(theta+angle_shift),rho.*sin(theta+angle_shift))
    hold on
end
axis square; title('All Trips')

subplot(1,3,2)
for k=1:Nalltrips
    if any(k==trip_list)
        angle_shift = ((2*pi)./Nalltrips)*(k-1);
        X     = single(trip_struct.Dataset{1,k}(:,'X'));
        Y     = single(trip_struct.Dataset{1,k}(:,'Y'));
        rho   = sqrt(X.*X+Y.*Y);
        theta = atan2(Y,X);
        plot(rho.*cos(theta+angle_shift),rho.*sin(theta+angle_shift))
        h=text(double(rho(end)*cos(theta(end)+angle_shift)),...
            double(rho(end)*sin(theta(end)+angle_shift)),num2str(k),...
            'HorizontalAlignment','Center');
        set(h,'Clipping','on')
        hold on
    end
end
line([0,0],ylim,'Color','k'); line(xlim,[0,0],'Color','k');
axis square; title('Selected Trips'); grid off

subplot(1,3,3)
for k=1:Nalltrips
    if any(k==trip_list)
        angle_shift = 0;
        X     = single(trip_struct.Dataset{1,k}(:,'X'));
        Y     = single(trip_struct.Dataset{1,k}(:,'Y'));
        rho   = sqrt(X.*X+Y.*Y);
        theta = atan2(Y,X);
        plot(rho.*cos(theta+angle_shift),rho.*sin(theta+angle_shift))
        hold on
    end
end
axis square; title('Rotated Selected Trips'); grid on

end

% ----------------------------------------------------------------------- %
% plotTripsHoGCompasses
% ----------------------------------------------------------------------- %
function plotTripsHoGCompasses(trip_struct,trip_list,NumBind,UseSignedOrientation)
%plotTripsHoGCompasses Plots trips compasses
%   INPUT:
%   NumBind; Number of orientation histogram bins.
%   UseSignedOrientation; Logical specifying selection of orientation values.
%
% if (~exist('NumBind','var')) NumBind=8; end
% if (~exist('UseSignedOrientation','var')) UseSignedOrientation=false; end
Ntrips = length(trip_list(:));

for k = 1:Ntrips
    n = ceil(sqrt(Ntrips));
    m = ceil(Ntrips/n);
    ind = trip_list(k);
    X     = single(trip_struct.Dataset{1,ind}(:,'X'));
    Y     = single(trip_struct.Dataset{1,ind}(:,'Y'));
    % Angle between pair of successive points
    theta = [0;atan2(diff(Y),diff(X))];
    % Distance between pair of successive points
    rho = [0;diff(cumsum([0;sqrt(diff(X).^2+diff(Y).^2)]))];
    %%% Get HoG Features
    [HoG_Magnitude,HoG_Phase,HoG_Labels] = extractHoGFeaturesKernel(...
        theta,rho,NumBind,UseSignedOrientation);
    %%% Plot Trip Campass
    subplot(m,n,k)
    z = HoG_Magnitude.*(cos(HoG_Phase)+i*sin(HoG_Phase));
    h1 = compass(z);
    %%% Change Plots attributes
    cmap = hsv(NumBind);
    set(h1, {'Color'},num2cell(cmap,2),'LineWidth',2);
    title(['Trip #',num2str(ind)]);
end


end

% ----------------------------------------------------------------------- %
% plotTripsHoG
% ----------------------------------------------------------------------- %
function plotTripsHoG(trip_struct,trip_list,NumBind,UseSignedOrientation)
%plotTripsHoGCompasses Plots trips compasses
%   INPUT:
%   NumBind; Number of orientation histogram bins.
%   UseSignedOrientation; Logical specifying selection of orientation values.

Ntrips = length(trip_list(:));

for k = 1:Ntrips
    n = 2*ceil(sqrt(Ntrips));
    m = ceil(2*Ntrips/n);
    ind = trip_list(k);
    X     = single(trip_struct.Dataset{1,ind}(:,'X'));
    Y     = single(trip_struct.Dataset{1,ind}(:,'Y'));
    % Angle between pair of successive points
    theta = [0;atan2(diff(Y),diff(X))];
    % Distance between pair of successive points
    rho = [0;diff(cumsum([0;sqrt(diff(X).^2+diff(Y).^2)]))];
    %%% Get HoG Features
    [HoG_Magnitude,HoG_Phase,HoG_Labels] = extractHoGFeaturesKernel(...
        theta,rho,NumBind,UseSignedOrientation);
    %%% Plot Trip Campass
    subplot(m,n,2*k-1)
    z = HoG_Magnitude.*(cos(HoG_Phase)+i*sin(HoG_Phase));
    h1 = compass(z);
    cmap = hsv(NumBind);
    set(h1, {'Color'},num2cell(cmap,2),'LineWidth',2);
    title(['Trip #',num2str(ind)]);
    %%% Plot Trip Trajectory
    subplot(m,n,2*k)
    for c=1:length(X)-1
        plot([X(c),X(c+1)],[Y(c),Y(c+1)],'Color',cmap(HoG_Labels(c+1),:));
        hold on
    end
    legend('off')
    
    title(['Trip #',num2str(ind)]); axis square
end


end
