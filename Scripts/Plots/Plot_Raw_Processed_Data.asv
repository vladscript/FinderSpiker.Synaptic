%% INPUT
% x: raw signal
% Intervals
% X_SYN->   x_syn: clenasynaptics
% XD->      x_detrended: detrended raw signal
% tmin: vector time  in MINUTES
% fs: sampling frequency
% timeframe: starting axis view
function Plot_Raw_Processed_Data(timeframe,WTinit)
%% Management
% Control that there is no other Figure called CHECK SIGNALS
figHandles = findobj('Type', 'figure');
for n=1:numel(figHandles)
    if strcmp(figHandles(n).Name,'CHECK SIGNALS')
        close(figHandles(n));
    end        
end

%% Setup
global x;
global fs;
% global WT;
global x_syn;
global x_detrended;
global lambdacounter;
%% Initial Cut
Acut = int64(timeframe);
Bcut = int64(timeframe+WTinit*fs-1);
% tmin_Cut =      tmin(Acut:Bcut);
% tmin_Cut =      float(Acut:Bcut)/fs/60;
tmin_Cut =      linspace(double(Acut),double(Bcut),double(Bcut-Acut+1))/fs/60;
x_cut    =      x(Acut:Bcut);
x_syn_cut=      x_syn(Acut:Bcut);
x_det_cut=      x_detrended(Acut:Bcut);
stdnoise=std(x_det_cut - x_syn_cut);
lambdacounter=0; % Initialize
% handles.tmin=tmin;
% handles.x=x;
% handles.x_syn=x_syn;
% handles.x_det=x_detrended;
%% Plot Data
% Plot_Data=figure('keypressfcn',@(object,event)manual_ctrl(object,event,handles));
Plot_Data=figure('keypressfcn',@(object,event)manual_ctrl(object,event));
Plot_Data.Name='CHECK SIGNALS';
AxisUp=subplot(2,1,1);
AxisDown=subplot(2,1,2);
linkaxes([AxisUp,AxisDown],'x');

%% Plot Raw Data

plot(AxisUp,tmin_Cut,x_cut)
axis(AxisUp,[tmin_Cut(1),tmin_Cut(end),min(x_cut),max(x_cut)]);
grid(AxisUp,'on')
%% Plot Processed Data
% Detrended Signal
plot(AxisDown,tmin_Cut,x_det_cut);
hold(AxisDown,'on');
% Synaptic Signal
plot(AxisDown,tmin_Cut,x_syn_cut,'LineWidth',2,'Color','k');
% Noise Threshold
plot(AxisDown,[0,numel(x_syn_cut)],-[stdnoise,stdnoise],'-.r');
% Axis & Grid
grid(AxisDown,'on')
axis(AxisDown,[tmin_Cut(1),tmin_Cut(end),min(x_cut),max(x_cut)]);
%% Setting Figure Appearance
AxisUp.XTickLabel=[];
AxisUp.Title.String='EPSC Detection';
AxisUp.Title.FontSize=10;
AxisUp.YLabel.String='Raw Current';
AxisUp.YLabel.FontSize=8;
AxisDown.YLabel.String='Detrended Current';
AxisDown.YLabel.FontSize=8;
AxisDown.XLabel.String='t [min]';
AxisDown.XLabel.FontSize=8;