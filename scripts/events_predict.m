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

%% Step 1: create and analyze the model
% copied from events_analyze.m

num_rep = 1; % number of sampling repetitions 
sample_sizes = [78912]; % sample sizes to consider 
samplingstrategy = 'continuous'; % sampling strategy
num_sasi = length(sample_sizes);  % number of different sample sizes

data = [event q qplus2 rm(:,32)];
edges = cell(1,4);
edges{1} = edges_event;
edges{2} = edges_q;
edges{3} = edges_q;
edges{4} = edges_rm;

[data_binned_xgqqplus2rm, data_histcounts_xgqqplus2rm] = f_histcounts_anyd(data, edges);
[~, ~, ~, H_xgqqplus2rm,  ~,  ~] = f_infomeasures_from_samples(data, edges, data_binned_xgqqplus2rm, data_histcounts_xgqqplus2rm, sample_sizes, num_rep, samplingstrategy);

%% Step 2: Apply the model 

    % specify the model
    model = data_histcounts_xgqqplus2rm;
    
    % from data_binned (which includes the target, extract the binned predictor
    % values for each timestep)
    predictor_vals = data_binned_xgqqplus2rm(:,2:end);

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
    
%% Step 5: Plot timeseries

 % plot a timeseries of q(t) and event
    figure;
    ax1=subplot(2,1,1);
    plot(DateTime,q,'b');
    ylabel('Discharge [m3/s]');
    ax2=subplot(2,1,2);
    hold on
    plot(DateTime,event,'b')
    plot(DateTime,p_event_xgqqplus2rm,'r')
    plot(DateTime,p_event_binary_xgqqplus2rm,'.r')
    plot(DateTime,p_event_xgqqplus2rm,'g')
    plot(DateTime,p_event_binary_xgqqplus2rm,'.g')
    hold off
    ylim([-0.1,1.1]);
    ylabel('event Yes=1, No=0');
    linkaxes([ax1,ax2],'x');

%% save the results 
save results_predict_model29.mat
save output_events_predictRECURSIVE_pe_tminus1.mat peminus1_xgqqplus2rm