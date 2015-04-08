%% Run Unit Test
% http://www.mathworks.com/help/matlab/matlab_prog/types-of-qualifications.html
warning('off')
slCharacterEncoding('ISO-8859-1');
runtests('unittests/test_importingTripsFunctions.m');
runtests('unittests/test_getTripsFunctions.m');
runtests('unittests/test_getTelematicMeasurements.m');


warning('on')
