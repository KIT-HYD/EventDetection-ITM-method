% Program to prepare input data for analysis and prediction of events

% Conditions
% - all series must be evenly spaced, gapfree and NaN-free

% Input
% - time series of Datetime [t,1]
% - time series of discharge q [t,1]
% - time series of rainfall p [t,1]
% - time series of user-provided classification event Yes=1 No=0 [t,1]
%   NOTE: it has to start and end with a non-event (0)

% Output
% - num_t: length of timeseries [1,1] 
% - DateTime: Datetime [num_t,1]
% - event: user-provided classification event Yes=1 No=0 [num_t,1]
% - q: discharge at time t [num_t,1]
% - qplus1: discharge at time t+1  [num_t,1]
% - qplus2: discharge at time t+2  [num_t,1]
% - qminus1: discharge at time t-1  [num_t,1]
% - qminus2: discharge at time t-2  [num_t,1]
% - logq: base e log of discharge at time t [num_t,1]
% - logqplus1: log discharge at time t+1  [num_t,1]
% - logqplus2: log discharge at time t+2  [num_t,1]
% - logqminus1: log discharge at time t-1  [num_t,1]
% - logqminus2: log discharge at time t-2  [num_t,1]
% - p: precipitaion at time t [num_t,1]
% - rm: relative magnitude of discharge at time t in window of size rm_window_sizes to the left AND right of it [num_t,num_ws] 
% - rml: relative magnitude of discharge at time t in window of size rm_window_sizes to the left of it [num_t,num_ws] 
% - rmr: relative magnitude of discharge at time t in window of size rm_window_sizes to the right of it [num_t,num_ws] 
% - num_ws: length of rm_window_sizes [1,1]
% - rm_window_sizes: size of rm window [1,num_ws]

% Version
% - 2017/10/19: UE, initial version

clear all
close all
clc

%% load data
load input_events_prepare

%% prepare predictors

num_t = length(DateTime); % length of the data set

% q(t)
% - already exists

% q(t+1)
qplus1 = circshift(q,-1);     % discharge at t+1 [m�/s] 

% q(t+2)
qplus2 = circshift(q,-2);     % discharge Q at t+2 [m�/s]

% q(t-1)
qminus1 = circshift(q,1); % discharge Q at t-1

% q(t-2)
qminus2 = circshift(q,2); % discharge Q at t-2

% log q(t)
logq = log(q);

% logq(t+1)
logqplus1 = circshift(logq,-1);     % discharge at t+1 [m3/s] 

% logq(t+2)
logqplus2 = circshift(logq,-2);     % discharge Q at t+2 [m3/s]

% logq(t-1)
logqminus1 = circshift(logq,1);     % discharge at t-1 [m3/s] 

% logq(t-2)
logqminus2 = circshift(logq,2);     % discharge Q at t-2 [m3/s]

% p(t)
% - already exists

% slope before vector [(Qt - Qt-1) / (t - t-1)]
qslope_before = q - qminus1;

% slope after vector [(Qt+1 - Qt) / (t+1 - t)]
qslope_after = qplus1 - q;

%% relative magnitude of discharge rm, rml and rmr (it takes a few minutes)

 num_ws = 100; % maximum length of the window
 rm_window_sizes = 1:num_ws; %create vector of window sizes
    % find the rm, rml and rmr values 
    
        % initialize the vectors
        rm = NaN(num_t,num_ws); % symmetrical window of size 2*rm_window_sizes + 1
        rml = NaN(num_t,num_ws); % window of size rm_window_size + 1 located BEFORE the analized value (to its left)
        rmr = NaN(num_t,num_ws); % window of size rm_window_size + 1 located AFTER the analized value (to its right)
        
        for ws = 1 : num_ws % loop over all window sizes

            q_shifted = NaN(num_t,2*rm_window_sizes(ws)+1);
            counter = 1;
            
            for s = rm_window_sizes(ws) : -1: -rm_window_sizes(ws) % loop over all shifts
                q_shifted(:,counter) = circshift(q,s);
                counter = counter+1;
            end

            % rm
            from = 1;
            to = 2*rm_window_sizes(ws)+1;            
            for t = 1 : num_t % loop over all timesteps
                min_q = min(q_shifted(t,from:to));    % find the minimum q in the window
                max_q = max(q_shifted(t,from:to));    % find the maximum q in the window
                if min_q == max_q
                    rm(t,ws) = 0.5; % all values in the window are the same --> rm is 0.5
                else
                    rm(t,ws) = (q(t) - min_q) / (max_q - min_q); % find the relative size [0,1] of q in the window
                end                
            end
            
            % rml
            from = 1;
            to = rm_window_sizes(ws)+1;          
            for t = 1 : num_t % loop over all timesteps
                min_q = min(q_shifted(t,from:to));    % find the minimum q in the window
                max_q = max(q_shifted(t,from:to));    % find the maximum q in the window
                if min_q == max_q
                    rml(t,ws) = 0.5; % all values in the window are the same --> rml is 0.5
                else
                    rml(t,ws) = (q(t) - min_q) / (max_q - min_q); % find the relative size [0,1] of q in the window
                end                      
            end
            
            % rmr
            from = rm_window_sizes(ws)+1;
            to = 2*rm_window_sizes(ws)+1;
            for t = 1 : num_t % loop over all timesteps
                min_q = min(q_shifted(t,from:to));    % find the minimum q in the window
                max_q = max(q_shifted(t,from:to));    % find the maximum q in the window               
                if min_q == max_q
                    rmr(t,ws) = 0.5; % all values in the window are the same --> rmr is 0.5
                else
                    rmr(t,ws) = (q(t) - min_q) / (max_q - min_q); % find the relative size [0,1] of q in the window
                end                     
            end
            
        end
          
 
%% save the output
 save output_events_prepare DateTime num_t event q p qminus1 qminus2 qplus1 qplus2 logq logqminus1 logqminus2 logqplus1 logqplus2 qslope_before qslope_after rm rml rmr rm_window_sizes 




