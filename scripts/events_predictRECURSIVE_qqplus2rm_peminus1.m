% Program to apply a set of predictors and a model to predict events

% Conditions

% Input
% - output_events_analyze.mat with the 'data_histcounts' for the optimal set of predictors
%   This is the 'model' that will be used for prediction
% - input_events_predict.mat with
%   - DateTime: [t,1] datetime array of the timeseries to predict events
%   - event: [t,1] array with observed events (only if available, for comparison)
%   - edges_event: array with edges for events
%   - all [t,1] predictor timeseries required by the model 
%   - all edges arrays for all predictors

% Output
% - none

% Version
% - 2017/10/29 Uwe Ehret: initial version

clear all
close all
clc

%% load data
load output_events_prepare.mat
load output_events_define_binning.mat

%% Step 1: apply the non-recursive model (model_1) with predictors to create the new predictor p_event(t-1)

    % combine and bin the data to get binned predictor values
    % Note: If no observed target data are available, create some dummy data
    data = [event q  qplus2 rm(:,32)];
    edges = cell(1,4);
    edges{1} = edges_event;
    edges{2} = edges_q;
    edges{3} = edges_q;
    edges{4} = edges_rm;
    [data_binned_qqplus2rm, data_histcounts_qqplus2rm] = f_histcounts_anyd(data, edges);
    
    % specify the model
    model = data_histcounts_qqplus2rm;
    
    % from data_binned (which includes the target, extract the binned predictor
    % values for each timestep)
    predictor_vals = data_binned_qqplus2rm(:,2:end);

    % get length of the timeseries to predict
    num_t = length(DateTime);

    % initialize the array with predicted probability of Event=Yes
    p_event_xgqqplus2rm = NaN(num_t,1);

    % loop over all timesteps to predict
    for t = 1 : num_t

        % from the model, extract the conditional target histogram for the current timestep
        dummy_hist = f_conditional_histogram(predictor_vals(t,:),model);

        % get conditional target pdf by dividing its histogram with its frequency
        % Note: If the marginal frequency = 0, this means division by 0, which leads to a pdf filled with NaNs
        dummy_pdf = dummy_hist / sum(dummy_hist);

        % from the pdf, extract the probability of event=Yes (value in bin 2)
        p_event_xgqqplus2rm(t) = dummy_pdf(2);

    end

    % convert the probabilistic prediction to a binary one by rounding toward
    % the nearest integer (0 or 1)
    p_event_binary_xgqqplus2rm = round(p_event_xgqqplus2rm);

    % compute some statistics (only possible if the truth is known)
    hits_xgqqplus2rm = length(intersect(find(event==1),find(p_event_binary_xgqqplus2rm==1)))        % obs=Yes and sim=Yes
    misses_xgqqplus2rm = length(intersect(find(event==1),find(p_event_binary_xgqqplus2rm==0)))      % obs=Yes and sim=No
    false_events_xgqqplus2rm = length(intersect(find(event==0),find(p_event_binary_xgqqplus2rm==1)))% obs=No and sim=Yes
    correct_negatives_xgqqplus2rm = length(intersect(find(event==0),find(p_event_binary_xgqqplus2rm==0))) % obs=No and sim=No
    percent_correct_xgqqplus2rm = 100*(hits_xgqqplus2rm + correct_negatives_xgqqplus2rm)/num_t      % total percentage of correct classifications       
    checksum_xgqqplus2rm = hits_xgqqplus2rm+misses_xgqqplus2rm+false_events_xgqqplus2rm+correct_negatives_xgqqplus2rm-num_t % should be 0   

%% Step 2: define binning for new predictor p_event(t-1)
% copied from events_define_binning.m

% create the new predictor: modelled probability of event=Yes at t-1
peminus1_xgqqplus2rm = circshift(p_event_xgqqplus2rm,1); 

% choose outermost bin centers and binwidth
center_left = 0; % center of leftmost bin
center_right = 1; % center of rightmost bin
binwidth = 0.1; % binwidth

% compute bin edges
mini = center_left-0.5*binwidth;   % leftmost bin edge
maxi = center_right+0.5*binwidth;   % rightmost bin edge
numbins = 1+(center_right-center_left)/binwidth;   % number of bins
edges_peminus1 = linspace(mini,maxi,numbins+1);

clear center_left center_right binwidth mini maxi numbins

%% Step 3: create and analyze the new model (model_2) with predictors q rm(:,32) qplus2 peminus1_xgqrmqplus2
% copied from events_analyze.m

