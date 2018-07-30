function [condi_hist] = f_conditional_histogram(predictor_vals, model)
% Extracts a conditional histogram of a target variable from a model relating
% predictors and target, for a single set of current predictor values
% Input
% - predictor_vals: [1,n] or [n,1] array with a set predictor bin values
%   n = number of predictors of the model
% - model: [num_bins of dim 1, num_bins of dim 2, ... , num_bins of dim end]
%   matrix, with 'dim 1' being the target, and 'dim 2' ... 'dim end' being the predictors
%   with counts of occurrency of the particular target/predictors combination
%   - The dimensionality of 'model' is 1+n
%   - The model is a frequency distribution (not a pdf)
% Output
% - condi_hist [num_bins of dim 1,1] array with a conditional histogram of the
%   target given the particular set of predictor bin values in predictor_vals
% Version
% - 2017/12/01 Uwe Ehret: extraction of target conditional histogram now
%              done by indexing with cell array, instead of using 'eval'
%              (change suggested by Diego Thiesen)
% - 2017/10/31 Uwe Ehret: initial version

% check if predictor_vals is NaN-free
if ~isempty(find(isnan(predictor_vals)))
    error('predictor_vals contains NaNs')
end

% check if model is NaN-free
if ~isempty(find(isnan(model)))
    error('model contains NaNs')
end

% get dimensions
num_pred = length(predictor_vals); % number of predictors
num_dim_model = length(size(model)); % number of dimensions of the model

% check if dimensionality of predictor_vals and model agree
if (num_dim_model -1 - num_pred) ~= 0
    error('dimensions of predictor_vals and model do not agree')
end

% UE: new version since 2017/12/01
    % extract the target conditional histogram from the model for a particular predictor combination
    predictor_vals_cell = num2cell(predictor_vals);     % convert the predictor combination from double array to cell array
    condi_hist = model(:, predictor_vals_cell{:});      % use the cell array to index the model
% UE: end new version since 2017/12/01

% UE: version before 2017/12/01
    % % initialize the command to extract the target conditional histogram from the model for a particular predictor combination
    % dummy_str = ('condi_hist = model(:,');
    %     
    % % loop over all predictors
    % for d = 1 : num_pred
    %     if d == 1
    %         dummy_str = strcat(dummy_str,num2str(predictor_vals(d)));
    %     else
    %         dummy_str = strcat(dummy_str,',',num2str(predictor_vals(d)));
    %     end                   
    % end
    %     
    % % finalize the command
    % dummy_str = strcat(dummy_str,');'); 
    %     
    % % execute the command: get the conditional target histogram and store it in 'condi_hist'
    % eval(dummy_str); 
% UE: end version before 2017/12/01

end

