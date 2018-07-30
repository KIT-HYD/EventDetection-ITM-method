function [Hcond, target_hist_p_combis] = f_conditionalentropy_anyd(data_histcounts, p_combis)
% Computes the conditional entropy of a target variable given any number of predictors >= 1
% i.e. there must be at least one predictor
% Input
% - data_histcounts: [num_bins of dim 1, num_bins of dim 2, ... , num_bins of dim end]
%   matrix, with 'dim 1' being the target, and 'dim 2' ... 'dim end' being the predictors
%   with counts of occurrency of the particular target/predictors combination
% - p_combis: [num_p_combis, num_dim -1] array with all possible bin number combinations (rows) of all predictors (columns) in data_histcounts
%   Note this excludes the first dimension in data_histcounts, as this is the target
% Note: Both data_histcounts and p_combis must be NaN-free
% Output
% - Hcond: [1,1] with conditional entropy in [bit]
% - target_hist_p_combis: [num_p_combis,num_target_bins] target histogram for each particular predictor combination
%   Note the order along the first dimension is the same as in p_combis
% Version
% - 2017/10/31 Uwe Ehret: included call to f_conditional_histogram
% - 2017/10/22 Uwe Ehret: initial version

% check if data_histcounts is NaN-free
if ~isempty(find(isnan(data_histcounts)))
    error('data_histcounts contains NaNs')
end

% check if p_combis is NaN-free
if ~isempty(find(isnan(p_combis)))
    error('p_combis contains NaNs')
end

% get dimensions
num_p_combis = size(p_combis,1); % number of possible predictor combinations
num_pred = size(p_combis,2); % number of predictors
num_target_bins = size(data_histcounts,1); % number of target bins

% initialize arrays for all conditional distributions
H_temp = NaN(num_p_combis,1); % target entropy for each particular predictor combination
num_temp = NaN(num_p_combis,1); % number of target values for each particular predictor combination (marginal predictor frequency)
target_hist_p_combis = NaN(num_p_combis,num_target_bins); % the target histogram for each particular predictor combination

% loop over all particular predictor combinations
for c = 1 : num_p_combis
    
    % get the current predictor combination
    predictor_vals = p_combis(c,:);
    
    % with the current predictor combination, extract the conditional target histogram
    target_hist_temp = f_conditional_histogram(predictor_vals,data_histcounts);
    
    % copy the histogram to the container variable
    target_hist_p_combis(c,:) = target_hist_temp;
    
    % find the marginal frequency of the particular predictor combination
    num_temp(c) = sum(target_hist_temp); 
    
    % get conditional target pdf by dividing its histogram with its frequency
    % Note: If the marginal frequency = 0, this means division by 0, which leads to a pdf filled with NaNs
    target_pdf_temp = target_hist_temp / sum(target_hist_temp);
    
    % compute the conditional entropy
    % Note: For a pdf filled with NaNs, this returns NaN
    H_temp(c) = f_entropy(target_pdf_temp); 

end

% convert the marginal frequencies to marginal probabilities 
num_temp = num_temp / sum(num_temp);

% compute total conditional entropy as expected value of all particular conditional entropies
Hcond = nansum(num_temp .* H_temp); 
% Note this requires 'nansum' instead of 'sum', as Hs_temp(c) = NaN for all
% conditional histograms with no data at all. 
    
end

