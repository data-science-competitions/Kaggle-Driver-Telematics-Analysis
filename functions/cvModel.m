function [AUC_Mean,AUC_Vec] = cvModel(X,labels,K,verbose)
%cvModel cross validation function for evaluating model AUC performance
%   INPUT:
%   X; A feature matrix, where each column correspond to a feature
%   labels; A column vector with the class of each row (observation) in X 
%   K; number of folds
%   verbose; Logical to show process in command window
%   OUTPUT:
%   AUC_Mean; The model AUC mean
%   AUC_Vec;  The model CVs' AUC 
%
learners = 'tree'; nlearners = 100;
N = size(X,1);
indices = crossvalind('Kfold', N, K);

mdl_AUC = [];

if (~exist('verbose','var')) verbose=false; end
if (verbose) fprintf('\n%% Cross Validating model'); end

startTime=datetime;

for k = 1:K
    if (verbose) fprintf('.'); end
    test = (indices == k); train = ~test;
    % Build Model
    BagModel = TreeBagger(...
        nlearners,X(train,:),labels(train,:),'method','classification',...
        'MinLeaf',10);
    % Predict
    [~,scores] = predict(BagModel,X(test,:));
    % Evaluate
    [~,~,~,mdl_AUC(k)] = perfcurve(labels(test,:),scores(:,2),1);
end
AUC_Mean = mean(mdl_AUC);
AUC_Vec = mdl_AUC;

if (verbose)
    fprintf(['\n%% Done in']);
    disp(datetime-startTime);
end

end

