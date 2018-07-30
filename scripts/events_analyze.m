% Program to find the optimal set of predictors to predict events

% Conditions

% Input
% - variables provided in output_events_prepare.mat (from events_prepare.m)
% - variables provided in output_events_define_binning.mat (from events_define_binning.m)

% Output
% - output_events_analyze.mat with the 'data_histcounts' for the optimal set of predictors
%   This is the 'model' that will be used for prediction in the next step

% Version
% - 2017/10/20: UE, initial version

clear all
close all
clc

%% load data
    load output_events_prepare.mat
    load output_events_define_binning.mat

%% choose parameters
% Note: If num_rep = 1 and samplesizes = 78912, then the effect of sampling
% size is not evaluated

    % number of sampling repetitions 
    num_rep = 1; 

    % sample sizes to consider 
    sample_sizes = [78912]; 
    % sample_sizes = [100; 1000; 10000];
    % sample_sizes =  [50;100;500;1000;1500;2000;2500;5000;7500;10000;15000;20000;25000;30000;35000;40000;45000;50000;60000;70000;78912]; % sample sizes tested in the study
    % sample_sizes = [(100:100:1000) (1500:500:9000) (10000:1000:78000) (78912)]';
    
    % sampling strategy
    samplingstrategy = 'continuous';

%% create required variables

    % number of different sample sizes
    num_sasi = length(sample_sizes);  
    
%% evaluate no predictor series  
data = event; %target
edges = cell(1,1);
edges{1} = edges_event;
[data_binned_x, data_histcounts_x] = f_histcounts_anyd(data, edges);
[H_x, DKL_x, HPQ_x, ~, ~, ~] = f_infomeasures_from_samples(data, edges, data_binned_x, data_histcounts_x, sample_sizes, num_rep, samplingstrategy);

%% evaluate single predictor series
data = [event rm(:,32)]; %target + 1 predictor
edges = cell(1,2);
edges{1} = edges_event;
edges{2} = edges_rm;
[data_binned_xgy, data_histcounts_xgy] = f_histcounts_anyd(data, edges);
[~, ~, ~, H_xgy, DKL_xgy, HPQ_xgy] = f_infomeasures_from_samples(data, edges, data_binned_xgy, data_histcounts_xgy, sample_sizes, num_rep, samplingstrategy)

%% evaluate double predictor series
data = [event logq qslope_before]; %target + 2 predictors
edges = cell(1,3);
edges{1} = edges_event;
edges{2} = edges_logq;
edges{3} = edges_qslope2;
[data_binned_xg2y, data_histcounts_xg2y] = f_histcounts_anyd(data, edges);
[~, ~, ~, H_xg2y, DKL_xg2y, HPQ_xg2y] = f_infomeasures_from_samples(data, edges, data_binned_xg2y, data_histcounts_xg2y, sample_sizes, num_rep, samplingstrategy)

%% evaluate triple predictor series
data = [event q qslope_after rm(:,32)]; %target + 3 predictors
edges = cell(1,4);
edges{1} = edges_event;
edges{2} = edges_q;
edges{3} = edges_qslope2;
edges{4} = edges_rm;
[data_binned_xg3y, data_histcounts_xg3y] = f_histcounts_anyd(data, edges);
[~, ~, ~, H_xg3y, DKL_xg3y, HPQ_xg3y] = f_infomeasures_from_samples(data, edges, data_binned_xg3y, data_histcounts_xg3y, sample_sizes, num_rep, samplingstrategy)

%% four predictor (Example of the case study recursive model)
load output_events_predictRECURSIVE_pe_tminus1.mat

data = [event q qplus2 rm(:,32) peminus1_xgqqplus2rm];
edges = cell(1,5);
edges{1} = edges_event;
edges{2} = edges_q;
edges{3} = edges_q;
edges{4} = edges_rm;
edges{5} = edges_peminus1;

[data_binned_xg4y, data_histcounts_xg4y] = f_histcounts_anyd(data, edges);
[~, ~, ~, H_xg4y,  DKL_xg4y, HPQ_xg4y] = f_infomeasures_from_samples_all2(data, edges, data_binned_xg4y, data_histcounts_xg4y, sample_sizes, num_rep, samplingstrategy)

%% save the results of the selected model
save output_events_analyze.mat