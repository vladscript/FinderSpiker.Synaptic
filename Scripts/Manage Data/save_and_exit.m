% Function Called from:
% [Plot_Raw_Processed_Data.m]
% Update Synaptical Cell Array & Save when processing figure closes.
function save_and_exit(object,~)
%% Setup
% Call Global Variables:
global x_syn;
global Intervals;
global fs;
global FileName;
%% GET CELL DATA
X_SYN=get_cell_data(x_syn,Intervals,fs);
Experiment=FileName(1:end-4);
%% Update Clean Synaptic Signal
checkname=1;
while checkname==1
    % Get Directory
    DP=pwd;
    Slashes=find(DP=='\');
    DefaultPath=[DP(1:Slashes(end)),'Processed Data'];
    if exist(DefaultPath,'dir')==0
        DefaultPath=pwd; % Current Diretory of MATLAB
    end
    [FileName,PathName] = uigetfile('*.mat',[' Pick the Analysis File ',Experiment],...
        'MultiSelect', 'off',DefaultPath);
    dotindex=find(FileName=='.');
    if strcmp(FileName(1:dotindex-1),Experiment)
        checkname=0;
        % SAVE DATA
        save([PathName,FileName],'X_SYN','-append');
        disp([Experiment,'   -> UPDATED (Synaptical Signal)'])
        delete(gcf)
    elseif FileName==0
        checkname=0;
        disp('....CANCELLED')
        delete(gcf)
    else
        disp('Not the same Experiment!')
        disp('Try again!')
    end
end    
