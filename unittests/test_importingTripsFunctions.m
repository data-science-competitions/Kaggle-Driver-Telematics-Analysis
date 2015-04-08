function tests = test_importingTripsFunctions
tests = functiontests(localfunctions);
end


% ----------------------------------------------------------------------- %
%                           importSingleTrip                              %
% ----------------------------------------------------------------------- %
function test_importSingleTrip_class(testCase)
% Represent trip path as string
arbitrary_trip_path = './Driver-Telematics-Analysis/207/172.csv';
arbitrary_trip_dataset = importSingleTrip(arbitrary_trip_path);
% Test that the return value is of dataset type
verifyClass(testCase,arbitrary_trip_dataset,'dataset');
end

% ----------------------------------------------------------------------- %
%                        importTripsFromFileList                          %
% ----------------------------------------------------------------------- %
function test_importTripsFromFileList_class(testCase)
% Represent trip path as cell
arbitrary_trip_path = fullfile('.','Driver-Telematics-Analysis','207','172.csv');
arbitrary_trip = importTripsFromFileList(arbitrary_trip_path);
% Test that importTripsFromFileList returns a list
verifyClass(testCase,arbitrary_trip,'struct');
end

function test_importTripsFromFileList_fieldnames(testCase)
% Represent trip path as cell
arbitrary_trip_path = fullfile('.','Driver-Telematics-Analysis','207','172.csv');
arbitrary_trip = importTripsFromFileList(arbitrary_trip_path);
% Test that importTripsFromFileList contains the expected fields
arbitrary_trip_fieldnames = strjoin(fieldnames(arbitrary_trip),',');
verifySubstring(testCase,arbitrary_trip_fieldnames,'ID');
verifySubstring(testCase,arbitrary_trip_fieldnames,'Number');
verifySubstring(testCase,arbitrary_trip_fieldnames,'Batch');
verifySubstring(testCase,arbitrary_trip_fieldnames,'Dataset');
end
% ----------------------------------------------------------------------- %
