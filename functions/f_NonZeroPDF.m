function [pdf_nonzero] = f_NonZeroPDF(histogram)
% Returns a pdf from a histogram where all bins have non-zero probabilities
% Method
% - For each bin, its nonzero bin occupation probability is estimated 
%   as the mean of the confidence interval for p_i based on the binominal distribution.
%   These confidence intervals will become narrower the larger the total counts in histogram
% Input
% - histogram: [1,n] array with bin occupation frequencies (positive integers >=0)
%   Note: histogram has to be NaN-free
% Output
% - pdf_nonzero: [1,n] array with nonzero bin occupation probability (strictly positive)
% Version
% 2017/10/26 Uwe Ehret, initial version

% check if histogram is NaN-free
if ~isempty(find(isnan(histogram)))
    error('histogram contains NaNs')
end

% get the total number of counts in the histogram
num_counts = sum(histogram);

% for each bin, compute the confidence interval of its bin occuptation probability, provided as upper and lower value of 95% confidence interval 
[~,CI] = binofit(histogram,num_counts); 

% the non-zero bin occupation probability is the mean of the confidence interval
pdf_nonzero = mean(CI,2);

% as pdf_nonzero = mean(CI,2) does not assure sum(pdf_nonzero)=1, do so by diving with the sum
pdf_nonzero = pdf_nonzero'/sum(pdf_nonzero);       

end