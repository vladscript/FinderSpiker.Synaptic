% Get histograms from features of all conditions
% Input
% F= cell of C Conditions of NxFeat conditions
% Output
% f:        voectorized feature
% binF      bin
% CountsF   Counts for each bin
function [f,binF,CountsF]=get_histogram(F,varargin)
%% Setup
% If there differente Features in the Cell
if numel (varargin)>0
    Feat=varargin{1};
else
    Feat=1;
end
C=size(F,2);
f=[];
binF=[];
pF=[];
%% Vectorize Cell Conditions 
for c=1:C
    f=[f;F{c}(:,Feat)];
end
%% Histogram
[CountsF,binFaux]=histcounts(f);
binF=binFaux(1:end-1)+diff(binFaux);
% bar(binF,CountsF);
end