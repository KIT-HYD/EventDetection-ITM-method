function [H_x, DKL_x, HPQ_x, H_xgy, DKL_xgy, HPQ_xgy] = f_infomeasures_from_samples(data, edges, data_binned, data_histcounts, sample_sizes, num_rep, samplingstrategy)
% For a target X and an any-dimensional set of predictors Y, returns information measures as a function of the size of samples taken from the data set
% Note: f_infomeasures_from_samples can also be applied to a target only (no predictors passed to the function.
%       In this case, H_xgy, DKL_xgy and HPQ_xgy are not computed and will be 'NaN'
% Input
% - data: [num_data,num_dim] array, where each row is a set of related target (col=1) and predictors (col= 2:end) values
%   Note: data must be NaN-free
% - edges: [1,num_dim] cell array, with a [1,num_edges] array of bin edges for each dimension inside
%   Note: For each dimension, the edges must completely cover the entire value range of the respective data
% - data_binned: [num_data,num_dim] array, with values in data classified, separately for each dimension, into its respective bins
%   Note: 
%   - data_binned(:,1) is the target, data_binned(:,2:end) are the predictors
%   - data_binned must be NaN-free
% - data_histcounts: [num_bins of dim 1, num_bins of dim 2, ... , num_bins of dim end]
%   matrix, with 'dim 1' being the target, and 'dim 2' ... 'dim end' being the predictors
%   with counts of occurrency of the particular target/predictors combination
% - sample_sizes: [num_sasi,1] vector with the sample sizes to be evaluated
% - num_rep: [1,1] number of repetitions to average over for each sample size
% - samplingstrategy: [1,1] how to take samples from the full data set:
%   - 'random': points are randomly sampled
%   - 'continuous': from a randomly chosen starting point the points are continuosly sampled
% Output
% - H_x: [1,1] unconditional entropy of the target, full data set
% - DKL_x: [num_sasi,1] unconditional Kullback-Leibler divergence of target samples, against full data set as reference
%                This quantifies the additional uncertainty about the target if its distribution
%                is estimated from a sample
% - HPQ_x: [num_sasi,1] unconditional cross entropy of target samples, against full data set as reference
%                This quantifies the total uncertainty about the target if its distribution
%                is estimated from a sample. HPQ_x = H_x + DKL_x
% - H_xgy: [1,1] conditional entropy of target given the predictors, full data set 
%                This is the expected (mean) H of all target conditional distributions 
%                given a particular combination of predictor values
% - DKL_xgy: [num_sasi,1] conditional Kullback-Leibler divergence of target samples, against full data set conditional
%                distribtutions as reference.
%                This quantifies the additional uncertainty about the target if the predictors are known, but if its 
%                conditional distributions are estimated from a sample
%                This is the expected (mean) DKL of all sample target conditional distributions vs. the target conditional
%                distribution from the full data set
% - HPQ_xgy: [num_sasi,1] conditional cross entropies of target samples, against full data set conditional
%                distributions as reference
%                This quantifies the total uncertainty about the target if predcitors are known and its 
%                conditional distributions are estimated from a sample. HPQ_xgy = H_xgy + DKL_xgy
% Version
% - 2017/11/24 Uwe Ehret: added some more comments
% - 2017/10/22 Uwe Ehret: initial version

%% preparations

% get dimensionality of data set
    num_data = size(data_binned,1); % length of the data set (rows of data_binned)
    num_dim = size(data_binned,2); % target + number of predictors (cols of data_binned, and dimensionality of data_histcounts
    num_bins = size(data_histcounts); % [num_dim,1] with number of bins of target and every predictor
    num_sasi = size(sample_sizes,1); % number of different sample sizes to test

% check data for NaN
    if ~isempty(find(isnan(data)))
        error('data contains NaN');
    end

% check data_binned for NaN
    if ~isempty(find(isnan(data_binned)))
        error('data_binned contains NaN');
    end

% check data_histcounts for NaN
    if ~isempty(find(isnan(data_histcounts)))
        error('data_histcounts contains NaN');
    end

% check if input data fall outside the bin edges
    mins = min(data);   % smallest value in each dimension
    maxs = max(data);   % largest value in each dimension

    % loop over all dimensions
    for d = 1 : num_dim 
        if mins(d) < edges{d}(1) % smallest value is < leftmost edge
            error('input data < leftmost edge');
        elseif maxs(d) > edges{d}(end)  % largest value is > rightmost edge
            error('input data > rightmost edge');
        end
    end    
    
% initialize output variables
    H_x = NaN(1,1);
    DKL_x = NaN(num_sasi,1);
    HPQ_x = NaN(num_sasi,1);
    H_xgy = NaN(1,1);
    DKL_xgy = NaN(num_sasi,1);
    HPQ_xgy = NaN(num_sasi,1);

% create variables needed in the script

    % edges of the target bins
    edges_target = edges{1};
    
    % array of all possible predictor bin combinations 
    % This is needed to derive conditional distributions of the target
    % Note that the input to f_all_predictor_bincombs includes the target dimension, but the output does not!
    [p_combis] = f_all_predictor_bincombs(num_bins); % set of all possible predictor combinations
    num_p_combis = size(p_combis,1); % the number of all possible predictor combinations
    
%% compute H_x

    % find the number of bins of the target (size of data_histcounts along the 1st dimension) 
    num_bins_target = size(data_histcounts,1);
    
    % reshape data_histcounts such that it resolves the target (= 1st dimension) 
    % and all other dimensions are collapsed to one (= 2nd dimension)
    dummy = reshape(data_histcounts,[num_bins_target,numel(data_histcounts)/num_bins_target]); 
    
    % get overall counts of each target bin by summing over the 2nd dimension
    % this is the target marginal histogram
    target_hist = sum(dummy,2)';
    
    % get target marginal pdf by dividing its histogram with the total number of target counts
    target_pdf = target_hist / sum(target_hist);
    
    % compute the entropy
    H_x = f_entropy(target_pdf); 
 
%% compute H_xgy (but only if at least one predictor is available)   

    if num_dim > 1 
        [H_xgy, target_histograms_fulldataset] = f_conditionalentropy_anyd(data_histcounts, p_combis);
    end
    
%% compute statistics for samples: DKL_x, HPQ_x, DKL_xgy, HPQ_xgy

    % loop over all sample sizes to be evaluated
    for s = 1 : num_sasi

        % the current sample size
        num_data_sasi = sample_sizes(s);

        % initialize vectors for results of all repetitions
        DKL_x_rep = NaN(num_rep,1);
        HPQ_x_rep = NaN(num_rep,1);
        DKL_xgy_rep = NaN(num_rep,1);
        HPQ_xgy_rep = NaN(num_rep,1);
        
        % initialize conditional entropies of the samples, only needed as intermediate result
        H_xgy_rep = NaN(num_rep,1); 

        % loop over repetitions of one sample size
        for r = 1 : num_rep

            % take a sample of the full data set
            sample = f_sample_data(data, num_data_sasi, samplingstrategy);

            % bin the sample with the same edges as the full data set
            [sample_binned, sample_histcounts] = f_histcounts_anyd(sample, edges);

            % compute the DKL between the unconditional target pdf of the sample and the target pdf of the full data set as a reference

                % reshape sample_histcounts such that it resolves the target (= 1st dimension) 
                % and all other dimensions are collapsed to one (= 2nd dimension)
                dummy = reshape(sample_histcounts,[num_bins_target,numel(sample_histcounts)/num_bins_target]); 

                % get overall counts of each target bin by summing over the 2nd dimension
                % this is the target marginal histogram of the sample
                target_hist_sample = sum(dummy,2)';

                % get target marginal pdf of the sample by dividing its histogram with the total number of target counts
                target_pdf_sample = target_hist_sample / sum(target_hist_sample);
                
                % Note: The case that target_pdf_sample is completely empty (sum(target_hist_sample = 0))
                % will never occur here (unless we put the sample size to 0)
                % so we do not have to take care of it
                
                % check for zero values in target_pdf_sample_hat where pdf is non-zero
                % If this is the case, replace pdf_hat with its non-zero estimate
                if ~isempty(intersect(find(target_pdf_sample == 0), find(target_pdf ~= 0)))
                    target_pdf_sample = f_NonZeroPDF(target_hist_sample);
                end
                
                % finally, compute DKL
                DKL_x_rep(r) = f_kld(target_pdf,target_pdf_sample);
            
            % if at least one predictor exists, compute conditional entropy and conditional DKL
            if num_dim > 1
                
                % compute the conditional entropy and target histograms of the sample for all predictor combinations of the full data set
                [H_xgy_rep(r), target_histograms_sample] = f_conditionalentropy_anyd(sample_histcounts, p_combis);

                % compute the conditional DKL between the conditional target pdfs of the sample and the conditional target pdf of the full data set as a reference
                % Note: Here the case that the condtional pdf of target or predictor is completely empty 
                %       can occur, but will be handeled in the function
                DKL_xgy_rep(r) = f_conditionalkld_anyd(target_histograms_fulldataset, target_histograms_sample);
                
            end
            
        end % of loop over repetitions of one subsample size

        % take the mean over all repetitions. This is the expected value of the respective statistic
        DKL_x(s) = mean(DKL_x_rep); 
        HPQ_x(s) = H_x + DKL_x(s);  % cross entropy can be computed from the mean/expected values
        DKL_xgy(s) = mean(DKL_xgy_rep );
        HPQ_xgy(s) = H_xgy + DKL_xgy(s); % cross entropy can be computed from the mean/expected values

    end % of loop over all subsample sizes

end

