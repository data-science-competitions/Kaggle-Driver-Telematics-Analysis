function plotSelectedTrips(trip_struct,trip_list)
%plotSelectedTrips Plots the selected trips trajectory (without the
% time dimension) specified in trip_list from trip_struct.
%   INPUT:
%   trip_struct; trip struct object created with importTripsFromFileList
%   trip_list; A vector containing the index number within trip_struct of
%   the trip to plot
Ntrips = length(trip_list(:));

for k = 1:Ntrips
    n = ceil(sqrt(Ntrips));
    m = ceil(Ntrips/n);
    subplot(m,n,k)
    ind = trip_list(k);
    X = single(trip_struct.Dataset{1,ind}(:,'X'));
    Y = single(trip_struct.Dataset{1,ind}(:,'Y'));
    X_c = (1/length(X))*sum(X);
    Y_c = (1/length(Y))*sum(Y);
    plot(X,Y,0,0,'ro',X_c,Y_c,'r+'); axis square
    title(['Trip #',num2str(ind)]);
end



end