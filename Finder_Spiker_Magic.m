%% GENERAL ****************************************************
% built: 11-7-17
%         It detects post synaptic-like waveforms signals
%         By sparse deconvolution from y=R*d+n, where:
%         y: signal
%         R: Synaptic Response Approx
%         d: Driver Signal or Onset indicator
%         n: noise
% Input
%   abf file from pCLAMP v2.X Post Synpatic Currents
%   Intervlas
% Output
%   Diplasy N synaptics @ WT=10 s window
%   Saved dataset @ Processed data saves data from the Intervals of Processing
%   Saves Log of Time Processing and Events
clc;
clear;
close all;
versionFS=2.251; % 04/07/18
%% Global Variables
global x;
% global t;
global fs;
global X_SYN;
global XD;
global Intervals;
global WT;
global lambdacounter;
global lambdaglobal; %#ok<NUSED>
global rglobal; %#ok<NUSED>
global FileName;
lambdacounter=0;
%% Get Scrripts Directory
Update_Directories
%% Load & Display WHOLE DATA ***********************************************
% Load Signal, Sampling Frequency [Hz]& File Name:
[x,fs,FileName,UnitsName]=loadEPSCabf;      % Read Signal from ABF file                
ts=1/fs;                                    % Sampling period [s]
% t=linspace(0,1000*length(x)*ts,length(x));  % Time Vector [ms]
%% Read COndition's Names & Times
[NC,Cond_Names,Intervals]=Get_Conditions_Details(length(x),fs);

%% Start Processing **************************************************
% Detection & Feature Extraction
h=waitbar(0,'Processing...');
tic;
for c=1:NC
    % Read Data Condition Indexes:
    Start=round(Intervals(c,1)*60*fs+1);        % SAMPLE: discrete domain
    End=round(Intervals(c,2)*60*fs);            % SAMPLE: discrete domain
    % Process Data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    [GF{c},X_SYN{c},XD{c},RAR{c},STDnoise{c},LAMBDASS_WIND{c}]=DetectionProcessing(x(Start:End),fs,Start);
    waitbar(c/NC)
end
ProcessingTime=toc;
delete(h)
% #################################################################
%% Once you Re-Loaded data from .mat file, run these sections:
% #################################################################
% #################################################################
%% Get Vectorized Signals
Update_Directories;
global x_syn;
global x_detrended;
% Denoised Sparsed Synaptics
x_syn=get_synaptic_signal(Intervals,X_SYN,numel(x),fs);
% Detrended Original Signal
x_detrended=get_synaptic_signal(Intervals,XD,numel(x),fs);
%% Threhshold Parameters of GF/STDnoise/LAMBDASS
% Onset/Amplitude-vs-Noise/ Rise & Fall Time Ratio
% GF: onset|amplitude|rise|fall
[All_Onsets,~,~]=get_histogram(GF,1);
[All_Amplitudes,binAmp,CAmp]=get_histogram(GF,2);
[All_Rises,~,~]=get_histogram(GF,3);
[All_Fallens,~,~]=get_histogram(GF,4);
[All_Lambdas,binLamb,CLamb]=get_histogram(GF,5);
[All_NoiseStd,binNoise,Cnoise]=get_histogram(STDnoise);
[All_Lamb_Win,binLambWin,CLambWin]=get_histogram(LAMBDASS_WIND);

% Repeated Onsets due to: *************************************************
% Negative or Zero Inter-Synaptics-Interval
[StaySyn,AllSyn]=clean_negative_isi(All_Onsets,All_Amplitudes);
% Cleaning Parameters:
Clean_Onsets=clean_indexes(StaySyn,AllSyn,All_Onsets);
Clean_Amplitudes=clean_indexes(StaySyn,AllSyn,All_Amplitudes);
Clean_Rises=clean_indexes(StaySyn,AllSyn,All_Rises);
Clean_Fallens=clean_indexes(StaySyn,AllSyn,All_Fallens);
Clean_Lambdas=clean_indexes(StaySyn,AllSyn,All_Lambdas);

