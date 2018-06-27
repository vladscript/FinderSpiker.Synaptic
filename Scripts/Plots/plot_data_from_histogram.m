% Script to Plot Data from Histogram
% And be abe to [re]-process data
% Only Run After plot_window_histogram
%% CHECK IF ACTUALLY come from the Figure
ActualBar=gco;
if isobject(ActualBar)
    if strcmp(ActualBar.Type,'rectangle')
        disp('Showing data ...')
        ActualTime=ActualBar.Position(1); % MINUTES OF THE EXPERIMENT
        %tmin=t/(1000*60);
        %[~,timeframe]=min(abs(tmin-ActualTime));
        timeframe=ActualTime*60*fs;
        Plot_Raw_Processed_Data;
        
    else
        disp('No Selected Bar Time')
    end
else
    disp('No data');
    % Probably Never happen
end