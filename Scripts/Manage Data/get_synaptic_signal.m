% Funtion to vectorize Cell Array of Processed Signal
% Input
%   Intervals: [start_C1, end_C1; start_C2, end_C2; ...start_Ci, end_Ci;  ]
%   X_SYN: cell of N Conditions
%   N: Number of elemnts to Vectorize
%   fs: Sampling Frequency
% Output
%   x_syn: concatenated vector of the cell data
function x_syn=get_synaptic_signal(Intervals,X_SYN,N,fs)
    x_syn=zeros(N,1);
    [NC,~]=size(Intervals);
    for c=1:NC
        xc=X_SYN{c};
        Start=round(Intervals(c,1)*60*fs+1);
        End=round(Intervals(c,2)*60*fs);
        %disp(End-Start)
        % disp(numel(xc))
        x_syn(Start:End)=xc;
    end
end