function [F] = extractQoDFeaturesKernel(V,lag,Q,remove_zeros)
% extractQoDFeaturesKernel extract the quantiles values over lagged time
% derivative vector. 
%   INPUT:
%   V; A vector of time series measurements.
%   lag; scalar or vector of lag value.
%   Q; number of quantiles to extract.
%   remove_zeros; Logical to ignore zeros from the calculation that is:
%                 if a<|eps|; eps=0.001 then a = []. [false]
%   OUTPUT:
%   F; Feature vector [1xq*lag], [lag1vector,...,lagjvector,...,lagkvector]
%   where lagjvector = [q_1,...,q_Q].

%% Initialization
%
if (~exist('remove_zeros','var')) remove_zeros=false; end

%% Calculation
%

l = length(lag);
F = zeros(1,l*Q);
for k=1:l
    % Create matrix of lagged time series
    if (lag(k)~=0)
        A = V(:) - lagmatrix(V(:), lag(k));
        A(1:lag(k))=0; % First element
    else
        A = V(:);
    end
    % Remove zeros
    if remove_zeros
        espilon = 0.001;
        A(find(abs(A)<espilon))=[];
        if isempty(A)
            A = zeros(1,Q);
        end
    end
    % Calculate quantiles
    F(1,(k-1)*Q+1:k*Q) = quantile(A,linspace(0,1,Q));
    
    clear A
end
% F(1,:) = []; % remove zero quantile
F = single(F);
end

