% Funtions to clean up 
% repeated or overimposed synaptics
% Getting Biggest abslolute amplitude Synaptica
% Input
%   All_Onsets
%   All_Amplitudes
% Output
%   Selected Onsets Indexes
%   Indexes of All Repeated Synaptics
function [StaySyn,AllSyn]=clean_negative_isi(All_Onsets,All_Amplitudes)
% Get Negative  Inter-Synaptic-Intervals
SynBefore=find(diff(All_Onsets)<=0);
StaySyn=[];
AllSyn=[];
if ~isempty(SynBefore)
    SynAfter=find(diff(All_Onsets)<=0)+1;
    AllSyn=[SynBefore;SynAfter];
    Nrepsyn=numel(SynBefore);
    for n=1:Nrepsyn
        if SynBefore==SynAfter-1
            [~,BorA]=max(abs([All_Amplitudes(SynBefore(n)),All_Amplitudes(SynAfter(n))]));
            if BorA==1
                StaySyn=[StaySyn;SynBefore(n)];
            else
                StaySyn=[StaySyn;SynAfter(n)];
            end
        else
            % No supossed to happen EVER!
            dips('Somethnig Strange has Happened')
        end
    end
else
    disp('No ProblemO')
end
