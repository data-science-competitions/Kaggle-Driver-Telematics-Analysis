function fileList = getAllFiles(dirName,verbose)
%getAllFiles returns all the pathes of the files within dirName
%
if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Get all folder paths') ; end

dirData = dir(dirName);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories
fileList = {dirData(~dirIndex).name}';  %'# Get a list of the files
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  %# Prepend path to files
        fileList,'UniformOutput',false);
end
subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
%#   that are not '.' or '..'

validSubDirs = subDirs(find(validIndex));
for k = 1:length(validSubDirs)                      %# Loop over valid subdirectories
    nextDir = fullfile(dirName,validSubDirs{k});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)]; %# Recursively call getAllFiles
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
end

if (verbose && (mod(length(fileList),500)~=0)) fprintf('\n'); end

end