num_rep = 1; % number of sampling repetitions 
sample_sizes = [78912]; % sample sizes to consider 
samplingstrategy = 'continuous'; % sampling strategy
num_sasi = length(sample_sizes);  % number of different sample sizes

data = [event q qplus2 rm(:,32) peminus1_xgqqplus2rm];
edges = cell(1,5);
edges{1} = edges_event;
edges{2} = edges_q;
edges{3} = edges_q;
edges{4} = edges_rm;
edges{5} = edges_peminus1;

[data_binned_xgqqplus2rmeminus1, data_histcounts_xgqqplus2rmeminus1] = f_histcounts_anyd(data, edges);
[~, ~, ~, H_xgqqplus2rmeminus1,  ~,  ~] = f_infomeasures_from_samples(data, edges, data_binned_xgqqplus2rmeminus1, data_histcounts_xgqqplus2rmeminus1, sample_sizes, num_rep, samplingstrategy);

%% Step 4: apply the recursive model (model_2) with predictors q qplus2 rm(:,n) peminus1_xgqqplus2rm

    % specify the model
    model = data_histcounts_xgqqplus2rmeminus1;
    
    % from data_binned (which includes the target, extract the binned predictor
    % values for each timestep)
    predictor_vals = data_binned_xgqqplus2rmeminus1(:,2:end);

    % get length of the timeseries to predict
    num_t = length(DateTime);

    % initialize the array with predicted probability of Event=Yes
    p_event_xgqqplus2rmeminus1 = NaN(num_t,1);

    % loop over all timesteps to predict
    for t = 1 : num_t

        % from the model, extract the conditional target histogram for the current timestep
        dummy_hist = f_conditional_histogram(predictor_vals(t,:),model);

        % get conditional target pdf by dividing its histogram with its frequency
        % Note: If the marginal frequency = 0, this means division by 0, which leads to a pdf filled with NaNs
        dummy_pdf = dummy_hist / sum(dummy_hist);

        % from the pdf, extract the probability of event=Yes (value in bin 2)
        p_event_xgqqplus2rmeminus1(t) = dummy_pdf(2);

    end

    % convert the probabilistic prediction to a binary one by rounding toward
    % the nearest integer (0 or 1)
    p_event_binary_xgqqplus2rmeminus1 = round(p_event_xgqqplus2rmeminus1);

    % compute some statistics (only possible if the truth is known)
    hits_xgqqplus2rmeminus1 = length(intersect(find(event==1),find(p_event_binary_xgqqplus2rmeminus1==1)))        % obs=Yes and sim=Yes
    misses_xgqqplus2rmeminus1 = length(intersect(find(event==1),find(p_event_binary_xgqqplus2rmeminus1==0)))      % obs=Yes and sim=No
    false_events_xgqqplus2rmeminus1 = length(intersect(find(event==0),find(p_event_binary_xgqqplus2rmeminus1==1)))% obs=No and sim=Yes
    correct_negatives_xgqqplus2rmeminus1 = length(intersect(find(event==0),find(p_event_binary_xgqqplus2rmeminus1==0))) % obs=No and sim=No
    percent_correct_xgqqplus2rmeminus1 = 100*(hits_xgqqplus2rmeminus1 + correct_negatives_xgqqplus2rmeminus1)/num_t      % total percentage of correct classifications       
    checksum_xgqqplus2rmeminus1 = hits_xgqqplus2rmeminus1+misses_xgqqplus2rmeminus1+false_events_xgqqplus2rmeminus1+correct_negatives_xgqqplus2rmeminus1-num_t % should be 0    
    
%% Step 5: Plot timeseries

 % plot a timeseries of q(t) and event
    figure;
    ax1=subplot(2,1,1);
    plot(DateTime,q,'b');
    ylabel('Discharge [m³/s]');
    ax2=subplot(2,1,2);
    hold on
    plot(DateTime,event,'b')
    plot(DateTime,p_event_xgqqplus2rmeminus1,'r')
    plot(DateTime,p_event_binary_xgqqplus2rmeminus1,'.r')
    plot(DateTime,p_event_xgqqplus2rmeminus1,'g')
    plot(DateTime,p_event_binary_xgqqplus2rmeminus1,'.g')
    hold off
    ylim([-0.1,1.1]);
    ylabel('event Yes=1, No=0');
    linkaxes([ax1,ax2],'x');

%% save the results 
save results_predict_qqplus2rmpeminus1.mat
