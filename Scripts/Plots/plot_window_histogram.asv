% Plot Histogram of Events for a given
% time window and C conditions
% Input
%  All_Onsets:   Vector of Onset for each Condition SECONDS
%  WT:           Scalar Size of the time window SECONDS
%  Cond_Names:   Cell of Names of the Conditions
%  Intervals:    Cell of Intervals in MINUTES (start,end)
%  fs:           Sampling Frequency
% Output
%   Plot Histogram
function plot_window_histogram(All_Onsets,WT,Cond_Names,Intervals,fs)
%% Setup
NC=numel(Cond_Names);
ts=1/fs;
HistSyn=figure;
HistSyn.Name='Temporal Histogram';
Haxis=subplot(1,1,1);

%% Main Loop
preMaxSyn=0;
for c=1:NC
    % Setup
    Nstart=Intervals(c,1); Nend=Intervals(c,2);     % [min]
    NW=round((Nend-Nstart)*60*fs/(WT/ts));          % Number of TimeWindows
    wup=Nstart*60*fs;  % SAMPLES
    % Counting
    SynCount=[];
    for w=1:NW
        A=(All_Onsets*fs/1000>wup);
        B=(All_Onsets*fs/1000<=wup+(WT/ts));
        SynCount(w)=sum(A.*B);
        wup=wup+(WT/ts);
    end
    % Plotting
    timeSyn=linspace(Nstart,Nend,NW);
    MaxSyn=max([preMaxSyn,max(SynCount)]);
    preMaxSyn=MaxSyn;
    bar(timeSyn,SynCount); hold on;
    line([Nstart,Nend],[max(SynCount)+10,max(SynCount)+10],...
        'LineWidth',2,'Color','black');
    text(Nstart+(Nend-Nstart)/3,max(SynCount)+15,...
        Cond_Names{c});
end
set(Haxis,'YLim',[0,MaxSyn+20]);
set(Haxis,'XLim',[0,Nend]);
Haxis.YLabel.String=['# Synaptics / ',num2str(WT),' s'];
Haxis.XLabel.String='Time [min]';
grid(Haxis,'on');