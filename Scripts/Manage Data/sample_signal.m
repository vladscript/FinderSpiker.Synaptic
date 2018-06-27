%% Function to sample Signal
% From A to B of vector x
% Input
%   x: whole signal
%   A: Initial Sample
%   B: Finale Sample
% Output
%   xsampled: x(A:B)
function xsampled=sample_signal(x,A,B)
% Make Indexes Integer 
A=int32(A);
B=int32(B);
xsampled=[];
if isinteger(A)&& isinteger(B)
    xsampled=x(A:B);
end
