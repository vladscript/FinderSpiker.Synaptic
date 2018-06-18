% Funtion that reads info of the File
% Input
%   Nx: length of the signal
%   fs: sampling frequency
% Output
%   NC: Number of COnditions
%   Names_Conditions: Names of the COnditions
%   Intervlas: Intervale of each Condition [min]
function [NC,Names_Conditions,Intervals]=Get_Conditions_Details(Nx,fs)
%% Read condition's times *************************************************
ts=1/fs;
% 1st Input Dialogue
NC = inputdlg('Number of Conditions: ',...
             'Condition', [1 55]);
NC = str2num(NC{:}); 
Conditions_String='Condition_';
n_conditions=[1:NC]';
Conditions=[repmat(Conditions_String,NC,1),num2str(n_conditions)];
Cond_Names=cell(NC,1);
% Names=cell(NC,1);
% interval_defaut=[0,5];
interval_defaut= floor(linspace(0,Nx*ts/60,NC+1));
for i=1:NC
    Cond_Names{i}=Conditions(i,:);
    Names_default{i}=['...'];
    NVids_default{i}=[num2str(interval_defaut(i:i+1))];
    % interval_defaut=interval_defaut+5;
end
% 2nd Input Dialogue
name='Names of Conditions';
numlines=[1 50];
Names_Conditions=inputdlg(Cond_Names,name,numlines,Names_default);
% 3th Input Dialogue
NI=Nx*ts/60+1; % Initial Number of Intervals
Intervals=zeros(NC,2);
aux1=0;
% While Total DUration or Final Interval Vale is less than Signal Duration
while or(NI > Nx*ts/60 ,Intervals(end,end)> Nx*ts/60 )
    aux1=aux1+1;
    if aux1>1
        uiwait( msgbox('Check the Intervals') )
    end
    name='Intervals (minutes)';
    numlines=[1 50];
    Intervals_Conditions=inputdlg(Names_Conditions,name,numlines,NVids_default);
    for i=1:NC
        Intervals(i,:)=str2num(Intervals_Conditions{i});
    end
    NI=sum(diff(Intervals,1,2)); % duration of all intervals
end