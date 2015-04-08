function tests = test_getTelematicMeasurements
tests = functiontests(localfunctions);
end

% ----------------------------------------------------------------------- %
%                        getTelematicMeasurements                         %
% ----------------------------------------------------------------------- %
function test_getTelematicMeasurements_fields(testCase)
trip_172_path = fullfile('.','Driver-Telematics-Analysis','207','172.csv');
trip_172 = importTripsFromFileList(trip_172_path);
trip_172 = getTelematicMeasurements(trip_172);
% Test that importTripsFromFileList contains the expected fields
arbitrary_trip_datasetcolnames = ...
    strjoin(get(trip_172.Dataset{1,1},'VarNames'),',');
verifySubstring(testCase,arbitrary_trip_datasetcolnames,'X');
verifySubstring(testCase,arbitrary_trip_datasetcolnames,'Y');
verifySubstring(testCase,arbitrary_trip_datasetcolnames,'Speed');
verifySubstring(testCase,arbitrary_trip_datasetcolnames,'Acceleration');
verifySubstring(testCase,arbitrary_trip_datasetcolnames,'Distance');
verifySubstring(testCase,arbitrary_trip_datasetcolnames,'Angle');
end

