%% GENERAL ****************************************************
% Beta 
% v1.1:     03-8-17: bugs/opt coding/ fasten(?)
% v1:       26-7-17: automatic detection; preliminar results
% built: 11-7-17
%         It detects post synaptic-like waveforms signals
%         By sparse deconvolution from y=R*d+n, where:
%         y: signal
%         R: Synaptic Response Approx
%         d: Driver Signal or Onset indicator
%         n: noise
clc;
clear;
close all;
%% Get Scrripts Directory
Update_Directories
%% Load & Display WHOLE DATA ***********************************************
% Load Signal, Sampling Frequency [Hz]& File Name:
[x,fs,FileName,UnitsName]=loadEPSCabf;      % Read Signal from ABF file                
ts=1/fs;                                    % Sampling period [s]
t=linspace(0,1000*length(x)*ts,length(x));  % Time Vector [ms]
%% Read COndition's Names & Times
[NC,Cond_Names,Intervals]=Get_Conditions_Details(length(x),fs);

%% Start Processing **************************************************
% Detection & Feature Extraction
h=waitbar(0,'Processing...');
for c=1:NC
    % Read Data Condition Indexes:
    Start=round(Intervals(c,1)*60*fs+1);
    End=round(Intervals(c,2)*60*fs);
    % Process Data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    [GF{c},X_SYN{c},XD{c},RAR{c},STDnoise{c},LAMBDASS_WIND{c}]=DetectionProcessing(x(Start:End),t(Start:End),fs);
    waitbar(c/NC)
end
delete(h)
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
        disp('Cleaned')
    else
        disp('Lambda Parameter: OK')
    end
end

%% Preliminar Results
WT=10;
plot_window_histogram(All_Onsets,WT,Cond_Names,Intervals,fs);
plot_window_histogram(Clean_Onsets,WT,Cond_Names,Intervals,fs);

%% MANUAL MODE


%% Saving Pre_Results
% for c=1:NC
%     FileSave=[FileName(1:end-4),'-',Cond_Names{c},'.xls']; % MODIFY TO CSV
%     T=table(Tdetection{c}(:,1),Tdetection{c}(:,2),Tdetection{c}(:,3),...
%         Tdetection{c}(:,4),Tdetection{c}(:,5),Tdetection{c}(:,6));
%     %OKonsets',AMP',RT',TD',lambdass*ones(length(OKonsets),1),SNRbyWT(w)*ones(length(OKonsets),1)
%     T.Properties.VariableNames={'Onset_ms',['Amplitude_',UnitsName],'RiseTime_ms',...
%         'DecayTime_ms','lambda','SNR_dB'};
%     writetable(T,FileSave);
% end
% disp('... done')
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
%% Save Stuff
% ResultsTable=array2table(T);
% ResultsTable.Properties.VariableNames={'Onset_ms','Drive_Amplitude','lambda','SNR_dB'};
% FileDirSave=pwd;
% save([FileDirSave,'\Results','\ExperimentA.mat'],'LAMBDAS','TAUS',...
%     'D','XEST','XESTwBASAL','fs');