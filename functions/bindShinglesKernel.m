function [shingle_count] = bindShinglesKernel(phi,NumBind,UseSignedOrientation)
%bindShinglesKernel bind angle vector into bins.
%   INPUT:
%   phi; A vector of angles (in rad)
%   NumBind; Number of orientation histogram bins
%   UseSignedOrientation; Selection of orientation values:
%   * [false] - [0,pi]
%   * [true]  - [-pi,pi]
%   OUTPUT:
%   shingle_count; A vector of length NumBind with counts of shingles
%                  in each angle bin.
%
if UseSignedOrientation
    phi = phi;
    angleBins = linspace(-pi,pi,NumBind);
else
    phi = abs(phi);
    angleBins = linspace(0,pi,NumBind);
end
shingle_type = ones(NumBind,1);
for k=2:NumBind
    shingle_type(phi>angleBins(k)) = k;
end
shingle_count = zeros(NumBind,1);
for k=1:NumBind
    shingle_count(k) = sum(shingle_type==k);
end

end

