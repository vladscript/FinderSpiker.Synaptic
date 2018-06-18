%% Funtion to load Axon Binary Files (.abf)
% It uses the function abfload from: https://www.mathworks.com/matlabcentral/fileexchange/6190-abfload
% INPUT
%   Open dialogue box to pick a file
% Output
%   x: signal vector [pA]
%   fs: sampling frequency
function [x,fs,FileName,UnitsName]=loadEPSCabf
    DefaultPath='C:\Users\Vladimir\Documents\Doctorado\Colaboraciones\EPSCs';
    if exist(DefaultPath,'dir')==0
        DefaultPath=pwd; % Current Diretory of MATLAB
    end
    
[FileName,PathName] = uigetfile('*.abf',' Pick an Axon file ',...
    'MultiSelect', 'off',DefaultPath);
% Signal Units pA                              
[DATA,ts_us,hinfo]=abfloadV2([PathName,FileName]);

UnitsName=hinfo.recChUnits{1};
ChannelName=hinfo.recChNames{2};
X=DATA(:,1,:); 
[N,R]=size(X);                  % N samples of R segments

x=X(:);
ts=ts_us/(1e6);                 % Sampling Period from [us] to [s]
fs=1/(ts_us/(1e6));             % Sampling Frequency [Hz]
disp([num2str(R),' Traces of ',num2str(N,4),' samples'])
disp(['Duration of the record: ',num2str(R*N*ts/60),' minutes '])
disp(['Sampled @: ',num2str(fs/1000),' kHz '])

%% Preview
figure; plot(ts*linspace(0,length(x)/60,length(x)),x)
title([FileName,' Record: ',ChannelName])
axis tight; grid on;
ylabel(['Current [',UnitsName,']'])
xlabel('Time [min]')
drawnow;
