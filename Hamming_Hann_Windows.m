% Question 3(a) - Low pass Hamming and low pass Hann filters

Fs = 2000;
Fc = 300;
N = 100;

LPF = fdesign.lowpass('N,Fc',100,300,2000); %Important to include the
% sample frequency at the end in order to normalise the cutoff frequncy.
Hd1 = design(LPF,'window','window',@hamming, 'systemobject',true);
Hd2 = design(LPF,'window','window',@hann, 'systemobject',true);
figure
PLTa = fvtool(Hd1,Hd2);
legend(PLTa,'Hamming window design','Hann window design')
%*Still to comment on the filter

%Question 3(b) - Low pass Hamming filter and high pass Hamming filter

LPF = fdesign.lowpass('N,Fc',100,300,2000);
HPF = fdesign.highpass('N,Fc',100,300,2000);
Hd3 = design(LPF,'window','window',@hamming,'systemobject',true);
Hd4 = design(HPF,'window','window',@hamming,'systemobject',true);
figure
PLTb = fvtool(Hd3,Hd4);
legend(PLTb,'Hamming Window Lowpass Design','Hamming Window Highpass Design')
%need to comment on this

%Question 3(c) - Band pass Hamming filters

% Fs = 2000;
% Fc1 = 200
% Fc2 = 400
% N1 = 100, N2 = 50

BPF1 = fdesign.bandpass('N,Fc1,Fc2',100,200,400,2000);
BPF2 = fdesign.bandpass('N,Fc1,Fc2',50,200,400,2000);
Hd5 = design(BPF1,'window','window',@hamming,'systemobject',true);
Hd6 = design(BPF2,'window','window',@hamming,'systemobject',true);
figure
PLTc = fvtool(Hd5,Hd6);
legend(PLTc,'Hamming Window Bandpass Design (N=100)','Hamming Window Bandpass Design (N=50)')