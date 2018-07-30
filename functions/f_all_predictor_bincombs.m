function [combis] = f_all_predictor_bincombs(num_bins)
% Creates an array of all possible predictor bin combinations
% Input
% - num_bins: [1,n] array, where for each dimension the number of bins is given
%   Note: The first entry is for the target, which will be ignored later
%   as we just need the number of predictor combinations
% Output
% - combis: [num_combis,num_dim-1] array with all possible bin number
%   combinations across all predictors
% Version
% - 2017/10/22 Uwe Ehret: initial version

% number of dimensions of the target-predictor matrix
num_dim = size(num_bins,2); 

% check the number of dimensions (at least one predictor, i.e. num_dim min 2)
if num_dim < 2
    error('num_dim too small');
end

% initialze cell array with all possible bin numbers for each dimension
mycell = cell(1,num_dim);

% loop over all dimensions of the target-predictor matrix
for d = 1 : num_dim
    % write an array with all possible bin numbers for target and all predictors
    mycell{d} = (1:num_bins(d)); 
end

% Delete the first entry of the cell (the target bins)
mycell(1) = []; 

% create all possible combinations of predictor bin numbers
combis = allcomb_singleinput(mycell); 

end

