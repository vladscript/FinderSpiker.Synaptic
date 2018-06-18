% Function to process each condition to detect PostSynaptic Currents
% Input
%   x: current signal
%   t: time vector
%   fs: sampling frequency
% Output
%   GLOBAL_FEATURES: [Onset_Time|Amplitude|Rise_Time|Fall_time]
%   XD:         Dretended Signal (fixed)
%   X_SYN:   Cleaned and Sparse Signal
%   LAMBDASS:   Sparse Deconv Parameter/windowed
%   RESPONSES:  Set of AR process / windowed
%   NOISE_STD:  Standard Deviation of Noise /windowed
%   SNR_WD:     Signal Noise Ratio by Wavelet Denoising / windowed
% 01/09/2017*********************
% Onset Version: Based on Wavelet Denoised Signal
function [GLOBAL_FEATURES,X_SYN,XD,RESPONSES,NOISE_STD,LAMBDAS]=DetectionProcessing(x,t,fs)

%% General Setup
%  Signal Processing
N=length(x);                % Total Samples
Load_SP_Settings;           % Signal Processsing Settings
OL=0;                       % Initial Overlapping 
NW=N/SW;                    % Number of Windows
% OUTPUTS
LAMBDAS=zeros(floor(NW),1); % Save lambdas for each window
XD=[];                      % Save Detrended Signal
X_SYN=[];                   % ALL Synaptics
NOISE_STD=[];                     % Amplitude Threshold: noise standard deviation

