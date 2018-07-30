function [ data_sample ] = f_sample_data(data, samplesize, samplingstrategy)
% Takes a random sample without replacement from a dataset with different sampling strategies
% Input
% - data: [n,m] data set, where each row is one data item
% - samplesize: [1,1] size of the sample (=number of rows in data) to be taken
% - samplingstrategy: [1,1] how to take samples from the full data set:
%   - 'random': data items are randomly sampled without replacement (each row can only be sampled once)
%   - 'continuous': from a randomly chosen starting row the data items are continuosly sampled
%     Note: If this exceeds the length of data, we assume a circular data set and continue at the start
% Output
% - data_sample: [samplesize,m] sample of the data set
% Version
% - 2017/10/23 Uwe Ehret: initial version

% get dimensionality of data set
num_data = size(data,1); % length of the data set (rows of data)

% check if sample requested is is larger than the data set
if samplesize > num_data
    error('samplesize must be <= size of the data set');
end

% distinguish the sampling strategies
if strcmp(samplingstrategy,'random')
    
    % take a random sample without replacement
    data_sample = datasample(data,samplesize,1,'Replace',false); 
    
elseif strcmp(samplingstrategy,'continuous')
    
    % double the data set to avoid end of data set
    data_double = [data;data];
    
    % randomly select a start position in data
    start = randi(num_data);
    
    % take the sample
    data_sample = data_double(start:start+samplesize-1,:);
    
else
    error('wrong specification of sampling strategy');   
end

end

