[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1404638.svg)](https://doi.org/10.5281/zenodo.1404638)

# Event Detection Method Based on Information Theory

In the ED method, we propose a data-driven approach based on Information Theory to automatically identify rainfall-runoff events in discharge time series. The final objective of the predictive model is to reflect (by means of probability) the users' Yes/No event decision and to more easily reproduce this classification patterns over a longer period of time or in a consistent new data set. 
The core of the concept is to construct and apply discrete, multivariate probability distributions to obtain probabilistic predictions of each time step being part of an event. For evaluation, we use Shannon Entropy and Conditional Entropy to select the best predictors and models, and Cross Entropy and Kullback-Leibler Divergence for measuring the strength of the Curse of Dimensionality in the model and its risk of overfitting. 
The approach permits any data to serve as predictors. Each choice of a particular predictor dataset is equivalent to formulate a model hypothesis. For the study case, we used as input: time series of discharge, precipitation and a training data set of events which were identified by a user.

The codes and data sets are complementary parts of the study proposed by Thiesen, Darscheid and Ehret (2018):

>_Thiesen, S., Darscheid, P., Ehret, U.: Identifying rainfall-runoff events in discharge time series: A data-driven method based on Information Theory. 2018._ 


## License agreement

The ED method comes with ABSOLUTELY NO WARRANTY. You are welcome to modify and redistribute it within the license agreement. The ED method is published under the CreativeComons "BY-NC-SA 4.0" license together with a ready-to-use sample data set. To view a full version of the license agreement please visit [BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).


## Requisites

* MATLAB (tested on 2018a).


## Usage

1. Download code as a zip file [here](https://github.com/KIT-HYD/EventDetection/archive/master.zip) or using git. You may need to download the files from `example_dataset/` separately.
2. Add the `functions/` folder to MATLAB path.
3. Navigate to the `scripts/` folder in MATLAB working directory.
4. See the included scripts and datasets for an example usage, and modify as necessary for your dataset.


## File structure

* functions/ ... .m
* scripts/ ... .m
* example_dataset/ ... .mat

### Functions

All functions are detailed in their own source code body. Examples of how to use them are available in the `scripts/` folder. 

```
f_histcounts_anyd
f_infomeasures_from_samples
f_conditional_histogram
f_all_predictor_bincombs
f_entropy
f_conditionalentropy_anyd
f_sample_data
f_histcounts_anyd
f_NonZeroPDF
f_kld
f_conditionalkld_anyd
allcomb_singleinput.m
```

### Scripts
The scripts contains usage examples based on the paper dataset (described in the section "Data set of the study"), and they are organized in the following logical sequential order.

__1. events_prepare.m__
Program to prepare input data (target and potential predictors) for analysis and prediction of events. 
- Input file: input_events_prepare.mat _(available on the `example_dataset/` folder)_
- Output file: output_events_prepare.mat _(available on the `example_dataset/` folder)_
 
 __2. events_define_binning.m__
Program to define the binning for all variables included in event analysis and prediction. It helps to analyze the data set to define the best bining strategy.
- Input file: output_events_prepare.mat _(available on the `example_dataset/` folder)_
- Output file: output_events_define_binning.mat _(available on the `example_dataset/` folder)_

__3. events_analyze.m__
The program helps to find the optimal set of predictors to predict events. When the user already has a set of models selected, in this same program it is also possible analyze the effect of different sample sizes, which is used to verify overfitting and the Curse of Dimensionality. 
- Input files: output_events_prepare.mat & output_events_define_binning.mat _(available on the `example_dataset/` folder)_

_Best predictors and models:_ Choice based on Entropy `H_x` and Conditional Entropy `H_xgy, H_xg2y,...` values. For this analysis, the number of sampling repetitions is 1 and sample size is the size of the full data set.

_Overfitting/Curse of Dimensionality:_ Choice based on Kullback-Leibler Divergence `DKL_xgy, DKL_xg2y,...` and Cross-Entropy values `HPQ_xgy, HPQ_xg2y,...`. For this analysis, the number of sampling repetitions needs to be defined and the sample size is a vector with the different sample sizes to be tested.

__4. events_predict.m__
Program to apply a set of predictors to predict events. The output of the code is the probability of the time step being a event.
- Input file: output_events_prepare.mat & output_events_define_binning.mat  _(available on the `example_dataset/` folder)_

> Note: As a recursive model, the result of the model application (probability of the time step being a event) can be also used as a predictor. In the paper, we shifted the results 1 time step and used them as predictor for the Model #29 and #30. As a complementary material, the __events_predictRECURSIVE_qqplus2rm_peminus1.m__ file organizes the step by step of the best  selected model of our paper. In this code `peminus1_xgqqplus2rm` is the probability of the time step t-1 being an event. In the paper, it is the prediction of the Model #27 (e | Q(t), P, RM) shifted 1 time step. `peminus1_xgqqplus2rm` is used as a predictor to create the model #29, and `p_event_xgqqplus2rmeminus1` is the model prediction.


### Dataset of the study

The folder contains raw and processed observation time series from the Dornbirnerach catchment in Austria used in the paper case study. Time resolution: 1 hour.

* `input_events_prepare.mat` contains the basic data needed for the case study
* `output_events_define_binning.mat` and `output_events_prepare.mat` are the processed inputs necessary to try the Information Theory measurements in the script `events_analyze.m` and to predict the events in the script `events_predict.m`

__1. input_events_prepare.mat__ 
Raw inputs of the catchment. It is the fundamental data for starting the event detection. Each row of the files represent 1 hour.

File content:
* __q:__ Discharge time series [m³/s] 
* __p:__ Precipitation time series [mm/h]
* __event:__ It is a binary dataset of rainfall runoff events. We classified each time step of the time series as either being part of an event (value '1') or not (value '0'). It is used as a target/training dataset. 
* __DataTime:__ Time vector related to the observation time series. It contains 78,912 data points. 

__2. output_events_prepare.mat__
Processed inputs of the catchment. It was created in the `events_prepare.m` script. It is the variables of potential predictors and target to be tested. 

File content:
* __q:__ discharge at time t [m³/s] 
* __p:__ precipitation at time t [mm/h]
* __event:__ event classification at time step t ['1' for event and '0' for non-event] 
* __DataTime:__ data time 
* __num_t:__ length of timeseries 
* __qplus1:__ discharge at time t+1 [m³/s] 
* __qplus2:__ discharge at time t+2 [m³/s] 
* __qminus1:__ discharge at time t-1 [m³/s]  
* __qminus2:__ discharge at time t-2 [m³/s]  
* __logq:__ natural logarithm of discharge at time t [ln(m³/s)]  
* __logqplus1:__ natural logarithm of discharge at time t+1 [ln(m³/s)]   
* __logqplus2:__ natural logarithm of discharge at time t+2 [ln(m³/s)]  
* __logqminus1:__ natural logarithm of discharge at time t-1 [ln(m³/s)]  
* __logqminus2:__ natural logarithm of discharge at time t2 [ln(m³/s)]  
* __rm:__ matrix of Relative Magnitude of Discharge-Central at time t. Each column is a tested window size (vector of window size: __rm_window_sizes__) [dimensionless] _Note: predictor detailedly explained in paper_ 
* __rml:__ matrix of Relative Magnitude of Discharge-Left at time t. Each column is a tested window size (vector of window size: __rm_window_sizes__) [dimensionless] _Note: predictor detailedly explained in paper_ 
* __rmr:__ matrix of Relative Magnitude of Discharge-Right at time t. Each column is a tested window size (vector of window size: __rm_window_sizes__) [dimensionless] _Note: predictor detailedly explained in paper_ 
* __qslope_after:__ Slope of the hydrograph after the time step t [m³/s.h] _Note: predictor detailedly explained in paper_
* __qslope_before:__ Slope of the hydrograph before the time step [m³/s.h] _Note: predictor detailedly explained in paper_


__3. output_events_define_binning.mat__
File with the bin edges for each variable (target and predictors). It was created in the `events_define_binning.m` script. Note: Variables with n+1 edges for n bins (e.g. for 2 bins, with [0,1] as central values of the bins, it will be 3 edges `[-0.5, 0.5, 1.5]` ) 

File content:
* __edges_q:__ binning applicable for the variables q, qplus1, qplus2, qminus1, qminus2
* __edges_logq:__ binning applicable for the variables logq, logqplus1, logqplus2, logqminus1, logqminus2
* __edges_p:__ binning applicable for the variable p
* __edges_event:__ binning applicable for the variable event
* __edges_rm:__ binning applicable for the variables rm, rml, rmr
* __edges_qslope2:__ binning applicable for the variables qslope_after, qslope_before


## Contact

Stephanie Thiesen | stephanie.thiesen@kit.edu
Uwe Ehret | uwe.ehret@kit.edu



