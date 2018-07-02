% Function to Control Manually, called from:
% [Plot_Raw_Processed_Data.m]
% Signal processing of EPSC (manual command):
% Arrow Right: moves to next samples
% Arrow Left: moves to previous samples
% Arrow Up: Increase Lambda and Process Actual Data int he Axis
% Arrow Down: Decrease Lambda and Process Actual Data int he Axis

function manual_ctrl(object,event)
%% Setup
% Global Variables
global fs;
global x;
global x_syn;
global x_detrended;
global lambdacounter;
global lambdaglobal;
global rglobal;
% Arbitrary Variable Values
L=10; p=1; taus_0=[1,1];
SW=1; OLsamples=1; ondeleta='merol';
% Load Setup  Variable's Values
Load_SP_Settings;
% Info from the Plot:
Acut=round(object.Children(1).XLim(1)*60*fs);
% Samples of the Window Time
% WTsamp=numel(object.Children(2).Children(1).YData); 
AxisCurrent=gca;
WTsamp=int64((AxisCurrent.XLim(end)-AxisCurrent.XLim(1))*fs*60+1);
Bcut=round(Acut+WTsamp-1);
% tmin_cut=[];
tmin_cut=linspace(double(Acut),double(Bcut),double(Bcut-Acut+1))/fs/60;
x_cut=x(Acut:Bcut);
x_syn_cut=x_syn(Acut:Bcut);
x_det=x_detrended(Acut:Bcut);
stdnoise=std(x_det - x_syn_cut);
% Set Axis Names
AxisUp=object.Children(2);
AxisRawX=AxisUp.Children(1);
AxisDown=object.Children(1);
AxisNoise=AxisDown.Children(1);
AxisProcSyn=AxisDown.Children(2);
AxisDetrenX=AxisDown.Children(3);
% TitleUp=AxisUp.Title.String;
% AxisNoise=AxisDown
% set(AxisDown,'nextplot','replace');
% =plot([0,0],[0,0],'Color','.r');

%% Magical Stuff Here
key=get(object,'CurrentKey');
deltalambda=1;
if strcmp(key,'rightarrow')
    % AxisCurrent=gca;
    % WTsamp=floor((AxisCurrent.XLim(end)-AxisCurrent.XLim(1))*fs*60);
    % WTsamp=int64((AxisCurrent.XLim(end)-AxisCurrent.XLim(1))*fs*60);
    % WTsamp=numel(object.Children(2).Children(1).YData);
    WTsamp=int64((AxisDown.XLim(end)-AxisDown.XLim(1))*fs*60+1);
    disp(['Next ',num2str(double(WTsamp)/fs),'[s] Window------->'])
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
    lambdacounter=0; % Re-Start Lambda Counter
    AxisDown.Title.String=[];
    AxisUp.Title.String='EPSC Detection';
elseif strcmp(key,'leftarrow')
    % AxisCurrent=gca;
    WTsamp=int64((AxisDown.XLim(end)-AxisDown.XLim(1))*fs*60+1);
    % WTsamp=numel(object.Children(2).Children(1).YData);
    disp(['Previous ',num2str(double(WTsamp)/fs),'[s] Window------->'])
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
    lambdacounter=0; % Re-Start Lambda Counter
    AxisDown.Title.String=[];
    AxisUp.Title.String='EPSC Detection';
elseif strcmp(key,'uparrow')
    disp('Up-ReProcess lambda   /\')
    get_data;
    deltalambda=1.25;
    process_data;
    update_data;
    plot_data;
elseif strcmp(key,'downarrow')
    disp('Down-ReProcess lambda \/');
    get_data;
    deltalambda=0.75;
    process_data;
    update_data;
    plot_data;
end
%% Nested Functions ######################################################
    function get_data()
        % Get Sampled Signals
        tmin_cut=linspace(double(Acut),double(Bcut),double(Bcut-Acut+1))/fs/60;
        x_cut=x(Acut:Bcut);
        x_syn_cut=x_syn(Acut:Bcut);
        x_det=x_detrended(Acut:Bcut);
        % WTsamp=numel(object.Children(2).Children(1).YData); % samples of the Window Time
    end

    function update_data()
        x_syn(Acut:Bcut)=x_syn_cut;
    end

    function plot_data()
        % 1ST SUBPLOT OF RAW DATA
        AxisRawX.YData=x_cut;
        AxisRawX.XData=tmin_cut;
        AxisUp.XLim=[tmin_cut(1),tmin_cut(end)];
        AxisUp.YLim=[min(x_cut),max(x_cut)];
        % 2ND SUBPLOT OF PROCESSED DATA
        AxisDetrenX.YData=x_det;
        AxisDetrenX.XData=tmin_cut;
        AxisProcSyn.XData=tmin_cut;
        AxisProcSyn.YData=x_syn_cut;
        if max(x_det)==min(x_det)
            AxisDown.YLim=[min(x_detrended),max(x_detrended)];
        else
            AxisDown.YLim=[min(x_det),max(x_det)];
        end
        AxisNoise.YData=-[stdnoise,stdnoise];
        AxisNoise.XData=[tmin_cut(1),tmin_cut(end)];
    end
    function process_data()
        if numel(x_det(x_det<0))>1.5*L
            if lambdacounter==0
                AxisDown.Title.String='Processing ... ';
                lambdacounter=lambdacounter+1; % Increase Counter Lambda
                % AR process Estimation
                [rglobal,~,~]=AR_Estimation(x_det',p,fs,L,taus_0);
                % Magical Sparse Deconvolution 
                [d,lambdaglobal]=maxlambda_finder(x_det',rglobal,1);
                % Get Signal
                x_syn_cut=sparse_convolution(d,rglobal);
                stdnoise=std(x_det - x_syn_cut);
                % plot_data;
            else
                lambdacounter=lambdacounter+1; % Increase Counter Lambda
                lambdaglobal=lambdaglobal*deltalambda;
                [~,x_syn_cut,~]=magic_sparse_deconvolution(x_det',rglobal,lambdaglobal);
                stdnoise=std(x_det - x_syn_cut);                
            end
            SynPeaks=findpeaks(-x_syn_cut);
            if isempty(SynPeaks)
                Nsyn=0;
            else
                Nsyn=numel(SynPeaks(SynPeaks>stdnoise));
            end
            AxisUp.Title.String=[' EPSC Detected: ',num2str(Nsyn)];
            AxisDown.Title.String=['\lambda = ',num2str(lambdaglobal),' N= ',num2str(numel(x_det))];
            AxisDown.Title.FontSize=9;
        else
            disp('Get a Wider Window to Process or There is NO detrended signal')
        end
    end
 end