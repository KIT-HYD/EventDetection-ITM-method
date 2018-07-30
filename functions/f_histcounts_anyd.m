function [ data_binned, data_histcounts ] = f_histcounts_anyd(data, edges)
% For an any-dimensional data set, returns the dataset classified in bins and the bincounts
% Also works for a 1-d data set
% Input
% - data: [num_data,num_dim] array, where each row is a set of related target
%   (col=1) and predictors (col= 2:end) values
%   Note: data must be NaN-free
% - edges: [1,num_dim] cell array, with a [1,num_edges] array of bin edges
%   for each dimension inside
%   Note: For each dimension, the edges must completely cover the entire
%   value range of the respective data
% Output
% - data_binned: [num_data,num_dim] array, with values in data classified,
%   separately for each dimension, into its respective bins
%   Note: col 1 is the target, cols 2 : end are the predictors
% - data_histcounts: [num_bins of dim 1, num_bins of dim 2, ... , num_bins of dim end]
%   array, with 'dim 1' being the target, and 'dim 2' ... 'dim end' being the predictors
%   with counts of occurrency of the particular target/predictor combination
%   Note that the ascending direction in one dimension is the ascending
%   direction in the bin edges, which is always from small to large
%   i.e. if edges for the target are [-0.5 0.5 1.5], then
%   data_histcounts(1,:,:) is for all cases where the target was '0'
% Version
% - 2017/12/01 Uwe Ehret: indexing of data_histcounts to raise its counter now
%              done by indexing with cell array, instead of creating a string and using 'eval'
%              (change suggested by Diego Thiesen)
% - 2017/10/30 Uwe Ehret: changed calculation of 'mins' and 'maxs' to also
%                         handle cases of num_data = 1
% - 2017/10/22 Uwe Ehret: initial version

% get dimensionality of data set
    [num_data, num_dim] = size(data);
 
% check input data for NaN
    if ~isempty(find(isnan(data)))
        error('input data contain NaN');
    end

% check if input data fall outside the bin edges
    mins = min(data,[],1);   % smallest value in each dimension
    maxs = max(data,[],1);   % largest value in each dimension

    % loop over all dimensions
    for d = 1 : num_dim 
        if mins(d) < edges{d}(1) % smallest value is < leftmost edge
            error('input data < leftmost edge');
        elseif maxs(d) > edges{d}(end)  % largest value is > rightmost edge
            error('input data > rightmost edge');
        end
    end

% initialize output variables

    % binned data set
    data_binned = NaN(num_data,num_dim);

    % histcounts
    num_bins = NaN(1,num_dim);
    dummy_str = ('data_histcounts = zeros(');

    % loop over all dimensions
    for d = 1 : num_dim
        num_bins(d) = size(edges{d},2) - 1; % number of bins = number of edges - 1
        if d == 1
            dummy_str = strcat(dummy_str,num2str(num_bins(d)));
        else
            dummy_str = strcat(dummy_str,',',num2str(num_bins(d)));
        end    
    end
        
    % if the data set has only one dimension (just a target), the
    % dummystr is not complete due to the if/else structure of building
    % it. In this case, add that there should be only one dimension.
    if num_dim == 1
        dummy_str = strcat(dummy_str,',1');
    end

    dummy_str = strcat(dummy_str,');');
    eval(dummy_str); % execute the command to build the 'data_histcounts' matrix
    
% compute the binned data set

    % loop over all dimensions
    for d = 1 : num_dim
        % classify the data in each dimension into bins
        [~,~,data_binned(:,d)] = histcounts(data(:,d),edges{d});
    end

% UE: new version since 2017/12/01
% compute the histogram counts

    % loop over all data
    for n = 1 : num_data
    
        % for all dimensions, get the bin number of the current row
        % and convert to cell to index multidimensional array
        bin_nums = num2cell(data_binned(n,:));
        
        % raise the counter for the current bin by one
        data_histcounts(bin_nums{:}) = data_histcounts(bin_nums{:}) + 1;
        
    end
% UE: end new version since 2017/12/01
    
% UE: version before 2017/12/01    
    % % compute the histogram counts
    % 
    %     % loop over all data
    %     for n = 1 : num_data
    %     
    %         % for all dimensions, get the bin number of the current row
    %         bin_nums = data_binned(n,:);       
    %         
    %         % create a string to raise the bin counter of this particular combination of target
    %         % and predictor bins in 'data_histcounts' (the indices in
    %         % 'bin_nums' unfortunately cannot be used directly to specify the
    %         % position in 'data_histcounts')
    %         
    %             % convert the bin numbers to a comma-separated string
    %             bin_nums_str = sprintf('%.0f,' , bin_nums);
    %             bin_nums_str  = bin_nums_str (1:end-1);% strip final comma
    %             
    %             % put the string together
    %             dummy_str = strcat('data_histcounts(', bin_nums_str, ')');
    %             dummy_str = strcat(dummy_str, '=', dummy_str, '+1;');
    %             
    %             % execute the command to build the 'data_histcounts' matrix
    %             eval(dummy_str); 
    %            
    %     end
% UE: end version before 2017/12/01
    
end


