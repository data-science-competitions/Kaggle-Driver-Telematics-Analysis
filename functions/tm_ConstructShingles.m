function [new_trip_structure] = tm_ConstructShingles(trip_structure,stride,verbose)

if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Get spatial measurements'); end
K = size(trip_structure.Dataset,2);
new_trip_structure = trip_structure;
tic
for k = 1:K
    X = single(trip_structure.Dataset{1,k}(:,{'X'}));
    Y = single(trip_structure.Dataset{1,k}(:,{'Y'}));
    % Construct Shingles
    Shingles = atan2(Y(stride+1:end),X(stride+1:end))-atan2(Y(1:end-stride),X(1:end-stride));
    if isempty(Shingles)
        X = 0; Y = 0; Shingles = 0;
        new_trip_structure.Dataset{1,k} = dataset(X,Y,Shingles);
    else
        Shingles(1)=[];
        Shingles = [zeros(stride+1,1);Shingles];
        new_trip_structure.Dataset{1,k} = dataset(X,Y,Shingles);
    end
    if (verbose && (k==1)) fprintf('\n'); end
    if (verbose && (mod(k,10)==0)) fprintf('.'); end
    if (verbose && (mod(k,100)==0)) fprintf('%4d',k); end
    if (verbose && (mod(k,500)==0)) fprintf('\n'); end
    clear X Y Shingles
end

if (verbose)
    fprintf(['\n%% Constructed Shingles for',num2str(K),' trips ',num2str(toc),'[sec]\n']);
end

end
