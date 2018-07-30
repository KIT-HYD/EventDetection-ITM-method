% Program to define the binning for all variables included in event analysis and prediction

% Conditions
% - all series must be evenly spaced, gapfree and NaN-free
% - make sure that the chosen binning range cover all data, even those in a potential application
% - to assure comparability, all binning should be uniformly spaced. 
%   But deviations from this are possible, if e.g. a huge dimensionality for
%   combinations of many predictors needs to be avoided

% Input
% - variables provided in output_events_prepare.mat

% Output
% variables with n+1 edges for n bins (e.g. for 2 bins, with [0,1] as central values of the bins, it will be 3 edges [-0.5, 0.5, 1.5])
% - edges_q: applicable for q, qplus1, qplus2, qminus1, qminus2
% - edges_logq: applicable for logq, logqplus1, logqplus2, logqminus1, logqminus2
% - edges_p: applicable for p
% - edges_event: applicable for event
% - edges_rm: applicable for rm, rml, rmr
% - edges_qslope2: applicable for qslope_after, qslope_before
% - edges_eminus1: applicable for the recursive predictor peminus1

% Version
% - 2017/10/19: UE, initial version

clear all
close all
clc

%% load data
load output_events_prepare

%% choose a variable to be analyzed
% - q: binning will also be used for qplus1, qplus2
% - logq: binning will also be used for logqplus1, logqplus2
% - p: binning will only be used for p

var = p;

min(var) % plot the min value
max(var) % plot the max value

%% iteratively choose bin range and width
% Note: chosen binning range has to cover all data, even those in a potential application

% choose outermost bin centers and binwidth
center_left = -0; % center of leftmost bin
center_right = 30; % center of rightmost bin
binwidth = 1; % binwidth

% compute bin edges
mini = center_left-0.5*binwidth;   % leftmost bin edge
maxi = center_right+0.5*binwidth;   % rightmost bin edge
numbins = 1+(center_right-center_left)/binwidth;   % number of bins
edges = linspace(mini,maxi,numbins+1);
    
% compute the pdf
% Note: the p's in the pdf are relative to ALL values in vals_x (even
% if they are NaN or outside the bin range --> erase all NaNs before
% and make sure the bin range covers all data
[pdf,edges] = histcounts(var,edges,'Normalization', 'probability');
    
% check probabilities sum to 1
if abs(sum(pdf) - 1) > .00001
    error('Probablities dont sum to 1.')
end
    
% plot the pdf
figure;
bar(edges(1:end-1),pdf,0.9,'histc');

%% save the results

% For each variable, enter the chosen binning edges here
% and save in a matfile called output_events_define_binning.mat

      edges_p = edges;
%     edges_q = edges;
%     edges_logq = edges;









