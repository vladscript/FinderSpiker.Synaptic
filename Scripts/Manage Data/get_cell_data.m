% Make Cell Data of the Vector Signal
% in Intervals
% Input
%   x: vector
%   Intervasl: Matrix of intervlas:[a1:b1;...]
%   fs: Sampling Frequency
% Output
%   X{[xi]} cell each element is the vector ofr each interval
function X=get_cell_data(x,Intervals,fs)
%% Setup
Nc=size(Intervals,1);
X=cell(Nc,1);
%% Main Loop
for c=1:Nc
    Start=round(Intervals(c,1)*60*fs+1);
    End=round(Intervals(c,2)*60*fs);
    X{c}=x(Start:End);
end