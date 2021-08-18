%Q3
load ('JAME_MaxExt3.mat')
load ('JAME_MaxFlex3.mat')
load ('JAME_RelaxedExtension.mat')
load ('JAME_RelaxedFlexion.mat')
%A= data;
Fs=1000;
L = length(data) ;
samplesize = L;
T=1/Fs;
t=(0 : L-1)*T ;

Bpfilter = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1',10, 'CutoffFrequency2', 499,'SampleRate', Fs);
notchfilter = designfilt('bandstopfir', 'FilterOrder', 100, 'CutoffFrequency1',49, 'CutoffFrequency2', 51,'SampleRate', Fs);
%Max extension
y1 = filter(Bpfilter , data);
y2 = filter(notchfilter , y1);
%Max flexion
load ('JAME_MaxFlex3.mat')
%B=data;
y3 = filter(Bpfilter , data);
y4 = filter(notchfilter , y3);
%Relaxed extension
load ('JAME_RelaxedExtension.mat')
%C=data;
y5 = filter(Bpfilter , data);
y6 = filter(notchfilter , y5);
%Relaxed flexion
load ('JAME_RelaxedFlexion.mat')
D=data;
y7 = filter(Bpfilter , D);
y8 = filter(notchfilter , y7);

%extension
%Rectifyingsignal by
rectified = abs(y2);
figure()
plot(t,rectified);
%Smoothing
samples = (1:(length(rectified)));
window = 100;
smooth = movmean(rectified,window);
figure()
plot(samples, smooth);

%Flexion
rectifiedF = abs(y4);
figure()
plot(t(1:78120),rectifiedF);
%Smoothing
samplesF = (1:(length(rectifiedF)));
windowF = 100;
smoothF = movmean(rectified,windowF);
figure()
plot(samplesF(58416:59778), smoothF(58416:59778));
hold on

baselineMean= mean(y4(58416:59778));
baselineSD=std(y4(58416:59778));
RE_threshold = baselineMean + 0.15*baselineSD;
yline(RE_threshold, 'g');
