%% INPUT
% x: raw signal
% Intervals
% X_SYN->   x_syn: clenasynaptics
% XD->      x_detrended: detrended raw signal
% tmin: vector time  in MINUTES
% fs: sampling frequency
% timeframe: starting axis view
function Plot_Raw_Processed_Data(timeframe)
%% Setup
% global Intervals;
% global X_SYN;
global x;
global fs;
% global XD;
global WT;
global x_syn;
global x_detrended;
%% Initial Cut
Acut = int64(timeframe);
Bcut = int64(timeframe+WT*fs-1);
% tmin_Cut =      tmin(Acut:Bcut);
% tmin_Cut =      float(Acut:Bcut)/fs/60;
tmin_Cut =      linspace(double(Acut),double(Bcut),double(Bcut-Acut+1))/fs/60;
x_cut    =      x(Acut:Bcut);
x_syn_cut=      x_syn(Acut:Bcut);
x_det_cut=      x_detrended(Acut:Bcut);
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

plot(AxisDown,tmin_Cut,x_det_cut);
hold(AxisDown,'on');
plot(AxisDown,tmin_Cut,x_syn_cut);
grid(AxisDown,'on')
axis(AxisDown,[tmin_Cut(1),tmin_Cut(end),min(x_cut),max(x_cut)]);
