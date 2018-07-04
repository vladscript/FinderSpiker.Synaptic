%% Globa Settings for Signal Processing
L=350;                      % Samples  of the Fluorophore Response
p=10;                       % AR(p) initial AR order        
taus_0= [.0075,0.02,1];     % starting values for taus
% Version 2.25->OK
% SW=1000;                    % Length in Window          (!)
% OLsamples=100;              % Overlapping Samples       (!)
% Version 2.31-> ?
SW=1000;                    % Length in Window          (!)
OLsamples=0;              % Overlapping Samples       (!)
ondeleta='sym8';            % Wavelet