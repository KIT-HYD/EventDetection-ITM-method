function [ KLD ] =f_kld(pdf,pdf_star)
% computes the Kullback-Leibler divergence between two distributions. 
% Note 
% - it is non-symmetrical!
% - based on http://www.mathworks.com/matlabcentral/fileexchange/13089-kldiv/content/kldiv.m, version 18.10.2013
% Input
% - pdf: [n,1] or [1,n] vector of probabilities representing the reference distribution (the 'truth')
% - pdf_star: [n,1] or [1,n] vector of probabilities representing the other distribution (the 'estimate')
%   Note
%   - pdf and pdf_star must have the same dimension
%   - The elements of pdf and pdf_star must each sum to 1 +/- .00001.
%   - All elements of pdf_star must be non-zero 
%   - In pdf, zero values are allowed (divergence in this case will be 0)
%   - In pdf_star 
%     - zero values are allowed where pdf is also zero (divergence in this case will be 0)
%     - zero values where pdf is NOT zero throw an error (divergence in this case would be infinite)
% Output
% - KLD: [1,1] Kullback-Leibler-divergence in [bit]
% Version
% - 2017/10/24 Uwe Ehret: handle the case of NaN's in the input
% - 2016/06/24 Uwe Ehret: intial version

% check if there are NaNs in 'pdf'
if ~isempty(find(isnan(pdf)))
    KLD = NaN;
    return;
end

% check if there are NaNs in 'pdf_star'
if ~isempty(find(isnan(pdf_star)))
    KLD = NaN;
    return;
end

% check for equal input dimensions
if ~isequal(size(pdf),size(pdf_star))
    error('All inputs must have same dimension.')
end

% check probabilities in 'pdf' sum to 1
if abs(sum(pdf) - 1) > .00001
    error('Probablities in pdf dont sum to 1.')
end

% check probabilities in 'pdf_star' sum to 1
if abs(sum(pdf_star) - 1) > .00001
    error('Probablities in pdf_star dont sum to 1.')
end

% check for zero values in pdf_star where pdf is non-zero
if ~isempty(intersect(find(pdf_star == 0), find(pdf ~= 0)))
    error('there are zero probabilities in pdf_star where pdf is non-zero');
end

% initialize the output variable
KLD = 0;

% loop over all bins
for i = 1 : length(pdf)
    if pdf(i) == 0 
        KLD = KLD;
    else
        KLD = KLD + ((log2(pdf(i)) - log2(pdf_star(i)))*pdf(i));
    end 
end

end
