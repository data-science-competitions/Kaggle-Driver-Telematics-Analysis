function tests = test_getTripsFunctions
tests = functiontests(localfunctions);
end

% ----------------------------------------------------------------------- %
%                              getAllFiles                                %
% ----------------------------------------------------------------------- %
function test_getAllFiles_class(testCase)
% Represent trip path as string
dataset_path = '.\Driver-Telematics-Analysis';
arbitrary_trip_path = fullfile('.','Driver-Telematics-Analysis','207','172.csv');
fileList = getAllFiles(dataset_path);
% Test that getAllFiles returns cell type
verifyClass(testCase,fileList,'cell')
end

function test_getAllFiles_filespaths(testCase)
% Represent trip path as string
dataset_path = '.\Driver-Telematics-Analysis';
arbitrary_trip_path = fullfile('.','Driver-Telematics-Analysis','207','172.csv');
fileList = getAllFiles(dataset_path);
% Test that getAllFiles returns files paths
verifyEqual(testCase,strmatch(arbitrary_trip_path,fileList),1);
end

% ----------------------------------------------------------------------- %
%                         getTripNameFromPath                             %
% ----------------------------------------------------------------------- %
function test_getTripNameFromPath_class(testCase)
% Represent trip path as string
arbitrary_trip_path = fullfile('.','Driver-Telematics-Analysis','207','172.csv');
[t_ID,t_number,t_batch] = getTripNameFromPath(arbitrary_trip_path);
% Test that getAllFiles returns files paths
verifyClass(testCase,t_ID,'char')
verifyClass(testCase,t_number,'uint16')
verifyClass(testCase,t_batch,'uint16')
end
% ----------------------------------------------------------------------- %


