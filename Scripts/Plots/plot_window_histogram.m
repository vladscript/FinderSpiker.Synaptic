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
% set (HistSyn, 'WindowButtonMotionFcn', @mouseMove);
HistSyn.Name='Temporal Histogram';
Haxis=subplot(1,1,1);
% set(HistSyn,)
%% Main Loop
preMaxSyn=0;
% BIN_TIMES=[];
% COUNTS_TOTAL=[];
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
    % SAVE ALL TIMES
    % BIN_TIMES=[BIN_TIMES,timeSyn];
    % SAVE ALL COUNTS
    % COUNTS_TOTAL=[COUNTS_TOTAL,SynCount];
    MaxSyn=max([preMaxSyn,max(SynCount)]);
    preMaxSyn=MaxSyn;
    BARplot{c}=bar(timeSyn,SynCount,'Parent',Haxis); hold on;
    set (BARplot{c}, 'ButtonDownFcn', @HighLightBar);
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
%% Save Bars Selected
Nbars=1;
x_0=0;
y_0=0;
Plot_Figure=false;
if Plot_Figure
    plot_data_from_histogram;
end
%% NESTED FUNCTIONS
    function HighLightBar (object, eventdata)
        [x,~] = ginput(1);
        [~,minT]=min(abs(object.XData-x));
        minX=diff(object.XData);
        x_0=object.XData(minT)-minX(1)/2;
        y_0=object.YData(minT);
        hold(Haxis,'on');
        RECT=rectangle('Position',[x_0,0,minX(1),y_0],'FaceColor','r','EdgeColor','b',...
        'LineWidth',0.25);
        hold(Haxis,'off');
        c=uicontextmenu;
        RECT.UIContextMenu = c;
        menuporc=uimenu( c,'Label','Show This Data','Callback',@showdata);
        sprintf('[%.2f - %.2f] Minutes - %d Synaptics',x_0,x_0+minX(1),y_0)
        Nbars=Nbars+1;
        Plot_Figure=true;
        % return;
        %C=get(HistSyn,'CurrentPoint');
        %disp(['(X,Y) = (', num2str(C(1,1)), ', ',num2str(C(1,2)), ')']);
    end
    function showdata(object, eventdata) 
        sprintf('Show Data @ %.2f Minutes',x_0);
        ActualBar=gco;
        if strcmp(ActualBar.Type,'rectangle');
            disp('Showing data ...')
            ActualTime=ActualBar.Position(1); % MINUTES OF THE EXPERIMENT
            timeframe=ActualTime*60*fs;
            Plot_Raw_Processed_Data(timeframe,WT);
        end
        %Plot_Figure=true;
        % Initialize Script to Plot Data
        % disp([x_0,y_0])
    end
end
%% END