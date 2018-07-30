function [ KLD ] = f_conditionalkld_anyd( histograms, histograms_hat)
% Returns the expected KLD over a set of histogram pairs (reference and estimate)
% The set is typically the set of all conditional target histograms for all
% possible combinations of predictors
% Input
% - histograms: [num_p_combis,num_bins] array of reference histograms (one per row)
% - histograms_hat: [num_p_combis,num_bins] array of estimated histograms (one per row)
%   Note: 
%   - Input has to be NaN-free
% Output
% - KLD: [1,1] expected KLD over all histogram pairs
% Version
% - 2017/11/24: Uwe Ehret, addition (# 2017/11/24, UE: start of change)
%               In the case that pdf_ref is non-empty, but pdf_hat is,
%               replaces pdf_hat by its nonzero estimate.
% - 2017/10/24: Uwe Ehret, initial version

% check if histograms is NaN-free
if ~isempty(find(isnan(histograms)))
    error('histograms contains NaNs')
end

% check if histograms_hat is NaN-free
if ~isempty(find(isnan(histograms_hat)))
    error('histograms_hat contains NaNs')
end

% get dimensions
num_p_combis = size(histograms,1); % number of possible predictor combinations = number of histograms

% initialize variables

    % array with KLD for each histogram pair
    KLD_temp = NaN(num_p_combis,1); 

    % marginal frequency of the particular predictor combination
    % Note: This is the frequency of the reference, as this will be the true occurence of this predictor combination
    num_temp = sum(histograms,2); 

% loop over all particular predictor combinations
for c = 1 : num_p_combis
    
    % get reference pdf by dividing its histogram with the total number of counts
    hist_ref = histograms(c,:);
    pdf_ref = hist_ref / sum(hist_ref);
    % Note: 
    % - If hist_ref is completly empty, division with sum(hist_ref) = 0 yields pdf_ref = NaN
    %   In this case, KLD_temp(c) will be NaN
    % - If hist_ref contains some zeros, this is no problem to compute DKL. So there is no need to check that
    
    % get estimate pdf by dividing its histogram with the total number of counts
    hist_hat = histograms_hat(c,:);
    pdf_hat = hist_hat / sum(hist_hat);
    % Note: 
    % - If hist_hat is completly empty, division with sum(hist_hat) = 0 yields pdf_hat = NaN
    %   In this case, KLD_temp(c) will be NaN
    
    % # 2017/11/24, UE: start of change
    % check if pdf_ref is NOT completely empty, but pdf_hat is. This case
    % means that the model has no answer on a situation observed in the
    % reference. As we should ensure an answer, give the maxEnt answer here
    % (a uniform distribution).
    % Note that the opposite case (pdf_ref is empty, pdf_hat not) is no
    % problem. It just means that the model has an answer on a situatiion
    % that never occurs in the reference.
    if (sum(hist_ref) > 0) && (sum(hist_hat)==0)
        pdf_hat = f_NonZeroPDF(hist_hat);
    end
    % # 2017/11/24, UE: end of change
    
    % check for zero values in pdf_hat where pdf is non-zero
    % If this is the case, replace pdf_hat with its non-zero estimate
    if ~isempty(intersect(find(pdf_hat == 0), find(pdf_ref ~= 0)))
        pdf_hat = f_NonZeroPDF(hist_hat);
    end
    
    % finally, compute DKL
    KLD_temp(c) = f_kld(pdf_ref,pdf_hat);     
end

% convert the reference marginal frequencies to marginal probabilities 
num_temp = num_temp / sum(num_temp);

% compute total conditional KLD as expected values of all particular KLDs
KLD = nansum(num_temp .* KLD_temp); 
% Note this requires 'nansum' instead of 'sum', as KLD_temp = NaN for all
% estimate histograms with no data at all. 

end

