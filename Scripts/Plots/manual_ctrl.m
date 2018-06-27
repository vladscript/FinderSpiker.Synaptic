% Function to Control Manually
% Signal processing of EPSC
function manual_ctrl(object,event)
%% Setup
% Global Variables
global fs;
global x;
global x_syn;
global x_detrended;
% Info from the Plot:
Acut=round(object.Children(1).XLim(1)*60*fs);
WTsamp=numel(object.Children(2).Children(1).YData); % samples of the Window Time
Bcut=round(Acut+WTsamp-1);
tmin_cut=[];
x_cut=[];
x_syn_cut=[];
x_det=[];
%% Magical Stuff Here
key=get(object,'CurrentKey');
if strcmp(key,'rightarrow')
    AxisCurrent=gca;
    % WTsamp=floor((AxisCurrent.XLim(end)-AxisCurrent.XLim(1))*fs*60);
    WTsamp=int64((AxisCurrent.XLim(end)-AxisCurrent.XLim(1))*fs*60);
    disp(['Next ',num2str(WTsamp/fs),'[s] Window------->'])
    % Get Intervals
    if Bcut+WTsamp-1>=numel(x)
        Bcut=numel(x);
        Acut=numel(x)-WTsamp+1;
        disp('End of the Record   <-]]]]')
    else
        Acut=Bcut+1;
        Bcut=Bcut+WTsamp-1;
    end
    get_data;
    plot_data;
elseif strcmp(key,'leftarrow')
    AxisCurrent=gca;
    WTsamp=int64((AxisCurrent.XLim(end)-AxisCurrent.XLim(1))*fs*60);
    disp(['Previous ',num2str(WTsamp/fs),'[s] Window------->'])
    % Get Intervals
    if Acut-WTsamp+1<=1
        Acut=1;
        Bcut=WTsamp;
        disp('[[[->     Start of the Record')
    else
        Bcut=Acut-1;
        Acut=Acut-WTsamp+1;
    end
    get_data;
    plot_data;
    
elseif strcmp(key,'uparrow')
    disp('Process Up ')    
elseif strcmp(key,'downarrow')
    disp('Process Down')    
end
%% Nested Functions
    function get_data()
        % Get Sampled Signals
        tmin_cut=linspace(double(Acut),double(Bcut),double(Bcut-Acut+1))/fs/60;
        x_cut=x(Acut:Bcut);
        x_syn_cut=x_syn(Acut:Bcut);
        x_det=x_detrended(Acut:Bcut);
        % WTsamp=numel(object.Children(2).Children(1).YData); % samples of the Window Time
    end
    function plot_data()
        % 1ST SUBPLOT OF RAW DATA
        object.Children(2).Children(1).YData=x_cut;
        object.Children(2).Children(1).XData=tmin_cut;
        object.Children(2).XLim=[tmin_cut(1),tmin_cut(end)];
        object.Children(2).YLim=[min(x_cut),max(x_cut)];
        % 2ND SUBPLOT OF PROCESSED DATA
        object.Children(1).Children(2).YData=x_det;
        object.Children(1).Children(2).XData=tmin_cut;
        object.Children(1).Children(1).XData=tmin_cut;
        object.Children(1).Children(1).YData=x_syn_cut;
        if max(x_det)==min(x_det)
            object.Children(1).YLim=[min(x_detrended),max(x_detrended)];
        else
            object.Children(1).YLim=[min(x_det),max(x_det)];
        end
    end
 end