RESPONSES=[];                   % All the Reponses
GLOBAL_FEATURES=[];             % Global Features
%% MAIN LOOP
% figure; % TO see pre-results
wa=1;                           % Auxiliar to make windows
for w=1:floor(NW)
    %% Signal Windowing: pre-Overlapping      **************************
    if w<floor(NW) 
        wb=wa+SW-1;         % End Window
        tc=t(wa-OL:wb);     % Time Vector Window [ms]
        xc=x(wa-OL:wb);     % Windowed Signal
        wa=wb+1;            % Start Window
        OL=OLsamples;       % Overlapping
    else        % Final Window:
        xc=x(wa-OL:end);
        tc=t(wa-OL:end);
    end
    %% Processing *****************************************************
    % DETRENDING
    xbasal=smooth(xc,length(xc),'loess');
    xcd=xc-xbasal;  
    % DENOISE
    [xdenoised,xcdU]=denoise_wavelet(-xcd');
    % Turn it upside down:
    xcdU=-xcdU;
    xdenoised=-xdenoised;
    noisex=xcd-xdenoised';
    NoiseStD=std(noisex);
    % FEATURE EXTRACTION
    % [SkewSignal(w),SkewNoise(w),SNRbyWT(w),ABratio(w)]=feature_extraction(xdenoised,noisex);
    x_synaptic=zeros(size(xdenoised));
    %% Accept Window to Process
    if skewness(noisex,0)>skewness(xdenoised,0) % Synaptic-like Response Detected  FIRST STEP
        % AR process Estimation
        [r,~,~]=AR_Estimation(xcdU,p,fs,L,taus_0);
        % Magical Sparse Deconvolution 
        [d,LAMBDAS(w)]=maxlambda_finder(xcdU,r);
        % d=smooth(d)';%  SMOOTH DRIVER [OPTIONAL MAYBE]
        % x_sparse=sparse_convolution(d,r);
        % CLEAN DRIVER
        [dUP,~,~,~,~,~]=analyze_driver_signal(-d,r,-xcdU,-xdenoised,1); dDown=-dUP;
        % GET CLEAN SIGNAL
        x_sparse=sparse_convolution(dDown,r);
%         %% PLOT RESULTS PREVIEW ######################################
%         subplot(2,1,1)
%         plot(xc)
%         axis tight; grid on;
%         subplot(2,1,2)
%         plot(xcdU); hold on;
%         plot(x_sparse,'k','LineWidth',3);
%         plot([0,numel(x_sparse)],[std(noisex),std(noisex)],'-.r');
%         plot([0,numel(x_sparse)],-[std(noisex),std(noisex)],'-.r');
%         hold off;
%         axis tight; grid on;
%         disp(w)
        %% GET FEATURES *******************************************
        % Make of this A Function *********
        Features=[];
        [Amps,Npeaks]=findpeaks(-x_sparse);
        [~,Nvalleys]=findpeaks(x_sparse);
        if isempty(Nvalleys); Nvalleys=[1,numel(x_sparse)]; end;
        % PEAKS ******************************
        SaveSamples=[];
        if ~isempty(Amps)
            for n=1:numel(Amps)
                if Amps(n)>NoiseStD % Amplitude Check
                    minAmp=-Amps(n)/10;
                    % Before the peak
                    auxN=0;
                    while and(x_sparse(Npeaks(n)-auxN)<minAmp,Npeaks(n)-auxN>0)
                        SaveSamples=[SaveSamples,(Npeaks(n)-auxN)];
                        auxN=auxN+1;
                    end
                    Onset=Npeaks(n)-auxN;
                    Nrise=auxN;
                    % After the peak
                    auxN=1;
                    while and(and(x_sparse(Npeaks(n)+auxN)<minAmp,~ismember(Npeaks(n)+auxN,Nvalleys)),...
                            Npeaks(n)+auxN<numel(x_sparse))
                        SaveSamples=[SaveSamples,(Npeaks(n)+auxN)];
                        auxN=auxN+1;
                    end 
                    Nfall=auxN;
                    % ONLYIF FALL is LONGER THAN RISE !!!!!
                    if Nfall>Nrise
                        % Saving features at discrete time scale of the Window
                        Features=[Features;Onset,-Amps(n),Nrise,Nfall,LAMBDAS(w)];
                    end

                end
            end
        end
        % CLEAN SYNAPTICS         
        Nsyn=size(Features,1);
        if Nsyn>0
            for n=1:Nsyn
                x_synaptic(Features(n,1):Features(n,1)+sum(Features(n,3:4)))=...
                    x_sparse(Features(n,1):Features(n,1)+sum(Features(n,3:4)));
            end
            Features(:,[3,4])=Features(:,[3,4])/fs; % @ Experiment Time Scale
            % Discard Overlapping Samples
            Features=Features(Features(:,1)>OL,:);
            % SAVE if STILLL THERE'RE Synaptics
            if ~isempty(Features)
                % Get Onsets on the Global Scale
                Features(:,1)=tc(Features(:,1));
                GLOBAL_FEATURES=[GLOBAL_FEATURES;Features];
            end
        end
        
        SaveSamples=unique(SaveSamples);
        if ~isempty(SaveSamples)
            SamplesDelete=setdiff([1:numel(x_sparse)],SaveSamples);
            x_sparse(SamplesDelete)=0;
        end
%         %% PLOT RESULT COMLPEMENT ################################
%         subplot(2,1,2); hold on;
%         plot(x_synaptic,'m','LineWidth',2);
%         hold off;
    %% Reject Window to Process
    else
        % NOISE LESS SKEWER THAN SIGNAL (Negatively Speaking)
        disp('**************************************    NO Synaptic -like Response Detected');
        dDown=zeros(size(xcd))';
        r=zeros(1,L);
        LAMBDAS(w)=0;
    end
    disp(['>>>>>>>>>>>>>>>>> Signal ++++++++++++++++++++++ ',num2str(w),'/',num2str(floor(NW))])
    %% Save OUTPUTS ***********************************************
    % Take Care of the Overlapping
    if w==1
        d_save=dDown(1:end);            % Get all samples only at 1st window
        xclean=xcdU(1:end);
        xsynaptica=x_synaptic(1:end);
    else
        d_save=dDown(OL+1:end);         % Discard pre-Overlapping
        xclean=xcdU(OL+1:end);
        xsynaptica=x_synaptic(OL+1:end);
    end
    % SAVE DATA ***********************************************************
    % LAMBDASS OK
    X_SYN=[X_SYN,xsynaptica];       % Clean synaptics
    RESPONSES=[RESPONSES;r];        % AR processes
    XD=[XD,xclean];                % Detrended Signal
    NOISE_STD=[NOISE_STD;-NoiseStD]; % Noise
    disp('########################################################')
    %     pause
end

end
%% END