% Lambda Selecting**************************************
% Check if there is mode @lambda pdf so it is <1
[plamb,binlamb]=ksdensity(Clean_Lambdas);
[PealProb,PeakLamb]=findpeaks(plamb,binlamb);
if ~isempty(PeakLamb)
    if PeakLamb(1)<1
        disp('lambda Way too low -> clean')
        [~,BinLambda]=histcounts(Clean_Lambdas);
        LambdaTHreshold=BinLambda(2);
        StayLamb=find(Clean_Lambdas>LambdaTHreshold);
        AllLamb=1:numel(Clean_Lambdas);
        Clean_Lambdas=clean_indexes(StayLamb,AllLamb,Clean_Lambdas);
        Clean_Onsets=clean_indexes(StayLamb,AllLamb,Clean_Onsets);
        Clean_Amplitudes=clean_indexes(StayLamb,AllLamb,Clean_Amplitudes);
        Clean_Rises=clean_indexes(StayLamb,AllLamb,Clean_Rises);
        Clean_Fallens=clean_indexes(StayLamb,AllLamb,Clean_Fallens);
        disp('>> Lambdas Cleaned')
    else
        disp('Lambda Parameter: OK')
    end
end
% Amplitude Threshold : maximum std of noise
Clean_OnsetsA= Clean_Onsets(  Clean_Amplitudes<min(All_NoiseStd) );
Clean_OnsetsA= Clean_Onsets(  Clean_Amplitudes<-8 );

% Fallen Rise  Ratio
FRR=Clean_Fallens./Clean_Rises;
Clean_OnsetsB= Clean_Onsets( FRR>=1.5 );
Clean_A= Clean_Amplitudes( FRR>=1.5 );

%% Preliminar Results
WT=10; % Window in [ SECONDS ]
plot_window_histogram(All_Onsets,WT,Cond_Names,Intervals,fs);
% plot_window_histogram(Clean_OnsetsA,WT,Cond_Names,Intervals,fs);
% plot_window_histogram(Clean_OnsetsB,WT,Cond_Names,Intervals,fs);

%% MANUAL MODE
% Activate Manual Editor
% Display: raw signal and processed signal
% Manipulate and save

%% Save Processing Intel
% Experiment:                       FileName
% Experiment Length:                sum(diff(Intervals'))
% Detected Synatics Automatically:  numel(Clean_Amplitudes)
% Time of Processing:               ProcessingTime [sec]
% Overlapping Size:                 OLsamples
% Window Sampling:                  SW
% Size of the Response:             L
dtime=clock;
FileTime='_';
for d=1:6
    FileTime=[FileTime,num2str(round(dtime(d)))];
end
Load_SP_Settings;
T=table( sum(diff(Intervals')), numel(Clean_Amplitudes),...
    ProcessingTime,OLsamples,SW,L,versionFS);
T.Properties.VariableNames={'Experiment_Length','Synaptics','TimeProcessing',...
    'Overlapping','WindowProcessing','LengthResponse','FSversion'};

ActualDir=pwd;
Slashes=find(ActualDir=='\');
SaveDir=[ActualDir(1:Slashes(end)),'Log Processing\'];
% Save Table in Resume Tables of the Algorithm Latency*********
if isdir(SaveDir)
    writetable(T,[SaveDir,FileName(1:end-4),FileTime,'.csv'],...
        'Delimiter',',','QuoteStrings',true);
    disp('Saved Log Processgin Intel')
else % Create Directory
    disp('Directory >Log Processing< created')
    mkdir(SaveDir);
    writetable(T,[SaveDir,FileName(1:end-4),FileTime,'.csv'],...
        'Delimiter',',','QuoteStrings',true);
    disp('Saved Log Processing Intel')
end

%% Saving Pre_Results
ActualDir=pwd;
Slashes=find(ActualDir=='\');
SaveDir=[ActualDir(1:Slashes(end)),'Processed Data\'];
if isdir(SaveDir)
    save([SaveDir,FileName(1:end-4),'.mat'],'x',...
    'fs','FileName','Cond_Names','Intervals',...
    'GF','X_SYN','XD','RAR','STDnoise','LAMBDASS_WIND');
    disp('[RAW DATA SAVED]')
    disp('[PROCESSED DATA SAVED]')
else % Create Directory
    disp('Directory > \Processed Data < created')
    mkdir(SaveDir);
    save([SaveDir,FileName(1:end-4),'.mat'],'x',...
    'fs','FileName','Cond_Names','Intervals',...
    'GF','X_SYN','XD','RAR','STDnoise','LAMBDASS_WIND');
    disp('[RAW DATA SAVED]')
    disp('[PROCESSED DATA SAVED]')
end

%% Review Results
% for c=1:NC
%     % Read Data Indexes:
%     Start=round(Intervals(c,1)*60*fs+1);
%     End=round(Intervals(c,2)*60*fs);
%     % Process Data
%     % Detection of Events
%     Windows_Reviewer(x(Start:End),t(Start:End),Drivers{c},Tdetection{c},fs);
%     % Measure of Events
%     % ... [missing]
% end