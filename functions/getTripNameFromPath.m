function [trip_ID,trip_number,trip_batch] = getTripNameFromPath(trip_path)
%UNTITLED Summary of this function goes here
%   INPUT:
%   trip_path; A string of the trip
%   OUTPUT:
%   trip_ID; A string of the trip such that [trip_batch,'_',trip_number]
%   trip_number; An integer specifing the index of the trip within its batch 
%   trip_batch; An integer specifing the index of the batch 

    if (iscell(trip_path))
        trip_path = trip_path{1};
        warning('Input trip path is a cell; extracting the first cell')
    end    

    trip_path_cell   = strsplit(trip_path,'\');
    trip_number = strsplit(trip_path_cell{1,end},'.csv');
    if (iscell(trip_number)) trip_number = trip_number{1}; end    
    trip_batch  = trip_path_cell{1,end-1};
    trip_ID     = [trip_batch,'_',trip_number];
    
    trip_number = uint16(str2num(trip_number));
    trip_batch  = uint16(str2num(trip_batch));

end

