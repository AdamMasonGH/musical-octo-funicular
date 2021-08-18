%Q2
load ('part111(1).mat')
A= data;
Fs=1000;
L= length(data) ;
T=1/Fs;
t=(0 : L-1)*T ;

Delta = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1',1, 'CutoffFrequency2', 4,'SampleRate', Fs);
y1 = filter(Delta , A);
Theta = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1',4, 'CutoffFrequency2', 8,'SampleRate', Fs);
y2 = filter(Theta , A);
Alpha = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1', 8, 'CutoffFrequency2' , 12,'SampleRate' , Fs);
y3 = filter(Alpha , A);
Beta = designfilt('bandpassfir', 'FilterOrder', 100, 'CutoffFrequency1',12, 'CutoffFrequency2' , 30,'SampleRate' , Fs);
y4 = filter(Beta , A);


figure(4)
subplot (5,1,1) ;
plot(t(5000:10000),data(5000:10000));
axis ([5 10 -inf inf]);
xlabel ('Time (s)');
ylabel ('Voltage(V)');
title ('ECG Data Signal');
hold on

subplot (5,1,2) ;
plot(t(5000:10000),y1(5000:10000));
axis ([5 10 -inf inf]);
xlabel ('Time (s)');
ylabel ('Voltage(V)');
title ('Delta Filter');
hold on

subplot (5,1,3) ;
plot(t(5000:10000),y2(5000:10000));
axis ([5 10 -inf inf]);
xlabel ('Time (s)');
ylabel ('Voltage(V)');
title ('Theta Filter');
hold on

subplot (5,1,4) ;
plot(t(5000:10000),y3(5000:10000));
axis ([5 10 -inf inf]);
xlabel ('Time (s)');
ylabel ('Voltage(V)');
title ('Alpha Filter');
hold on

subplot (5,1,5) ;
plot(t(5000:10000),y4(5000:10000));
axis ([5 10 -inf inf]);
xlabel ('Time (s)');
ylabel ('Voltage(V)');
title ('Beta Filter');

%Q4

load('PO1_PO2_EO_EC(1)(1).mat')
Fs = 256;
%Extracting the required channel
O1O= PO1_PO2_EO_EC(1,:);
O1C= PO1_PO2_EO_EC(3,:);


%Q5
%Calculate Welch's Power Spectral Density
[Pxx,F] = pwelch(O1O,[],[],[],Fs);
[Pxxc,Fc] = pwelch(O1C,[],[],[],Fs);

figure(1)
plot(F,Pxx,'r');
hold on
plot(Fc,Pxxc,'g');
axis([0 45 0 inf]);
xlabel('Frequency (Hz)');
ylabel('Power (dB)');
title('Power Spectral Density Open vs Closed eyes');
legend('Eyes Open','Eyes Closed');
hold off

%Q6

O2C= PO1_PO2_EO_EC(2,:);
O20= PO1_PO2_EO_EC(4,:);

[Cxy1,F] = mscohere(O1O,O1C,hamming(256),[],[],Fs);

figure(2)
plot(F,Cxy1);
xlabel('Frequency (Hz)');
ylabel('Magnitude Squared Coherence')
title('Coherence between O1O & O1C')

[Cxy2,F] = mscohere(O1O,O2O,hamming(256),[],[],Fs);

figure(3)
plot(F,Cxy2);
xlabel('Frequency (Hz)');
ylabel('Magnitude Squared Coherence')
title('Coherence between O1O & O2O')

mean(Cxy1)
mean(Cxy2)

