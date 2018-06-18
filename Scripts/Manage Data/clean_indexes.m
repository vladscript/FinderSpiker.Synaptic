% Function to Select Indexes (A in B) in C
% A: Selected Synaptics Indexes
% B: ISI<=0 Synaptics Indexes
% C: All Synaptics Indexes
% Input
%   StaySyn: Selected Synaptics Indexes
%   AllSyn:  Synaptics Indexes
%   All_Onsets: Parameter to Clean
% Output
function Clean_Param=clean_indexes(StaySyn,AllSyn,All_Param)
    if ~isempty(AllSyn)
        All_Indexes=1:numel(All_Param);
        Clean_Indexes=sort([setdiff(All_Indexes,AllSyn)';StaySyn]);
        Clean_Param=All_Param(Clean_Indexes);
    else
        Clean_Param=All_Param;
    end
end