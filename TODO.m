%% READY TO GO
% ************************************************************************
% Time Processing Issues:
% use std(noise) of NON FIEXED DETRENDED SIGNAL->DONE
% deconvolution mode->DONE
% Length of the Processing Window->DONE
% Overlapping Size->DONE
% Length Response->DONE
% NO SAVE vector t-> Error
%% TASKS:

% get skewnnes of samples just below POSITIVE standard DEV-NOISE >>Next
% Version
% Should I save the vector x????
% Re plot histogram from synaptics Signal after closign manual mode
% Downsample Signal to Make it Faster
% Processing Parameters: Rate of Synaptics vs Time of Processing
% Linka X axis between raw data and periohistogram
% Integrate Several Conditios in Sevral .abf Files
% MANUAL MODE: OK->

% Data Sets: ------
% #######################################################################
% Get Onsets & Parameters after Manual Mode:
% Applying Filter such as:
% > Amplitude (sigma noise)
% > Rise/Fall Times Ratio 
% For each Condition:
% [FEATURES]=get_features(x_syn,Intervals)

% From COMPLETE signal:
%   Cursor activate a Zomm According to the Intervals of The Condition

% OPTIONAL {no excatly necessary}
%   Cursor to Delete Manually a Synaptic
% Delete plot_data_from_histogram
%       plot onsets of the detected ones-> Clean Ones
% Manual Funtion
% Personlize Colors


%% Already in Github
% Make histogram /10s
% Clear Repeated Onsets (get biggest amplitude)
% Save lambda for each synaptic
% Filter by smallest lambda
% Upload to Github
% test on data test:17228002.abf
% Save Log and Matlab Data
% MANUAL MODE:
%   Highlight Bar from Histogram
%   Plot_Raw_Processed_Data-> Cut Data instead of plotting Everybit
%   Display Data from histogram: OK
%   Activate Editor->Deconvolve Manually [KeyBoard]                     ***
%   Show Threshold: Standard Deviation of Noise 
%   Up and Down Lambda
%   Update Signal
%   display N samples
%   display S synaptics detected
% MAKE GLOBAL Variables(space issue)
% MANUAL MODE: Processing:
% Processing: 
% Exit Function: Save Synaptics Signal:
% X_SYN=cut_signal(x_syn,Intervals)
% SAVE SIGNALS AS CELLS!!!!!!
%   Save with Time&Date